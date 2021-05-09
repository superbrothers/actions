# actions

![CI](https://github.com/superbrothers/actions/workflows/CI/badge.svg)

This repo provides a collection of actions for use in your workflows.

## setup-krew

This action sets up krew tool on your job.

```yaml
steps:
- uses: superbrothers/actions/setup-krew@master
- run: kubectl krew version
```

## krew-plugin-test

This action tests your kubectl plugin with krew tool.

```yaml
steps:
- uses: superbrothers/actions/krew-plugin-test@master
  with:
    archive: ./dist/kubectl-open_svc-linux-arm64.zip
    manifest: ./dist/open-svc.yaml
    command: kubectl open-svc --help
```

See [action.yml](./krew-plugin-test/action.yml) for inputs.

## krew-plugin-release

This action creates a pull request to krew-index repo for releasing your kubectl plugin.

```yaml
- uses: superbrothers/actions/krew-plugin-release@master
  with:
    token: ${{ secrets.PAT }}
    manifest_path: ./dist/open-svc.yaml
    git_author_name: Kazuki Suda
    git_author_email: kazuki.suda@gmail.com
```

See [action.yml](./krew-plugin-release/action.yml) for inputs.
