# 关键词列表，除header外禁止使用

KEYWORDS = [
    '.q_header',
    '.q-header'
]

exports.applyRules = (content) ->
    # 检查禁用关键词
    checkKeywords(content, keyWord) for keyWord in KEYWORDS

    # 检查z-index
    checkZindex(content)

checkKeywords = (content, keyWord) ->
    if ~content.indexOf(keyWord) isnt no
        console.error "#{keyWord} is keyWord"
        return

checkZindex = (content) ->
    