// Generated by CoffeeScript 1.7.1
(function() {
  var child_process, server;

  child_process = require("child_process");

  server = exports;

  server.start = function(pidFile, program, args, options) {
    if (options == null) {
      options = {};
    }
    server.kill(pidFile, function() {
      var serverProcess;
      if (options.stdio == null) {
        options.stdio = "inherit";
      }
      serverProcess = child_process.spawn(program, args, options);
      return serverProcess.pid.toString().to(pidFile);
    });
  };

  server.kill = function(pidFile, cb) {
    var e, pid;
    if (test("-f", pidFile)) {
      pid = cat(pidFile);
      pid = parseInt(pid, 10);
      rm(pidFile);
      try {
        process.kill(pid);
      } catch (_error) {
        e = _error;
      }
    }
    process.nextTick(function() {
      if (cb != null) {
        return cb();
      }
    });
  };

}).call(this);
