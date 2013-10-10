# Licensed under the Apache License. See footer for details.

fs   = require "fs"
path = require "path"

_      = require "underscore"
coffee = require "coffee-script"

require "shelljs/global"

PROGRAM = path.basename(__filename).split(".")[0]

Tasks = null

HelpTasks = ["help", "?", "-?", "-h", "--h", "--help"]

#-------------------------------------------------------------------------------
exports.main = main = (task, args...) ->

    if not test("-f", "jbuild.js") and not test("-f", "jbuild.coffee")
        if task in HelpTasks
            help()
        else
            logError null, "jbuild.js not found in current dir; use `jbuild help` for help"

    # load the local jbuild module
    try 
        jmod = require "#{path.join process.cwd(), 'jbuild'}"
    catch err
        logError err,  "unable to load module jbuild: #{err}"

    # get tasks from the module
    Tasks = {}

    for name, taskObj of jmod
        if !_.isFunction taskObj.run
            logError null, "the run property of task #{name} is not a function"

        taskObj.name  = name
        taskObj.doc  ?= "???"

        Tasks[name] = taskObj

    # print help if no args, or arg is help, or unknown task
    help() if !task? or task in HelpTasks

    if !Tasks[task]?
        logError null, "unknown task '#{task}'; use `jbuild help` for help"

    # run the task
    try
        Tasks[task].run.apply null, args
    catch err
        logError err,  "running task #{task}"

    return

#-------------------------------------------------------------------------------
log = (message) ->
    if !message? or message is ""
        console.log ""
    else
        console.log "#{PROGRAM}: #{message}"
    return

#-------------------------------------------------------------------------------
logError = (err, message) ->
    log "error: #{message}"

    if err
        console.log "stack:" 
        console.log err.stack

    process.exit 1
    return

#-------------------------------------------------------------------------------
help = ->
    console.log """
        usage: #{PROGRAM} task arg arg arg ...

        Run a task from ./jbuild.js or ./jbuild.coffee, passing the
        appropriate args.

        The tasks should be exported from the jsbuild module.
    """

    process.exit 1 if !Tasks?

    console.log """

        Available tasks from your jbuild module:

    """

    tasks            = _.values Tasks
    longestNamedTask = _.max tasks, (task) -> task.name.length
    maxTaskNameLen   = longestNamedTask.name.length

    for task in tasks
        name = task.name
        doc  = task.doc
        console.log "   #{alignLeft name, maxTaskNameLen} - #{doc}"

    process.exit 1

#-------------------------------------------------------------------------------
alignLeft = (s, len) ->
    while s.length < len
        s += " "
    return s

#-------------------------------------------------------------------------------
main.apply null, (process.argv.slice 2) if require.main is module

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
