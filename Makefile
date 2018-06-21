PYODIDE_ROOT=$(abspath .)
include Makefile.envs

FILEPACKAGER=emsdk/emsdk/emscripten/tag-1.38.4/tools/file_packager.py

CPYTHONROOT=cpython
CPYTHONLIB=$(CPYTHONROOT)/installs/python-$(PYVERSION)/lib/python$(PYMINOR)

CC=emcc
CXX=em++
OPTFLAGS=-O3
CFLAGS=$(OPTFLAGS) -g -I$(PYTHONINCLUDE) -Wno-warn-absolute-paths
CXXFLAGS=$(CFLAGS) -std=c++14

# __ZNKSt3__220__vector_base_commonILb1EE20__throw_length_errorEv is in
# EXPORTED_FUNCTIONS to keep the C++ standard library in the core, even though
# there isn't any C++ there, for the sake of loading dynamic modules written in
# C++, such as those in matplotlib.
LDFLAGS=\
	-O3 \
	-s MODULARIZE=1 \
	$(CPYTHONROOT)/installs/python-$(PYVERSION)/lib/libpython$(PYMINOR).a \
  -s "BINARYEN_METHOD='native-wasm'" \
  -s TOTAL_MEMORY=536870912 \
	-s MAIN_MODULE=1 \
	-s EMULATED_FUNCTION_POINTERS=1 \
  -s EMULATE_FUNCTION_POINTER_CASTS=1 \
  -s EXPORTED_FUNCTIONS='["_main", "__ZNKSt3__220__vector_base_commonILb1EE20__throw_length_errorEv"]' \
  -s WASM=1 \
	-s SWAPPABLE_ASM_MODULE=1 \
	-s USE_FREETYPE=1 \
	-std=c++14 \
  -lstdc++ \
  --memory-init-file 0

SITEPACKAGES=root/lib/python$(PYMINOR)/site-packages

all: build/pyodide.asm.js build/pyodide.asm.data build/pyodide.js build/addon

build/pyodide.asm.js: src/main.bc src/jsimport.bc src/jsproxy.bc src/js2python.bc \
					  src/pyimport.bc src/pyproxy.bc src/python2js.bc \
					  src/runpython.bc src/dummy_thread.bc src/hiwire.bc
	[ -d build ] || mkdir build
	$(CXX) -s EXPORT_NAME="'pyodide'" -o build/pyodide.asm.html $(filter %.bc,$^) \
	  $(LDFLAGS) -s FORCE_FILESYSTEM=1
	rm build/pyodide.asm.asm.js
	rm build/pyodide.asm.wasm.pre
	rm build/pyodide.asm.html

build/pyodide.asm.data: root/.built
	python2 $(FILEPACKAGER) build/pyodide.asm.data --preload root/lib@lib --js-output=build/pyodide.asm.data.js

build/pyodide.js: src/pyodide.js
	cp $< $@
	sed -i -e 's#{{DEPLOY}}#pyodide/#g' $@

build/addon:
	echo 'Copying pyodide files to addon'
	cp build/* addon/src/pyodide/

clean:
	rm -fr root
	rm build/*
	rm src/*.bc

%.bc: %.cpp $(CPYTHONLIB)
	$(CXX) --bind -o $@ $< $(CXXFLAGS)

%.bc: %.c $(CPYTHONLIB)
	$(CC) -o $@ $< $(CFLAGS)

root/.built: \
		$(CPYTHONLIB) \
		src/sitecustomize.py \
		src/pyodide.py \
		remove_modules.txt
	rm -rf root
	mkdir -p root/lib
	cp -a $(CPYTHONLIB)/ root/lib
	cp src/sitecustomize.py $(SITEPACKAGES)
	cp src/pyodide.py root/lib/python$(PYMINOR)/site-packages
	( \
		cd root/lib/python$(PYMINOR); \
		rm -fr `cat ../../../remove_modules.txt`; \
		rm encodings/mac_*.py; \
		find . -name "*.wasm.pre" -type f -delete ; \
		find -type d -name __pycache__ -prune -exec rm -rf {} \; \
	)
	touch root/.built


$(CPYTHONLIB): emsdk/emsdk/emsdk
	make -C $(CPYTHONROOT)

emsdk/emsdk/emsdk:
	make -C emsdk
