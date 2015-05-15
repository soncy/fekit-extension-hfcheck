fs = require 'fs'
uglifycss = require 'uglifycss'
KEYWORDS = ['.q_header', '.qhf_']
STARTWORDS = ['@', 'require', '.', '#']
reg = /\}([\s\S]*?)\{/g
mediaReg = /@media(.*?)\{(.*?)\}(.*?)\}/g
errorMsg = []

exports.check = (filePath) ->
    errorMsg = []
    content = fs.readFileSync(filePath, 'utf-8').toString()
    content = uglifycss.processString(content)
    style = getStyles(content)
    checkStartWord(style.classNames) 
    checkTagName(style.originClass)
    
    return errorMsg

# 获取所有selector
getStyles = (content) ->
    content = parseMediaStyle(content)    
    firstClass = content.substr(0, content.indexOf('{')).split(';')
    
    ret = 
        classNames: {}
        originClass: []

    classNames = content.match(reg)
    if classNames is null
        return ret

    classNames = firstClass.concat(classNames)
    classNames.forEach((item) ->
        item = item.replace('{', '').replace('}', '')
        ret.originClass.push(item)

        arr = item.split(','); # 拆分 .a .b, .c .d
        arr.forEach((cns) ->
            arr1 = cns.split(' '); # 拆分.a .b
            arr1.forEach((cn) ->
                if !ret.classNames[cn] and cn.indexOf('.') is 0
                    ret.classNames[cn] = 1
            )
        )
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


# 检查selector开头是否合规
checkStartWord = (classNames) ->
    ret = yes
    notLegitimateWord = []
    for own item, value of classNames
        if isStrartWithSpecial(item) is yes
            if isStartWithKeyword(item) is yes
                ret = no
                notLegitimateWord.push item

    if ret is no
        errorMsg.push "#{notLegitimateWord.join(',')} 是禁用样式"
    return ret

# 检查selector开头是否合规
isStartWithKeyword = (str) ->
    ret = no
    KEYWORDS.forEach((keyword) ->
        if str.indexOf(keyword) is 0
            ret = yes
    )
    return ret

# 检查标签定义是否有命名空间
checkTagName = (originClass) ->
    ret = yes
    notLegitimateWord = []
    originClass.forEach((styleLine) ->
        arr = styleLine.split(',')
        arr.forEach((style) ->
            k = style.split(' ')
            namespace = k[0]

            for selector in k
                if isStrartWithSpecial(selector) isnt yes
                    if isStrartWithSpecial(namespace) isnt yes
                        notLegitimateWord.push selector
                        ret = no
        )
    )
    if ret is no
        errorMsg.push "#{notLegitimateWord.join(',')}没有命名空间"

isStrartWithSpecial = (str) ->
    ret = no
    for word in STARTWORDS
        if str.indexOf(word) is 0
            return true
    return ret