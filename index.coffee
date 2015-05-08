path = require 'path'
fs = require 'fs'
walk = require 'walk'
rules = require './rules'

exports.usage = ""

exports.set_options = ( optimist ) ->
    return optimist

exports.run = ( options ) ->
    run()

run = () ->
    console.log 'check header start'
    checkFiles()

# 检查文件
checkFiles = () ->
    needCheckFolder = process.cwd() + '/prd/'
    if fs.existsSync(needCheckFolder) is no
        console.log 'no prd, none need check'
        return
    
    walker = walk.walk(needCheckFolder, followLinks: false)
    walker.on('file', fileHandler)
    walker.on('end', endHandler)
    walker.on('error', errorsHandler)

fileHandler = (root, fileStat, next) ->
    filePath = path.resolve(root, fileStat.name)
    scanFile(filePath)
    next()

# 扫描文件
scanFile = (filePath) ->
    rules.applyRules(filePath)

errorsHandler = (root, nodeStatsArray, next) ->
    nodeStatsArray.forEach((n) ->
        console.error("[ERROR] " + n.name)
        console.error(n.error.message or (n.error.code + ": " + n.error.path))
    )
    next()

endHandler = () ->
    console.log 'check done'

run()