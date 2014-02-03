# Licensed under the Apache License. See footer for details.

#-------------------------------------------------------------------------------
# build file for use with jbuild - https://github.com/pmuellr/jbuild
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# perform a build, defined using defineTasks()
#-------------------------------------------------------------------------------

tasks = defineTasks exports,
    watch: "watch for source changes, then build, then test"
    build: "build the package from source"
    test:  "test the package"

#-------------------------------------------------------------------------------
tasks.watch = ->

    watchFiles

        "lib-src/*.coffee" :->
            tasks.build()
            tasks.test()

        "jbuild.coffee" :->
            echo "file jbuild.coffee changed; exiting"
            process.exit 0

#-------------------------------------------------------------------------------
tasks.build = ->
    log "compiling source"
    coffee "--compile --output lib lib-src/*.coffee"

#-------------------------------------------------------------------------------
# watch task: run a build, then watch for changes to this file, and sources
#-------------------------------------------------------------------------------

exports.watch =
    doc: "watch for source file changes, then rebuild"
    run: ->
        tasks.build()

        # watch for changes to sources, run a build
        watchFiles
            "lib-src/*.coffee" :-> tasks.build()
            "jbuild.coffee" :->
                echo "file jbuild.coffee changed; exiting"
                process.exit 0


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
