# 关键词列表，除header外禁止使用

Promise = require 'Promise'

KEYWORDS = [
    '.q_header',
    '.q-header'
]

exports.applyRules = (content) ->
    # 检查禁用关键词
    checkKeywords(content)
    # 检查z-index
    .then(checkZindex)
    # 检查人品
    .then(() ->
        console.log 44
    )
    
    

checkKeywords = (content) ->
    promis = new Promise((resolve, reject) ->
        KEYWORDS.forEach((keyWord) ->
            if content.indexOf(keyWord) > -1
                console.error "#{keyWord} is keyWord"
                reject()
            else
                resolve(content)
        )
    )

    return promis

    

checkZindex = (content) ->
    Promise.resolve()
    