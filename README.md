jbuild - a JavaScript-based build tool
================================================================================

Another flavor of make, using node.

Install globally via: (sudo not needed for windows)

    sudo npm install -g git://github.com/pmuellr/jbuild

This will install a global command `jbuild`.

`jbuild` expects you to have a `jbuild.js` or `jbuild.coffee` node module 
in the current directory.  The module should export a property for every 
task you want to define for your build.  The property should be an object
with two properties: `doc` which is a single line description of your task,
and `run` which is the function to run when the task is invoked.

When you run `jbuild` with no arguments, it will print some help as well
as the tasks in your `jbuild` module, and the doc entries for those
tasks.

To run a task in your `jbuild` module, invoke `jbuild` with that task as
the first argument.  You can pass further arguments on the command line, and
they will be passed to the task's function.

The shelljs package (<https://github.com/arturadib/shelljs>) is installed
"globally", so that all the functions are available in your module.  For
example, in the example below, the "echo" function is used, which is one of the 
shelljs global functions.

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
        return echo(args.join(" "));
    }
}
```

When you invoke:

    jbuild echo hello world

you will see the following output:

    hello world


additional global functions
--------------------------------------------------------------------------------

`log(message)`

> will write `message` to the console, prefixed by the program name
> prefix.  If you pass an empty string, an blank line will be printed

`logError([err,] message)`

> will write `message` to the console, prefixed by the program name
> prefix.  If `err` is non-null, it will print the error's stack trace.
> The function will then exit the program by calling `process.exit(1)`
> The `err` parameter is optional.

`watch(watchSpec)`

> will watch the files specified in the `watchSpec` argument for 
> changes, and when a change occurs, run the command specified in
> the `watchSpec` argument.  Once the command has completed, the
> files will be watched again, and when a change occurrs, run 
> the command specified.  For ever.  For more information, see
> the section on the `watch(watchSpec)` function.  You can run
> the `watch()` function multiple times, to watch different files
> and act upon them independently.

`server.start(pidFile, program, args[, options])`

> will start `program` with `child_process.spawn(program, args, options)`
> and capture the pid for that process in `pidFile`.  It will also invoke
> `server.kill(pidFile)` before spawning the program.  To be specific,
> `server.kill()` is invoked with a callback which actually spawns the
> program, to give the event queue a chance to breathe between killing
> and respawning a program.

`server.kill(pidFile[, callback])`

> will read the pid from `pidFile`, invoke `process.kill()` on it, and
> then call the `callback` on `process.nextTick()`.

`the watch(watchSpec) global function`
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