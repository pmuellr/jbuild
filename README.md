jbuild - a JavaScript-based build tool
================================================================================

Another flavor of make, using node.

Install globally via: (sudo not needed for windows)

    sudo npm -g install jbuild

This will install a global command `jbuild`.

`jbuild` expects you to have a `jbuild.js` or `jbuild.coffee` node module
in the current directory.  The module should export a property for every
task you want to define for your build.  The property should be an object
with two properties: `doc` which is a single line description of your task,
and `run` which is the function to run when the task is invoked.

When you run `jbuild` with no arguments, it will do one of two things,
depending on how many tasks are defined (exported) from your module.

* When only one task is defined in a module, that task will be run.

* Otherwise, some help will be printed, as well
  as the tasks in your `jbuild` module, and the doc entries for those
  tasks.

To run a task in your `jbuild` module, invoke `jbuild` with that task as
the first argument.  You can pass further arguments on the command line, and
they will be passed to the task's function.

The shelljs package (<https://github.com/arturadib/shelljs>) is installed
"globally", so that all the functions are available in your module.  For
example, in the example below, the "echo" function is used, which is one of the
shelljs global functions.

A handful of additional "global" functions are provided by jbuild,
for your tasks, as described below.

In addition, jbuild will define "global" functions for all the scripts in
your `node_modules/.bin` directory.  The functions will be defined
exactly like [shelljs's `exec()` function][1]. Some example invocations 
for a script `node_modules/.bin/foop`, from CoffeeScript:

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

###`log(message)`

will write `message` to the console, prefixed by the program name
prefix.  If you pass an empty string, an blank line will be printed

###`logError([err,] message)`

will write `message` to the console, prefixed by the program name
prefix.  If `err` is non-null, it will print the error's stack trace.
The function will then exit the program by calling `process.exit(1)`.

The `err` parameter is optional.

###`watch(watchSpec)`

will watch the files specified in the `watchSpec` argument for
changes, and when a change occurs, run the command specified in
the `watchSpec` argument.  Once the command has completed, the
files will be watched again, and when a change occurrs, run
the command specified.  For ever.

For more information, see
the section on the `watch(watchSpec)` function.  You can run
the `watch()` function multiple times, to watch different files
and act upon them independently.

###`server.start(pidFile, program, args[, options])`

will create a new process with `child_process.spawn(program, args, options)`
and capture the pid for that process in `pidFile`.  It will also invoke
`server.kill(pidFile)` before spawning the program.

To be specific,
`server.kill()` is invoked with a callback which actually spawns the
program, to give the event queue a chance to breathe between killing
and respawning a program.

###`server.kill(pidFile[, callback])`

will read the pid from `pidFile`, invoke `process.kill()` on it, and
then call the `callback` on `process.nextTick()`.

###`pexec(command, options, callback)`

will call [shelljs's `exec()` function][1]
with `command` prefixed with `"node_modules/.bin"`, which allows you easily
call binaries installed with npm package dependencies.


the `watch(watchSpec)` global function
--------------------------------------------------------------------------------

The global `watch()` function takes a single argument `watchSpec`.
`watchSpec` should be an object with two properties:

* `files` - a wild-card enabled file specification of files to watch
  for changes

* `run` - a function which will be invoked when a file changes

The `files` property must be a string or array of strings which
can contain [minimatch](https://github.com/isaacs/minimatch)
wildcards, which will be compared to all the files in the
current directory.  The comparison is against the path relative
to the current directory, so the files arguments must not
contain path entries above the current directory.  For example,
you can't use `__filename` as an argument, as that variable
is a fully qualified filename.  Use `path.basename(__filename)`
instead.

The `run` property is the function to run when a file changes.
It will be passed the first file name that was noticed to
have changed.  Once one file has been noticed to change,
the file watching is stopped, the command is run, and then
file watching begins again.  Specifically, the `run` function
will not be called for every file that changes.

<!-- references -->

[1]: https://github.com/arturadib/shelljs#execcommand--options--callback

