# install-pkg

This GitHub action installs additional GAP packages.

## Usage

The action `install-pkg` has to be called by the workflow of a GAP
package.
It installs the package(s) in GAP's `pkg` subfolder.

## Migration from setup-gap@v2

This package is intended to replace the `gap-pkgs-to-clone` input, though with some
notable changes. Packages will **not** be built, this has to be done by a subsequent
`build-pkg` action.


### Inputs

The following input is mandatory:

- `packages`:
  - Space-separated or newline-separated list of packages to install. Packages are either
    given as `package@version`, or by an URL pointing to a release archive. Here, `package`
    can either be the name of a package in the GAP package distribution or the name of a
    GitHub repository (of the form "org/repo"). The suffix `version` is either `latest`,
    `devel`, or a version number.
  - default: `''`

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
          packages: |
            gap-packages/smallgrp
            autpgrp@devel
            https://github.com/gap-packages/primgrp/releases/download/v4.0.2/primgrp-4.0.2.tar.gz
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
