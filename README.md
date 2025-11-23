# install-pkg

This GitHub action installs additional GAP packages.

## Usage

The action `install-pkg` has to be called by the workflow of a GAP
package.
It installs the package(s) using [PackageManager](https://github.com/gap-packages/PackageManager).
This also means that PackageManager will automatically take care of unmet dependencies
and will build package(s) if needed.

## Migration from setup-gap@v2

This package is intended to replace the `GAP_PKGS_TO_CLONE` and `GAP_PKGS_TO_BUILD` inputs,
though with some notable changes.


### Inputs

The following input is mandatory:

- `packages`:
  - Space-separated or newline-separated list of packages to install.
    Can be the name of the package, the link to a git repo (ending in `.git'`'), or
    the link to a release archive (ending in `.tar.gz`).
  - default: `''`
 
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
      - uses: actions/checkout@v5
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
