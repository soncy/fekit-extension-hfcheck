path = require 'path'
fs = require 'fs'
walk = require 'walk'

baselib = path.join( module.parent.filename , '../' )
utils = require( path.join( baselib , 'util'  ) )
rules = require './lib/rules/checkRules'
logger = utils.logger

exports.usage = "检查代码是否和header冲突及合规"

exports.set_options = ( optimist ) ->
    return optimist

exports.run = ( options ) ->
    run()

run = () ->
    checkFolder = process.argv[3] or 'prd'
    logger.log 'check header start'
    checkFiles(checkFolder)

# 检查文件
checkFiles = (checkFolder) ->
    needCheckFolder = path.join(process.cwd(), checkFolder)

    if path.isAbsolute(checkFolder) is yes
        needCheckFolder = checkFolder

    if fs.existsSync(needCheckFolder) is no
        logger.log "no the folder #{needCheckFolder}, none need check"
        return
    
    walker = walk.walk(needCheckFolder, followLinks: false)
    walker.on('file', fileHandler)
    walker.on('end', endHandler)
    walker.on('error', errorsHandler)

fileHandler = (root, fileStat, next) ->
    filePath = path.resolve(root, fileStat.name)
    rules.applyRules(filePath)
    next()

errorsHandler = (root, nodeStatsArray, next) ->
    nodeStatsArray.forEach((n) ->
        logger.error("[ERROR] " + n.name)
        logger.error(n.error.message or (n.error.code + ": " + n.error.path))
    )
    next()

endHandler = () ->
    logger.log 'check done'

