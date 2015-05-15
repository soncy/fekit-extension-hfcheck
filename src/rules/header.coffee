fs = require 'fs'
uglifycss = require 'uglifycss'
KEYWORDS = ['.q_header', '.qhf_']
reg = /\}([\s\S]*?)\{/g
mediaReg = /@media(.*?)\{(.*?)\}(.*?)\}/g
legitimateStartWord = ['.', '#', '@', 'require']
errorMsg = []

exports.check = (filePath) ->
    errorMsg = []
    content = fs.readFileSync(filePath, 'utf-8').toString()
    content = uglifycss.processString(content)
    styles = getStyles(content)
    checkSelector(styles)
    
    return errorMsg

# 获取所有selector
getStyles = (content) ->
    content = parseMediaStyle(content)    
    firstClass = content.substr(0, content.indexOf('{')).split(';')
    
    ret = []

    classNames = content.match(reg)
    if classNames is null
        return ret

    classNames = firstClass.concat(classNames)
    classNames.forEach((item) ->
        item = item.replace('{', '').replace('}', '')
        ret.push(item)
    )
    return ret

# 获取media中的样式
parseMediaStyle = (content) ->
    mediaStyles = content.match(mediaReg)
    if mediaStyles isnt null
        for media in mediaStyles
            firstLeftBrace = media.indexOf('{')
            lastRightBrace = media.lastIndexOf('}')
            content = content.replace(media, media.substring(firstLeftBrace + 1, lastRightBrace))
    content = content.replace(/@(.*?);/g, '')
    return content

checkSelector = (styles) ->

    illegalSelector = []
    illegalTagName = []

    styles.forEach((styleLine) ->
        styleLine.split(',').forEach((selectorLine) ->
            selectors = selectorLine.split(' ')
            namespace = selectors[0]

            selectors.forEach((selector) ->
                keyWordResult = isStartWithKeyword(selector)
                isTag = isTagName(selector)

                if keyWordResult is yes
                    illegalSelector.push(selector)

                if isTag is yes
                    namespaceIsTagName = isTagName(namespace)

                if namespaceIsTagName is yes
                    illegalTagName.push(selector)
            )
        )
    )

    illegalSelector.length > 0 and errorMsg.push("#{illegalSelector.join(',')}是禁用样式")
    illegalTagName.length > 0 and errorMsg.push("#{illegalTagName.join(',')}没有命名空间")

# 检查selector开头是否合规
isStartWithKeyword = (selector) ->
    ret = no
    KEYWORDS.forEach((keyword) ->
        if selector.indexOf(keyword) is 0
            ret = yes
    )
    return ret

isTagName = (str) ->
    ret = yes
    legitimateStartWord.forEach((word) ->
        if str.indexOf(word) is 0
            ret = no
    )
    return ret
