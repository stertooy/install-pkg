# install-pkg

This GitHub action installs additional GAP packages.

## Supported OSes

This action can be run on Ubuntu. There is some support for macOS and Windows (through the
`setup-cygwin` action), but this should be considered experimental and is only expected to
work properly for recent versions of GAP (>= 4.14).


## Usage

The action `install-pkg` has to be called by the workflow of a GAP
package.
It installs the package(s) using [PackageManager](https://github.com/gap-packages/PackageManager).
This also means that PackageManager will automatically take care of unmet dependencies
and will build package(s) if needed.

You can tell PackageManager which packages to install using three different formats:
 - the name of the package,
 - the link to a release archive (ending in `.tar.gz` or `.tar.bz2`),
 - the link to the git repo (ending in `.git'`').

With the first option, PackageManager will download the latest release of the specified package.
With the second option, PackageManager will download the specified archive. This is useful if you
need an exact version of a particular package.
With the third option, PackageManager will clone the default branch of the specified repository,
and then attempt to build the documentation. You will likely have to set either `use-latex` or
`ignore-errors` to `true` in this case.


## Migration from setup-gap@v2

This package is intended to replace the `GAP_PKGS_TO_CLONE` and `GAP_PKGS_TO_BUILD` inputs,
though with some notable changes.


### Inputs

The following input is mandatory:

- `packages`:
  - Space-separated or newline-separated list of packages to install.
    Can be the name of the package, the link to a git repo (ending in `.git'`'),
    or the link to a release archive (ending in `.tar.gz` or `.tar.bz2`).
 
The following inputs are all optional:

- `ignore-errors`:
  - Ignore errors raised by PackageManager. Can be of use when it
    fails to build documentation that you don't need anyway.
  - default: `'false'`
- `use-latex`:
  - Install and use LaTeX (only works on Linux).
  - default: `'false'`


### Examples

See below for a minimal example to run this action.

#### Minimal example
```yaml
name: CI

# Trigger the workflow on push or pull request
on:
  push:
  pull_request:

jobs:
  test:
    name: Test
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v6
      - uses: gap-actions/setup-gap@v3
      - uses: gap-actions/install-pkg@v1
        with:
          packages: 'example'
```

## Contact
Please submit bug reports, suggestions for improvements and patches via
the [issue tracker](https://github.com/gap-actions/install-pkg/issues).

## License
The action `install-pkg` is free software; you can redistribute
and/or modify it under the terms of the GNU General Public License as published
by the Free Software Foundation; either version 2 of the License, or (at your
opinion) any later version. For details, see the file `LICENSE` distributed
with this action or the FSF's own site.
