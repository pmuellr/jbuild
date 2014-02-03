# Licensed under the Apache License. See footer for details.

shelljs = require "shelljs"

utils = exports

#-------------------------------------------------------------------------------
utils.runTest = (name, expFileName, cmd, done) ->
    cwd = process.cwd()
    process.chdir name

    try
        runTest name, expFileName, cmd
    finally
        process.chdir cwd

#-------------------------------------------------------------------------------
runTest = (name, expFileName, cmd, done) ->
    cmd = "node ../../bin/cli.js #{cmd}"

    opts =
        silent: true
        async:  false

    shelljs.exec cmd, opts, (code, actOutput) ->
        expOutput = shelljs.cat expFileName

        done() if actOutput is expOutput


        console.log ""
        console.log "expected:"
        console.log expOutput
        console.log ""
        console.log "actual:"
        console.log actOutput

        done new Error "unexpected output from #{name}/#{expFileName}"

#-------------------------------------------------------------------------------
# Copyright 2014 Patrick Mueller
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
