rules = require './rules.coffee'

fs = require 'fs'
Promise = require('promise')
readFile = Promise.denodeify(fs.readFile)

exports.applyRules = (filePath) ->
    # 检查禁用关键词和禁用写法
    
    readFile(filePath, 'utf-8').then((data) ->
        rules.checkProhibited(data.toString())
    )