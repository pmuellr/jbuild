// Generated by CoffeeScript 1.6.3
(function() {
  var fs, getFiles, getWatchHandler, minimatch, path, runWatch, watch, _;

  fs = require("fs");

  path = require("path");

  _ = require("underscore");

  minimatch = require("minimatch");

  module.exports = watch = function(_arg) {
    var files, run;
    files = _arg.files, run = _arg.run;
    if (_.isString(files)) {
      files = [files];
    }
    if (!_.isArray(files)) {
      throw Error("watch() argument `files` must be a string or array");
    }
    if (!_.isFunction(run)) {
      throw Error("watch() argument `run` must be a function");
    }
    return runWatch(files, run);
  };

  runWatch = function(fileSpecs, run, fileName, watchers) {
    var options, watchFile, watchFiles, watchHandler, watcher, _i, _j, _len, _len1;
    if (watchers == null) {
      watchers = [];
    }
    if (watchers.tripped) {
      return;
    }
    if (fileName != null) {
      log("----------------------------------------------------");
      log("file changed: " + fileName + " on " + (new Date));
    }
    if (watchers.length) {
      for (_i = 0, _len = watchers.length; _i < _len; _i++) {
        watcher = watchers[_i];
        fs.unwatchFile(watcher);
      }
      watchers.splice(0, watchers.length);
      watchers.tripped = true;
    }
    if (watchers.tripped) {
      run(fileName);
    }
    watchFiles = [];
    watchFiles = getFiles(fileSpecs);
    if (_.isEmpty(watchFiles)) {
      log("no files to watch!");
      return;
    }
    watchers = [];
    watchers.tripped = false;
    options = {
      persistent: true,
      interval: 500
    };
    for (_j = 0, _len1 = watchFiles.length; _j < _len1; _j++) {
      watchFile = watchFiles[_j];
      watchHandler = getWatchHandler(fileSpecs, run, watchFile, watchers);
      fs.watchFile(watchFile, options, watchHandler);
      watchers.push(watchFile);
    }
    log("watching " + watchFiles.length + " files for changes ...");
  };

  getFiles = function(fileSpecs) {
    var allFiles, file, fileSpec, result, _i, _j, _len, _len1;
    allFiles = ls("-RA", ".");
    result = [];
    for (_i = 0, _len = fileSpecs.length; _i < _len; _i++) {
      fileSpec = fileSpecs[_i];
      for (_j = 0, _len1 = allFiles.length; _j < _len1; _j++) {
        file = allFiles[_j];
        if (minimatch(file, fileSpec)) {
          result.push(file);
        }
      }
    }
    return result;
  };

  getWatchHandler = function(fileSpecs, run, watchFile, watchers) {
    return function(curr, prev) {
      if (curr.mtime === prev.mtime) {
        return;
      }
      runWatch(fileSpecs, run, watchFile, watchers);
    };
  };

}).call(this);