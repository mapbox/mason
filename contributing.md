# Release process

- Increment version at the top of `mason`
- Increment the version in the [Readme](https://github.com/mapbox/mason/blob/master/README.md#installation)
- Update changelog
- Ensure tests are passing
- Tag a release:

```
TAG_NAME=$(cat mason | grep MASON_RELEASED_VERSION= | cut -d '"' -f2)
git tag v${TAG_NAME} -a -m "v${TAG_NAME}" && git push --tags
```

- Go to https://github.com/mapbox/mason/releases/new and create a new release
