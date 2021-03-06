# Licensed under the Apache License. See footer for details.

fs   = require "fs"
path = require "path"

_      = require "underscore"
coffee = require "coffee-script"
require "shelljs/global"

pkg    = require "../package.json"
watch  = require "./watch"

coffee.register()

global.watch       = watch.watch
global.watchFiles  = watch.watchFiles
global.server      = require "./server"

PROGRAM = path.basename(__filename).split(".")[0]

Tasks = null

HelpTasks = ["help", "?", "-?", "-h", "--h", "--help"]

#-------------------------------------------------------------------------------
exports.execMain = ->
    exec "node #{__filename} #{(process.argv.slice 2).join ' '}"
    process.exit 0

#-------------------------------------------------------------------------------
exports.main = main = (task, args...) ->

    if not test("-f", "jbuild.js") and not test("-f", "jbuild.coffee")
        if task in HelpTasks
            help()
        else
            logError "error: jbuild.js not found in current dir; use `jbuild help` for help"

    # compile the coffee file, to get syntax errrors
    if test "-f", "jbuild.coffee"
        code = cat "jbuild.coffee"

        try
            coffee.compile code,
                compile: true
                output:  "jbuild.coffee.js"

        catch err
            iFile = "jbuild.coffee"
            if err.location.first_line
                iFile = "#{iFile}:#{err.location.first_line}"
                if err.location.first_column
                    iFile = "#{iFile}:#{err.location.first_column}"

            logError "error: syntax error in #{iFile}: #{err}"

        finally
            rm "jbuild.coffee.js" if test "-f", "jbuild.coffee.js"

    # install node_module/.bin scripts
    global.defineModuleFunctions "."

    # load the local jbuild module
    try
        jmod = require "#{path.join process.cwd(), 'jbuild'}"
    catch err
        logError err,  "error: unable to load module ./jbuild: #{err}"

    # get tasks from the module
    Tasks = {}

    for name, taskObj of jmod
        if !_.isFunction taskObj.run
            logError "error: the run property of task #{name} is not a function"

        taskObj.name  = name
        taskObj.doc  ?= "???"

        Tasks[name] = taskObj

    # if no task arg, but there is one task defined, that's the one
    taskNames = _.keys Tasks
    task = Tasks[taskNames[0]].name if !task? and taskNames.length is 1

    # print help if no args, or arg is help, or unknown task
    help() if !task? or task in HelpTasks

    if !Tasks[task]?
        logError "error: unknown task '#{task}'; use `jbuild help` for help"

    # run the task
    try
        Tasks[task].run.apply null, args
    catch err
        logError err,  "running task #{task}"

    return

#-------------------------------------------------------------------------------
global.defineTasks = (exports_, tasksSpec) ->
    tasks = {}

    for name, doc of tasksSpec
        run = getTaskRunner tasks, name
        exports_[name] = {doc, run}

    return tasks

#-------------------------------------------------------------------------------
getTaskRunner = (tasks, name) ->
    (args...) ->
        run = tasks[name]
        unless run?
            logError "task run function for `#{name}` not defined in tasks object"

        run.apply null, args

#-------------------------------------------------------------------------------
global.defineModuleFunctions = (dir) ->
    nodeModulesBin = path.join dir, "node_modules", ".bin"

    scripts = getNodeModulesScripts nodeModulesBin

    for script in scripts
        sanitizedName         = sanitizeFunctionName script
        global[sanitizedName] = invokeNodeModuleScript nodeModulesBin, script

    return

#-------------------------------------------------------------------------------
global.pexec = (command, options, callback) ->
    global.log "the `pexec()` function is deprecated"

    if _.isFunction options and !callback?
        callback = options
        options  = {}

    options ?= {}

    command = "#{path.join 'node_modules', '.bin', command}"

    if _.isFunction callback
        return exec command, options, callback
    else
        return exec command, options

#-------------------------------------------------------------------------------
global.log = (message) ->
    if !message? or message is ""
        console.log ""
    else
        console.log "#{PROGRAM}: #{message}"
    return

#-------------------------------------------------------------------------------
global.logError = (err, message) ->
    if err? and !message?
        message = err
        err     = null

    log message

    if err and err.stack
        console.log "stack:"
        console.log err.stack

    process.exit 1
    return

#-------------------------------------------------------------------------------
invokeNodeModuleScript = (scriptPath, script) ->
    script = "#{script}.cmd" if (process.platform is "win32")

    (commandArgs, execArgs...) ->
        command = "#{path.join scriptPath, script} #{commandArgs}"

        execArgs.unshift command

        exec.apply null, execArgs

#-------------------------------------------------------------------------------
getNodeModulesScripts = (dir) ->
    return [] unless test "-d", dir

    result  = {}
    scripts = ls dir
    for script in scripts
      name = script.split(".")[0]
      result[name] = name

    return _.keys result

#-------------------------------------------------------------------------------
sanitizeFunctionName = (scriptName) ->
    return scriptName.replace(/[^\d\w_$]/g, "_")

#-------------------------------------------------------------------------------
help = ->
    console.log """
        #{PROGRAM} version #{pkg.version}

        usage: #{PROGRAM} task arg arg arg ...

        Run a task from ./jbuild.js or ./jbuild.coffee, passing the
        appropriate args.

        The tasks should be exported from the jsbuild module.
    """

    process.exit 0 if !Tasks?

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

    process.exit 0

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
