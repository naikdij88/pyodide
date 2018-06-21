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
