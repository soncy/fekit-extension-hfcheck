fs = require 'fs'
path = require 'path'

requireReg = /require( ?)\((.*)\)/g
importReg = /@import(.*?)[\("'](.*)['"|\)]/g

listCache = {}
alias = {}

module.exports = (fekitConfig, folder, callback) ->

    list = fekitConfig.export
    alias = fekitConfig.alias

    list.forEach((filePath) ->
        if filePath.path
            filePath = filePath.path

        filePath = path.join(process.cwd(), folder, filePath)

        if isCssFile(filePath)
            callback(filePath)
            findFilePath(filePath, callback)

        if isLessFile(filePath) or isSassFile(filePath)
            callback(filePath)

        listCache[filePath] = 1
    )

findFilePath = (filePath, callback) ->
    dirname = path.dirname(filePath)
    if fs.existsSync(filePath)
        content = fs.readFileSync(filePath, 'utf-8').toString()

        findChildList = (reg) ->
            list = content.match(reg)
            if list isnt null
                list.forEach((item) ->
                    file = item.replace(reg, '$2').replace(/["']/g, '')
                    folders = file.split('/')

                    firstFolder = folders[0]

                    if alias[firstFolder]
                        folders[0] = alias[firstFolder]
                        childFilePath = ''
                        folders.forEach((f) ->
                            childFilePath = path.join(childFilePath, f)
                        )
                    else
                        childFilePath = path.resolve(dirname, file)
                    if (isCssFile(filePath) and !isBeginWithTouch(childFilePath)) and listCache[childFilePath] isnt 1
                        callback(childFilePath)
                        listCache[childFilePath] = 1
                        findFilePath(childFilePath, callback)
                )

        findChildList(requireReg)
        findChildList(importReg)

isCssFile = (filePath) ->
    return isSomeTypeFile(filePath, '.css')

isLessFile = (filePath) ->
    return isSomeTypeFile(filePath, '.less')

isSassFile = (filePath) ->
    return isSomeTypeFile(filePath, '.scss')

isBeginWithTouch = (filePath) ->
    basename = path.basename filePath
    return basename.indexOf('touch-reset') is 0

isSomeTypeFile = (filePath, suffix) ->
    basename = path.basename filePath
    currentSuffix = path.extname basename
    return currentSuffix is suffix
