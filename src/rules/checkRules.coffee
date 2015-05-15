path = require 'path'
header = require './header'

rules = [header]

exports.applyRules = (filePath) ->
    
    fileName = path.basename(filePath)
    suffix = getSuffix(fileName)

    if suffix is 'css'
        rules.forEach((rule) -> 
            ret = rule.check(filePath)
            if ret.length isnt 0
                # console.log filePath
                console.log "\n\n #{filePath} 检测不通过， 原因：\n#{ret.join(;)} \n\n"
        )

getSuffix = (fileName) ->
    arr = fileName.split('.')
    len = arr.length
    if len is 1
        return null
    return arr[len - 1]

    



