fs = require 'fs'
path = require 'path'

requireReg = /require( ?)\((.*)\)/g
importReg = /@import(.*?)[\("'](.*)['"\)]/g

listCache = {}

module.exports = (list, folder, callback) ->
    list.forEach((filePath) ->
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
                    childFilePath = path.resolve(dirname, file)
                    if isCssFile(childFilePath) and listCache[childFilePath] isnt 1
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

isSomeTypeFile = (filePath, suffix) ->
    basename = path.basename filePath
    currentSuffix = path.extname basename
    return currentSuffix is suffix
