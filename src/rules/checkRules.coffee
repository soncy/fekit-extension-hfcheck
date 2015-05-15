path = require 'path'

baselib = path.join( module.parent.parent.filename , '../' )
utils = require( path.join( baselib , 'util'  ) )
logger = utils.logger

header = require './header'

rules = [header]

exports.applyRules = (filePath) ->
    
    rules.forEach((rule) -> 
        checkResult = rule.check(filePath)

        if checkResult.ret is no
            logger.error "#{filePath} 检测不通过， 错误信息：\n#{checkResult.errorMsg} \n"
    )

    