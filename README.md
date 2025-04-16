# WPEverest - Action Build

A GitHub Action to build WPEverest plugins using Composer and NPM.

## Managing files in the build

Use a `.distignore` file to exclude files from the build.

## Example

```yaml
name: Build release and save asset
on:
  release:
    types: [published]
jobs:
  build:
    name: Build release and save asset
    runs-on: ubuntu-20.04.02
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Build
        id: build
        uses: wpeverest/action-build@v2
        with:
          generate-zip: true
      - name: Upload release asset
        uses: actions/upload-release-asset@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: ${{ steps.build.outputs.zip_path }}
          asset_name: ${{ github.event.repository.name }}.zip
          asset_content_type: application/zip
```
