jbuild - a JavaScript-based build tool
================================================================================

A build tool where tasks are defined in JavaScript (or CoffeeScript).

Install globally via: (sudo not needed for windows)

    sudo npm -g install jbuild

This will install a global command `jbuild`.

`jbuild` expects you to have a `jbuild.js` or `jbuild.coffee` node module in the
current directory.  This module defines the tasks that you want to run, and is a
node module like any other, so you can `require()` other modules if you need to.

Tasks are defined by exporting named objects from the module, where the objects
contains both a short documentation string, and the function invoked when the
task is run.

For example, the following code in `jbuild.coffee` exports two tasks:

```coffee
exports.build =
    doc: "build the code"
    run: -> build()  # a build() function defined elsewhere

exports.test =
    doc: "test the code"
    run: -> test() # a test() function defined elsewhere
```

You can also define tasks using the `defineTasks()` function described below.

To invoke a task in your `jbuild` file, run the global `jbuild` command, passing
the name of the task to run.  You can also pass arguments to the task.

For example, the following task in `jbuild.coffee` will echo it's arguments:

```coffee
exports.echo =
    doc: "echo's it's arguments to stdout"
    run: (args...) ->
        console.log args.join " "
```

When invoked as `jbuild echo 1 2 3`, you'll see `1 2 3` printed to stdout.

When you run `jbuild` with no arguments, it will do one of two things, depending
on how many tasks are defined (exported) from your module.

* When only one task is defined in a module, that task will be run.

* Otherwise, some help will be printed, as well as the tasks in your `jbuild`
  module, and the doc entries for those tasks.

You can always run `jbuild help` to see all the defined tasks.

