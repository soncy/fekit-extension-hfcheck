# 关键词列表，除header外禁止使用

Promise = require 'Promise'

KEYWORDS = [
    '.q_header',
    '.q-header'
]

exports.applyRules = (filePath, content) ->
    # 检查禁用关键词
    checkKeywords(filePath, content)
    # 检查z-index
    .then(checkZindex)
    # 检查人品
    .then((content) ->
        # console.log(content)
    )
    
# 关键字检查    
checkKeywords = (filePath, content) ->
    promis = new Promise((resolve, reject) ->

        for keyword in KEYWORDS
            if content.indexOf(keyword) <= -1
                console.log "#{filePath} has keyword #{keyword}"
                reject()
                break

        resolve(content)                
    )

    return promis

# z-index检查
checkZindex = (content) ->
    Promise.resolve(content)
    