#!/bin/sh

# a little helper to build jbuild if you don't have it installed already :-)

node_modules/.bin/coffee --compile --output lib lib-src/*.coffee