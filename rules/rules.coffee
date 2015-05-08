# 关键词列表，除header外禁止使用

KEYWORDS = [
    '.q_header',
    '.q-header'
]


exports.checkProhibited = (content) ->
    checkKeywords(content, keyWord) for keyWord in KEYWORDS


checkKeywords = (content, keyWord) ->
    if ~content.indexOf(keyWord) isnt no
        console.error "#{keyWord} is keyWord"
        return