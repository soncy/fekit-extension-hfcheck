path = require 'path'

baselib = path.join( module.parent.parent.filename , '../' )
utils = require( path.join( baselib , 'util'  ) )
logger = utils.logger
header = require './header'

rules = [header]

logger.warning = () ->
    msg = Array.prototype.join.call(arguments, '')
    console.log('[WRANING] ' + msg)

exports.applyRules = (filePath) ->
    
    rules.forEach((rule) -> 
        checkResult = rule.check(filePath)
        
        if checkResult.ret is no
            if checkResult.errorMsg
                logger.error "#{filePath} 检测不通过， 错误信息：\n#{checkResult.errorMsg} \n"
            if checkResult.warningMsg
                logger.warning "#{filePath} 检测警告， 警告信息：\n#{checkResult.warningMsg} \n"
    )

    