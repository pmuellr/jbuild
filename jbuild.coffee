# Licensed under the Apache License. See footer for details.

#-------------------------------------------------------------------------------
# build file for use with jbuild - https://github.com/pmuellr/jbuild
#-------------------------------------------------------------------------------

path = require "path"

# base name of this file, for watch()
__basename = path.basename __filename

# source and output directories
src = "lib-src"
out = "lib"

#-------------------------------------------------------------------------------
# perform a build
#-------------------------------------------------------------------------------

build = ->
    echo "compiling #{src} to #{out}"
    coffeec "--output #{out} #{src}/*.coffee"

#-------------------------------------------------------------------------------
# build task, just runs a build
#-------------------------------------------------------------------------------

exports.build =
    doc: "build the jbuild files"
    run: -> build()

#-------------------------------------------------------------------------------
# watch task: run a build, then watch for changes to this file, and sources
#-------------------------------------------------------------------------------

exports.watch =
    doc: "watch for source file changes, then rebuild"
    run: ->
        build()

        # watch for changes to sources, run a build
        watch
            files: "#{src}/*.coffee"
            run: -> build()

        # watch for changes to this file, then exit
        watch
            files: __basename
            run: -> 
                echo "file #{__basename} changed; exiting"
                process.exit 0

#-------------------------------------------------------------------------------
# command to compile coffee files
#-------------------------------------------------------------------------------

coffeec = (args) -> exec "node_modules/.bin/coffee --compile #{args}"

#-------------------------------------------------------------------------------
# Copyright 2013 Patrick Mueller
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------
