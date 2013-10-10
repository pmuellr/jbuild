# Licensed under the Apache License. See footer for details.

#-------------------------------------------------------------------------------
exports.build =
    doc: "build the jbuild files"
    run: ->
        src = "lib-src/jbuild.coffee"
        out = "lib"

        echo "compiling #{src} to #{out}"
        coffeec "--output lib lib-src/jbuild.coffee"

#-------------------------------------------------------------------------------
exports.echo =
    doc: "echo's it's arguments to stdout"
    run: (args...) ->
        echo args.join " "

#-------------------------------------------------------------------------------
exports.throwsError =
    doc: "throws an error"
    run: ->
        throw new Error "all this task does is throw an error"

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
