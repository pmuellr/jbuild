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

    exports.echo =
        doc: "echo's it's arguments to stdout"
        run: (args...) ->
            echo args.join " "

The JavaScript version, `jbuild.js`, would be this:

    exports.echo = {
        doc: "echo's it's arguments to stdout",
        run: function() {
            var args = [].slice.call(arguments)
            return echo(args.join(" "));
        }
    }

When you invoke:

    jbuild echo hello world

you will see the following output:

    hello world

