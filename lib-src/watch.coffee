# Licensed under the Apache License. See footer for details.

fs   = require "fs"
path = require "path"

_         = require "underscore"
minimatch = require "minimatch"

#-------------------------------------------------------------------------------
module.exports = watch = ({files, run}) ->

    files = [files] if _.isString files

    if !_.isArray files
        throw Error "watch() argument `files` must be a string or array"

    if !_.isFunction run
        throw Error "watch() argument `run` must be a function"

    runWatch files, run

#-------------------------------------------------------------------------------
runWatch = (fileSpecs, run, fileName, watchers=[]) ->

    return if watchers.tripped

    if fileName?
        log "----------------------------------------------------"
        log "file changed: #{fileName} on #{new Date}" 

    # remove old watchers, indicate the watchers already tripped
    if watchers.length
        for watcher in watchers
            fs.unwatchFile watcher

        watchers.splice 0, watchers.length
        watchers.tripped = true

    # run the user-specified function only when tripped
    if watchers.tripped
        run fileName

    # set up new watchers
    watchFiles = []

    watchFiles = getFiles fileSpecs

    if _.isEmpty watchFiles
        log "no files to watch!"
        return

    watchers = []
    watchers.tripped = false

    options = 
        persistent: true
        interval:   500

    for watchFile in watchFiles
        watchHandler = getWatchHandler fileSpecs, run, watchFile, watchers
        fs.watchFile watchFile, options, watchHandler

        watchers.push watchFile

    log "watching #{watchFiles.length} files for changes ..."

    return

#-------------------------------------------------------------------------------
getFiles = (fileSpecs) ->
    allFiles = ls "-RA", "."

    result = []    
    for fileSpec in fileSpecs
        for file in allFiles
            if minimatch file, fileSpec
                result.push file

    return result

#-------------------------------------------------------------------------------
getWatchHandler = (fileSpecs, run, watchFile, watchers) ->
    return (curr, prev) ->
        return if curr.mtime == prev.mtime

        runWatch fileSpecs, run, watchFile, watchers

        return

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
