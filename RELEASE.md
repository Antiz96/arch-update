# Creating a new release

## Required dependencies

- `git-cliff`
- `github-cli`

## Disable the main branch protection rule temporarily

<https://github.com/Antiz96/arch-update/settings/branches>

## Run the script

From the root of the repo:

```bash
./scripts/mkrelease.sh X.Y.Z
```

Where `X.Y.Z` is the version / tag number to create (example: 3.16.2)

## Re-enable the main branch protection rule

<https://github.com/Antiz96/arch-update/settings/branches>
