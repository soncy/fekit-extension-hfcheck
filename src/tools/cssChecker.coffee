css = require 'css'

exports.check = (filePath, content) ->
    console.log css
    console.log(css.parse(content).stylesheet.rules)


createCssTree = () ->
