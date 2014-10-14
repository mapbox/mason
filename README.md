## Mason

Build automation for the Mapbox C++ core

[![Build status](https://ci.appveyor.com/api/projects/status/tjybfxu4cgerjlcn)](https://ci.appveyor.com/project/Mapbox/mason)

The future home of the scripts from:

  - https://github.com/mapnik/mapnik-packaging
  - https://github.com/BergWerkGIS/build-gdal/tree/master/windows

## Mac OS X

```
(git clone https://github.com/mapbox/mason.git /usr/local/share/mason ; ln -s /usr/local/share/mason/mason /usr/local/bin/mason)
```

Usage:
```
$ mason install libuv 0.11.29
...
$ mason prefix libuv 0.11.29
/usr/local/mason/osx-10.9/libuv/0.11.29
```

### Goal

 - Automake C++ SDKs for node-mapnik, node-gdal, node-osrm, node-osmium, and mapbox-gl-native
