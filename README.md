# Docker Harness for [Workspace]

To use this harness:

1. Install [Workspace]
1. Get the release version from [release notes]
2. Run `ws create <projectName> inviqa/docker:v{release version}`
3. Fill in project-specific AWS and Github credentials, set as blank if you don't need them
4. Change to the <projectName> directory: `cd <projectName>`
5. Create an initial commit, ensuring that `workspace.override.yml` is not added to git:
```bash
git init
git add .
git commit -m "Initial commit"
```
6. Store the `workspace.override.yml` contents in a suitable location (such as LastPass).

## Releasing

### Performing a Release

1. Head to the [releases page] and create a new release:
    * Enter the tag name to be created
    * Give it a title containing the same tag name
    * Click "Auto-generate release notes"
    * Click `Publish Release`
1. Submit a pull request to [my127/my127.io] that adds the new release version and asset download URL for the
   Go harness to `harnesses.json`
### Setup the next minor release branch

1. Create a new branch for the minor release
   ```bash
   git fetch
   git checkout -b x.y.z origin/HEAD
   git push x.y.z
   ```
1. Switch the default branch in Github [branch settings](https://github.com/inviqa/harness-docker/settings/branches) to the new branch

[releases page]: https://github.com/inviqa/harness-go/releases
[my127/my127.io]: https://github.com/my127/my127.io
[Workspace]:https://github.com/my127/workspace
[upgrade doc]: UPGRADE.md
