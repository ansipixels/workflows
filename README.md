# workflows
Workflows reused across the Go repos, to avoid dozens of same dependabot bumps

Adapted from [fortio/workflows](https://github.com/fortio/workflows) with the following changes:
- Uses `ghcr.io/ansipixels` instead of `docker.io/fortio` for container images
- Uses GitHub Container Registry instead of Docker Hub
- Package imports use fortio.org vanity domain, but ansipixels local packages stay at github.com/ansipixels/$repo

The goreleaser and golangci-lint configs are shared and downloaded by the respective steps

A typical use is to setup the following (see fortio/multicurl for original example)
```yaml
name: "Shared cli/server ansipixels workflows"
on:
    push:
      branches: [ main ]
      tags:
        # so a vX.Y.Z-test1 doesn't trigger build
        - 'v[0-9]+.[0-9]+.[0-9]+'
        - 'v[0-9]+.[0-9]+.[0-9]+-pre*'
    pull_request:
      branches: [ main ]

jobs:
    call-gochecks:
        uses: ansipixels/workflows/.github/workflows/gochecks.yml@main
    call-codecov:
        uses: ansipixels/workflows/.github/workflows/codecov.yml@main
    call-codeql:
        uses: ansipixels/workflows/.github/workflows/codeql-analysis.yml@main
        # Permissions are now optional (defined at workflow level) but recommended for clarity
        permissions:
            actions: read
            contents: read
            security-events: write
    call-releaser:
        if: github.event_name == 'push' && startsWith(github.ref, 'refs/tags/')
        uses: ansipixels/workflows/.github/workflows/releaser.yml@main
        with:
            ### *** Don't forget to update this: *** ###
            description: "Ansipixels ...update description...."
            # Optional:
            # main_path: for binaries not in "."
            # binary_name: for a name different than the default (which project name)
        secrets:
            GH_PAT: ${{ secrets.GH_PAT }}
```

Or for a library

```yaml
# Same as full workflow but without the goreleaser step
name: "Shared library ansipixels workflows"

on:
    push:
      branches: [ main ]
    pull_request:
      branches: [ main ]

jobs:
    call-gochecks:
        uses: ansipixels/workflows/.github/workflows/gochecks.yml@main
    call-codecov:
        uses: ansipixels/workflows/.github/workflows/codecov.yml@main
    call-codeql:
        uses: ansipixels/workflows/.github/workflows/codeql-analysis.yml@main
        # Permissions are now optional (defined at workflow level) but recommended for clarity
        permissions:
            actions: read
            contents: read
            security-events: write
```

Dependabot will regularly update pinned github actions - to pin a new dependency:

Use https://github.com/mheap/pin-github-action
```
npm install -g pin-github-action
```
for each action:
```
pin-github-action .github/workflows/...yml
```


Note about `golangci-lint` make sure to run locally `make` before MRs


## Newrepo tool

See [newrepo.sh](newrepo.sh) to create a new repo under ansipixels/

## Key Differences from fortio/workflows

1. **Container Registry**: Uses GitHub Container Registry (ghcr.io) instead of Docker Hub
   - Images are published to `ghcr.io/ansipixels/{binary_name}` instead of `fortio/{binary_name}`
   - Authentication uses GITHUB_TOKEN instead of DOCKER_USER/DOCKER_TOKEN

2. **Package Imports**: ansipixels projects can use fortio.org packages via the vanity domain, but ansipixels local packages stay at github.com/ansipixels/$repo

3. **Homebrew Tap**: Uses ansipixels/homebrew-tap instead of fortio/homebrew-tap

4. **Homepage**: References github.com/ansipixels instead of fortio.org
