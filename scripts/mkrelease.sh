#!/bin/bash
set -euo pipefail

# Check that we are on the main branch
if [ "$(git branch --show-current)" != "main" ]; then
	echo -e >&2 "ERROR: Current branch is not 'main'"
	exit 1
fi

# Check that `github-cli` is correctly authenticated
if ! gh auth status > /dev/null; then
	echo -e >&2 "ERROR: github-cli is not authenticated"
	exit 2
fi

# Pull repo and fetch tags
git pull
git fetch --tags

# Assign and check tag variables
release_tag="${1}"
latest_tag=$(git describe --tags --abbrev=0)

if [ -z "${release_tag}" ]; then
	echo -e >&2 "ERROR: Release tag is empty\nUsage: ./scripts/mkrelease.sh X.Y.Z # where 'X.Y.Z' is the tag to create"
	exit 3
fi

echo -e "Release tag = v${release_tag}\nLatest tag = ${latest_tag}\n"
read -rp "Confirm? [y/N] " answer

case "${answer}" in
	y|Y)
		echo -e "\nProceeding in 5 sec"
		sleep 5
	;;
	*)
		echo -e >&2 "\nAborting"
		exit 4
	;;
esac


# Bump version where necessary
sed -i "s/${latest_tag#v}/${release_tag}/g" doc/man/arch-update.* doc/man/fr/arch-update.* po/* src/arch-update.sh

# Update changelog
git-cliff -up CHANGELOG.md
sed -i "s|\[unreleased\]|\[v${release_tag}\](https://github.com/Antiz96/arch-update/releases/tag/v${release_tag})\ -\ $(date '+%Y-%m-%d')|g" CHANGELOG.md

# Review changes
git diff
echo
read -rp "Confirm? [y/N] " answer

case "${answer}" in
	y|Y)
		echo -e "\nProceeding in 5 sec"
		sleep 5
	;;
	*)
		echo -e >&2 "\nAborting"
		exit 5
	;;
esac

# Create and push a signed commit
git add .
git commit -SD33FAA16B937F3B2 -m "chore(release): v${release_tag}"
git push

# Create and push a signed tag
git tag "v${release_tag}" -u D33FAA16B937F3B2 -m "v${release_tag}"
git push origin "v${release_tag}"

# Create release
echo -e "\nType (or paste) release notes, press ctrl+d when done\n"
gh release create "v${release_tag}" --title "v${release_tag}" --verify-tag -F -

# Download and sign auto-generated source tarball and checksum
gh release download "v${release_tag}" --archive tar.gz --clobber
gpg --local-user D33FAA16B937F3B2 --armor --detach-sign "arch-update-${release_tag}.tar.gz"
sha256sum "arch-update-${release_tag}.tar.gz" > "arch-update-${release_tag}.tar.gz.sha256"
gpg --local-user D33FAA16B937F3B2 --armor --detach-sign "arch-update-${release_tag}.tar.gz.sha256"

# Upload source tarball and checksum signatures
gh release upload "v${release_tag}" "arch-update-${release_tag}.tar.gz.asc" "arch-update-${release_tag}.tar.gz.sha256" "arch-update-${release_tag}.tar.gz.sha256.asc"
rm -f "arch-update-${release_tag}.tar.gz"*
