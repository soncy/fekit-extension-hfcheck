fs = require 'fs'
path = require 'path'

requireReg = /require( ?)\((.*)\)/g
importReg = /@import(.*?)[\("'](.*)['"\)]/g

module.exports = (list, folder, callback) ->
    list.forEach((filePath) ->
        filePath = path.join(process.cwd(), folder, filePath)

        if isCssFile(filePath)
            callback(filePath)
            findFilePath(filePath, callback)

        if isLessFile(filePath) or isSassFile(filePath)
            callback(filePath)
    )

findFilePath = (filePath, callback) ->
    dirname = path.dirname(filePath)
    if fs.existsSync(filePath)
        content = fs.readFileSync(filePath, 'utf-8').toString()

        requireList = content.match(requireReg)
        if requireList isnt null
            requireList.forEach((item) ->
                file = item.replace(requireReg, '$2').replace(/["']/g, '')
                childFilePath = path.resolve(dirname, file)
                callback(childFilePath)
                if isCssFile(childFilePath)
                    findFilePath(childFilePath, callback)
            )

        importList = content.match(importReg)
        if importList isnt null
            importList.forEach((item) ->
                file = item.replace(importReg, '$2').replace(/["']/g, '')
                childFilePath = path.resolve(dirname, file)
                callback(childFilePath)
                if isCssFile(childFilePath)
                    findFilePath(childFilePath, callback)
            )

isCssFile = (filePath) ->
    return isSomeTypeFile(filePath, '.css')

isLessFile = (filePath) ->
    return isSomeTypeFile(filePath, '.less')

isSassFile = (filePath) ->
    return isSomeTypeFile(filePath, '.scss')

isSomeTypeFile = (filePath, suffix) ->
    basename = path.basename filePath
    suffix = path.extname basename
    return suffix is suffix
