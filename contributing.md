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


# Creating new packages


### Tips for creating patch files

When packages need to be patched a good workflow is:

```bash
# try your build
./mason build <your package> <your version>
# if the build fails and needs patched...
cd mason_packages/.build/<your package>/
git init . && git add . && git commit -a -m "add all files"`
# edit some things fixing the build
# then dump the patch file out
git diff > ../../../scripts/<your package>/<your version>/patch.diff
# Then add the patch back to the script.sh so it is run automatically by adding something like:
# patch -N -p1 < ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff to your `mason_compile` step
```