The shelljs package (<https://github.com/arturadib/shelljs>) is installed
"globally", so that all the functions are available in your module.  For
example, in the example below, the "echo" function is used, which is one of the
shelljs global functions.  This task does the same thing as the `echo` task
defined above.

```coffee
exports.echo =
    doc: "echo's it's arguments to stdout"
    run: (args...) ->
        echo args.join " "
```

A handful of additional "global" functions are provided by jbuild, for your
tasks, as described below.

In addition, `jbuild` will define "global" functions for all the scripts in your
`node_modules/.bin` directory.  The functions will be defined exactly like
[shelljs's `exec()` function][1]. Some example invocations for a script
`node_modules/.bin/foop`, from CoffeeScript:

    # run `foop` in with args "1 2 3", sync, output to stdout
    foop "1 2 3"

    # run `foop` in with args "4", async, capturing code and output when done
    foop "4", silent:true, (code,output) -> console.log output



example
--------------------------------------------------------------------------------

contents of a `jbuild.coffee` file

```coffee
exports.echo =
    doc: "echo's it's arguments to stdout"
    run: (args...) ->
        echo args.join " "
```

The JavaScript version, `jbuild.js`, would be this:

```js
exports.echo = {
    doc: "echo's it's arguments to stdout",
    run: function() {
        var args = [].slice.call(arguments)
        echo(args.join(" "));
    }
}
```

When you invoke:

    jbuild echo hello world

you will see the following output:

    hello world



additional global functions
--------------------------------------------------------------------------------

In addition to the shelljs functions and node_modules/.bin scripts available
globally (as described above), the following functions are available globally.



###`log(message)`

will write `message` to the console, prefixed by the program name prefix.  If
you pass an empty string, an blank line will be printed



###`logError([err,] message)`

will write `message` to the console, prefixed by the program name prefix.  If
`err` is non-null, it will print the error's stack trace. The function will then
exit the program by calling `process.exit(1)`.

The `err` parameter is optional.



###`watch(watchSpec)`

will watch the files specified in the `watchSpec` argument for changes, and when
a change occurs, run the command specified in the `watchSpec` argument.  Once
the command has completed, the files will be watched again, and when a change
occurrs, run the command specified.  For ever.

`watchSpec` is an object with two properties:

* `files` - a string or array of strings of wildcard file specification of
  files to watch for changes

* `run` - a function which will be invoked when a file changes

The wildcard file specifications can contain
[minimatch](https://github.com/isaacs/minimatch) wildcards, which will be
compared to all the files in the current directory.  The comparison is against
the path relative to the current directory, so the files arguments must not
contain path entries above the current directory.  For example, you can't use
`__filename` as an argument, as that variable is a fully qualified filename. Use
`path.basename(__filename)` instead.

The `run` property is the function to run when a file changes. It will be passed
the first file name that was noticed to have changed.  Once one file has been
noticed to change, the file watching is stopped, the command is run, and then
file watching begins again.  Specifically, the `run` function will not be called
for every file that changes.

You can run the `watch()` function multiple times, to watch different files and
act upon them independently.



###`watchFiles(watchFilesSpec)`

will invoke the `watch()` function, but takes a slightly different argument.

`watchFiles()` expects an object where the keys are the files to watch and the
value associated with the key is the function to run.  The keys are space-
separated lists of the same file specifications that the `watch()` function
supports.

This code using `watchFiles()`:

```coffee
watchFiles
    "src/*.coffee src/*.js" : -> build()
    "out/*"                 : -> test()
```

is exactly the same as this code using `watch()`:

```coffee
watch
    files: ["src/*.coffee", "src/*.js"]
    run:   -> build()

watch
    files: "out/*"
    run:   -> test()
```



###`server.start(pidFile, program, args[, options])`

will create a new process with `child_process.spawn(program, args, options)` and
capture the pid for that process in the file named by the `pidFile` argument.
It will also invoke `server.kill(pidFile)` before spawning the program.

Specifically, when you invoke `server.start()`, `server.kill()` is invoked with
a callback which actually spawns the program, to give the event queue a chance
to breathe between killing and respawning a program.



###`server.kill(pidFile[, callback])`

will read the pid from the file named by the `pidFile` argument, invoke
`process.kill()` on it, and then call the `callback` on `process.nextTick()`.

Since `server.kill()` is invoked by `server.start()`, in most cases you'll
never need to invoke this function.

No error will be printed or thrown if the specified process isn't found, or
if the pidFile does not exist.



###`defineTasks(exports, tasksSpec)`

provides an alternative to defining your tasks as objects exported from your
module with `doc` and `run` properties.

The `exports` argument should be the object which exports properties from your
module.  Typically you'd just pass in the `exports` object provided to your
module, but if you're making use of `module.exports`, you may need to pass that.

The `tasksSpec` argument should be an object where the keys are the name of the
tasks, and the values of those keys are what you would use in the `doc` property
when defining tasks.

The `defineTasks()` function will return an object which you should add the
`run` functions to, using the same key that you used in the `tasksSpec`
argument.

This code using `defineTasks()`

```coffee
tasks = defineTasks exports,
    build:  "build the code"
    test:   "test the code"

tasks.build = -> build()
tasks.test  = -> test()
```

is exactly the same as this code defining the tasks as exports

```coffee
exports.build =
    doc: "build the code"
    run: -> build()

exports.test =
    doc: "test the code"
    run: -> test()
```

You can mix-and-match the two styles of defining tasks.  The `defineTasks()`
function just adds tasks specifications to the exports object passed in.



###`runTask(taskName, arg...)`

**(dreamcode; not yet defined)**

Runs the specified task, passing optional arguments.



task methods
--------------------------------------------------------------------------------

**(dreamcode; not yet defined)**

When a watch function or task function is run, the `this` available in the
function is a task object.  Task objects have the following properties and
methods available:



###`name`

the name of the task.  Note that watch functions' name will be null.



###`async()`

Similar to the
[grunt `async()` task method](http://gruntjs.com/api/inside-tasks#this.async).

Watch and task and functions are assumed to be run synchronously.  If you need
to run parts of your watch and task functions asynchronously, you will need
to use the `async()` method.

The `async()` method notifies `jbuild` that the task completion is not
indicated by the return of the function, but manually by the function.  The
method returns a "done" function which should be invoked when
the task is complete.

This task will write "function done" to the stdout, wait two seconds, write
"task done" to the console, and is then considered done.

```coffee
tasks.echoAndWait = ->
    done = @async()

    whenDone = ->
        echo "task done"
        done()

    setTimeout whenDone, 2000

    echo "function done"
```

<!-- references -->

[1]: https://github.com/arturadib/shelljs#execcommand--options--callback

