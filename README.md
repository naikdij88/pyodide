# PyConsole

## Compiling CPython to WebAssembly

These instructions were tested on Linux.

Make sure the prerequisites for [emsdk](https://github.com/juj/emsdk) are installed.

    $ `make`

The build downloads and builds a local, patched version of emsdk, then
downloads and builds Python. 

## Running web extension locally

* In firefox, go to: about:debugging#addons
* Pick `manifest.json` from addon directory after selecting "Load Temporary
  Add-on"

##  Assembling web extension

After building CPython, files from `build/` (except `pyodide_dev.js`) are copied to
`addon/src/pyodide`. `pyodide.js` is then modified so that the baseURL is
`'pyodide/'` and the packages object is emptied.

Extension can then be built in standard ways:
https://developer.mozilla.org/en-US/Add-ons/WebExtensions/Package_your_extension_
