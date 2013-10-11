# Licensed under the Apache License. See footer for details.

#-------------------------------------------------------------------------------
# build file for use with jbuild - https://github.com/pmuellr/jbuild
#-------------------------------------------------------------------------------

src = "lib-src"
out = "lib"

#-------------------------------------------------------------------------------
build = ->
    src = "lib-src"
    out = "lib"

    echo "compiling #{src} to #{out}"
    coffeec "--output #{out} #{src}/*.coffee"

#-------------------------------------------------------------------------------
exports.build =
    doc: "build the jbuild files"
    run: -> build()

#-------------------------------------------------------------------------------
exports.watch =
    doc: "watch for source file changes, then rebuild"
    run: ->
        build()

        watch
            files: "#{src}/*.coffee"
            run: -> build()

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
