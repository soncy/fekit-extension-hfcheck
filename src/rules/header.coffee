fs = require 'fs'
path = require 'path'
uglifycss = require 'uglifycss'
less = require 'less'
sass = require 'node-sass'

KEYWORDS = ['.q_header', '.qhf_', 'q-header', 'qhf-']
reg = /\}([\s\S]*?)\{/g
mediaReg = /@media(.*?)\{(.*?)\}(.*?)\}/g
legitimateStartWord = ['.', '#', '@', 'require']
errorMsg = []

exports.check = (filePath) ->
    errorMsg = []
    fileName = path.basename(filePath)
    suffix = path.extname(fileName)

    switch suffix
        when '.css' then checkCss filePath
        when '.less' then checkLess filePath
        when '.scss' then checkSass filePath

    return {
        ret: errorMsg.length is 0
        errorMsg: errorMsg.join('\n')
    }    

# 检查.css文件
checkCss = (filePath) ->
    content = fs.readFileSync(filePath, 'utf-8').toString()
    content = uglifycss.processString(content)
    styles = getStyles(content)
    checkSelector(styles)

# 检查.less文件
checkLess = (filePath) ->
    content = fs.readFileSync(filePath, 'utf-8').toString()
    less.render(content, (e, output) ->
        con = uglifycss.processString(output.css)
        styles = getStyles(con)
        checkSelector(styles)
    )

# 检查.sass文件
checkSass = (filePath) ->
    content = fs.readFileSync(filePath, 'utf-8').toString()
    result = sass.renderSync({
        file: filePath
    })
    con = uglifycss.processString(result.css.toString())
    styles = getStyles(con)
    checkSelector(styles)


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

# 是否是tagName
isTagName = (str) ->
    ret = yes
    legitimateStartWord.forEach((word) ->
        if str.indexOf(word) is 0 or str.split('.').length > 1
            ret = no
    )
    return ret
