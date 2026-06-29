This is a copy of `pyyaml-3.12` vendored on april 24, 2018 by @springmeyer.

https://github.com/mapbox/mason/issues/563 documents why.

The process to vendor was:

```
cd mason
pip install pyyaml --user
cp $(python -m site --user-site)/yaml scripts/clang-tidy/6.0.0/
```

Then the `clang-tidy` package was built and the `yaml` directory was copied beside the `share/run-clang-tidy.py` script (which depends on it).