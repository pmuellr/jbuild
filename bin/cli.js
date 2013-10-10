#!/usr/bin/env node

var jbuild = require("../lib/jbuild")
jbuild.main.apply(null, process.argv.slice(2))
