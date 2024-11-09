# Contributing

Thank you for considering contributing to [Arch-Update](https://github.com/Antiz96/arch-update)!

With the exception of the [general rules](#general-rules) (which **must** be acknowledged and applied in any contribution / interaction in this project), these guidelines represent an ideal target & standards that I would like this project to follow but may not all be **strictly** enforced (depending on the situation).

Please, don't refrain yourself from contributing if you feel that your contribution may not entirely follow these guidelines (or if you're struggling applying some of them). I value your contributions much more than the strict application of these guidelines!

## Table of contents

- [General rules](#general-rules)
- [Open an issue](#open-an-issue)
- [Open a pull request](#open-a-pull-request)
- [Donations](#donations)
- [Thank you](#thank-you)

## General rules

These general rules apply to **every** contributions (whatever the type). They should **always** be acknowledged and **strictly** followed in any circumstances:

Basic common sense applies to every contributions & discussions: stay polite and respectful, no flaming / trolling / spamming or any kind of discrimination / harassment, avoid controversial topics *(specifically if it has nothing to do with this project whatsoever)*, etc...

Use English as much as possible for contributions & discussions. If required, I can also speak French, but it's important that contributions & discussions remain intelligible to most people.

Arch-Update is developed and tested specifically with *vanilla* Arch Linux in mind. That doesn't mean that Arch-Update won't work with other Arch based distributions (e.g. EndeavourOS,  CachyOS, Garuda...), but keep in mind that such distributions are supported at a "best effort" level. In other words, I'll try my best to keep Arch-Update compatible with derivatives distributions, but there's no guarantee that Arch-Update (or parts of it) will *continuously* work properly on such distributions.

## Open an issue

Before [opening an issue](https://github.com/Antiz96/arch-update/issues/new/choose), verify that there isn't one already open on the same (or a similar) subject.

Make sure to use the correct type for your issue (`Bug Report` or `Feature Request`) and to provide the requested information. If you have a doubt about which one is the most appropriate for your issue (or if you think that none of these types apply to your issue), feel free to use the general `Other` type.

Providing as much details as possible in your issue will ease its processing.

## Open a pull request

Read the following sub-chapters before opening a pull request.  
Make sure to create your merge request from a dedicated branch (do not use the `main` branch) and to provide the information requested in the [pull request template](https://github.com/Antiz96/arch-update/blob/main/.github/PULL_REQUEST_TEMPLATE.md).

### Open an issue first

Apart from trivial changes (like simple typo fixes), it is advised to first [open an issue](#open-an-issue) to expose and discuss your changes, verify its feasibility / necessity and agree on the specifications.

### Coding style

When submitting code changes, try to respect the coding style and the overall way things work, as much as possible.  
For instance:

- Stick to bash syntax
- Variables should use the `"${var}"` format
- Use the `{main,info,ask,warning,error}_msg` functions to print messages
- Use `"$(eval_gettext "string")"` for any string chain that should be included in translations
- The main `arch-update.sh` script should only be used as a wrapper around "libraries" stored in `src/lib/`
- [...]

Bash code is checked with [shellcheck](https://www.shellcheck.net/).  
Python code is checked with [pylint](https://github.com/pylint-dev/pylint).  
Markdown syntax is checked with [markdownlint](https://github.com/markdownlint/markdownlint).

### Commit message format

Commits must follow the [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.

This project uses the following commit types:

- chore: for internal / miscellaneous changes
- feat: for new features (or improvements / additions to existing features)
- fix: for bug fixes
- doc: for documentation only changes
- style: For changes that do not affect the meaning of the code (white-space, formatting, typo fixes, etc...)

An optional scope can be provided to the commit type if relevant (for instance when a change is specific to a precise part of the project), like so: `type(scope): commit message`.

If a commit introduces a breaking change, its type must contain a `!` (e.g. `feat!: commit message`) and / or a `BREAKING CHANGE:` mention should be added at the end of your commit message (e.g. `BREAKING CHANGE: description of the breaking change`).

Here are a few examples of the expected commit format:

```text
feat(systray): Add a right click menu to the systray applet

Add a right click menu to the systray applet containing two entries:
One to run Arch-Update and one to "exit" (close) the systray applet

Closes https://github.com/Antiz96/arch-update/issues/163
```

```text
fix: Improve parsing on Flatpak cli output to avoid false positives

The current parsing of the Flatpak cli output when looking for pending Flatpak updates is subject to false positives.
This commit makes it more robust to avoid such issues.

Fixes https://github.com/Antiz96/arch-update/issues/103
```

```text
doc(man): Add the -l / --list option to man pages

The recently introduced -l / --list option was missing from the man page
```

```text
style: Typo fixes in README and man pages
```

```text
chore!(code structure): Split the script functions into separate libraries

Split the functions inside the main script into their own separate libraries scripts to improve readability and ease the overall maintenance and contribution processes.

Closes https://github.com/Antiz96/arch-update/issues/230

BREAKING CHANGE: The python script for the systray applet is now sourced as a library by the main script (and not executed from `"installation_prefix"/bin/` anymore).  
People that installed Arch-Update from source will have to either uninstall it (with `make uninstall`) **before** pulling and installing the new version (with `make install`), or they will have to manually remove the `arch-update-tray` file from their system (which is under `/usr/local/bin/` if the default installation prefix was used) after upgrading from `v2.x.x` to `v3.x.x`. Otherwise, the `arch-update-tray` file will remain un-tracked on the system.
```

### License

By contributing to this project, you agree that your contributions will be licensed under the [GPL-3.0 license](https://github.com/Antiz96/arch-update/blob/main/LICENSE) (or any later version of this license).

## Donations

You can also support this project development (and my work in general) by making a donation via my [GitHub sponsor page](https://github.com/sponsors/Antiz96).

## Thank you

Once again, thank you for considering contributing to Arch-Update!  
I'd also like to thank everyone that already opened issues, feature requests, pull requests or contributed to Arch-Update in any other way! :heart:
