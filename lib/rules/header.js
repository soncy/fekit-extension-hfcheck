var KEYWORDS, checkCss, checkLess, checkSass, checkSelector, errorMsg, fs, getStyles, isBeginwithRoot, isStartWithKeyword, isTagName, legitimateStartWord, less, mediaReg, parseMediaStyle, path, reg, sass, uglifycss, warningMsg;

fs = require('fs');

path = require('path');

uglifycss = require('uglifycss');

less = require('less');

sass = require('node-sass-china');

KEYWORDS = ['.q_header', '.qhf_', 'q-header', 'qhf-'];

reg = /\}([\s\S]*?)\{/g;

mediaReg = /@(.*?)\{(.*?)\}\}/g;

legitimateStartWord = ['.', '#', '@', 'require', '::'];

errorMsg = [];

warningMsg = [];

exports.check = function(filePath) {
  var fileName, suffix;
  errorMsg = [];
  warningMsg = [];
  fileName = path.basename(filePath);
  suffix = path.extname(fileName);
  switch (suffix) {
    case '.css':
      checkCss(filePath);
      break;
    case '.less':
      checkLess(filePath);
      break;
    case '.scss':
      checkSass(filePath);
  }
  return {
    ret: errorMsg.length === 0 && warningMsg.length === 0,
    errorMsg: errorMsg.join('\n'),
    warningMsg: warningMsg.join('\n')
  };
};

checkCss = function(filePath) {
  var content, styles;
  content = fs.readFileSync(filePath, 'utf-8').toString();
  content = uglifycss.processString(content);
  styles = getStyles(content);
  return checkSelector(styles);
};

checkLess = function(filePath) {
  var content;
  content = fs.readFileSync(filePath, 'utf-8').toString();
  return less.render(content, function(e, output) {
    var con, styles;
    con = uglifycss.processString(output.css);
    styles = getStyles(con);
    return checkSelector(styles);
  });
};

checkSass = function(filePath) {
  var con, content, result, styles;
  content = fs.readFileSync(filePath, 'utf-8').toString();
  result = sass.renderSync({
    file: filePath
  });
  con = uglifycss.processString(result.css.toString()).replace('@charset "UTF-8";', '');
  styles = getStyles(con);
  return checkSelector(styles);
};

getStyles = function(content) {
  var classNames, firstClass, ret;
  content = parseMediaStyle(content);
  firstClass = content.substr(0, content.indexOf('{')).split(';');
  ret = [];
  classNames = content.match(reg);
  if (classNames === null) {
    return ret;
  }
  classNames = firstClass.concat(classNames);
  classNames.forEach(function(item) {
    item = item.replace(/\{/g, '').replace(/\}/g, '');
    return ret.push(item);
  });
  return ret;
};

parseMediaStyle = function(content) {
  return content.replace(mediaReg, '');
};

checkSelector = function(styles) {
  var illegalSelector, illegalTagName;
  illegalSelector = [];
  illegalTagName = [];
  styles.forEach(function(styleLine) {
    return styleLine.split(',').forEach(function(selectorLine) {
      var namespace, selectors;
      selectors = selectorLine.split(' ');
      namespace = selectors[0];
      if (isBeginwithRoot(selectorLine)) {
        namespace = selectors[1] || selectors[0];
      }
      return selectors.forEach(function(selector) {
        var isTag, keyWordResult, namespaceIsTagName;
        keyWordResult = isStartWithKeyword(selector);
        isTag = isTagName(selector);
        if (keyWordResult === true) {
          illegalSelector.push(selector);
        }
        if (isTag === true) {
          namespaceIsTagName = isTagName(namespace);
        }
        if (namespaceIsTagName === true) {
          return illegalTagName.push(selector);
        }
      });
    });
  });
  illegalSelector.length > 0 && errorMsg.push((illegalSelector.join(',')) + "是禁用样式");
  return illegalTagName.length > 0 && warningMsg.push((illegalTagName.join(',')) + "没有命名空间，请尽快完成修改");
};

isStartWithKeyword = function(selector) {
  var ret;
  ret = false;
  KEYWORDS.forEach(function(keyword) {
    if (selector.indexOf(keyword) === 0) {
      return ret = true;
    }
  });
  return ret;
};

isTagName = function(str) {
  var ret;
  ret = true;
  legitimateStartWord.forEach(function(word) {
    if (str.indexOf(word) === 0 || str.split('.').length > 1) {
      return ret = false;
    }
  });
  return ret;
};

isBeginwithRoot = function(str) {
  return str.indexOf(':root') === 0;
};
