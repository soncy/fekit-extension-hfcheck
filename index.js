// Generated by CoffeeScript 1.9.0
(function() {
  var baselib, checkFiles, endHandler, errorsHandler, fileHandler, fs, logger, path, rules, run, utils, walk;

  path = require('path');

  fs = require('fs');

  walk = require('walk');

  baselib = path.join(module.parent.filename, '../');

  utils = require(path.join(baselib, 'util'));

  rules = require('./lib/rules/checkRules');

  logger = utils.logger;

  exports.usage = "检查代码是否和header冲突及合规";

  exports.set_options = function(optimist) {
    return optimist;
  };

  exports.run = function(options) {
    return run();
  };

  run = function() {
    var checkFolder;
    checkFolder = process.argv[3] || 'prd';
    logger.log('check header start');
    return checkFiles(checkFolder);
  };

  checkFiles = function(checkFolder) {
    var needCheckFolder, walker;
    needCheckFolder = path.join(process.cwd(), checkFolder);
    if (path.isAbsolute(checkFolder) === true) {
      needCheckFolder = checkFolder;
    }
    if (fs.existsSync(needCheckFolder) === false) {
      logger.log("no the folder " + needCheckFolder + ", none need check");
      return;
    }
    walker = walk.walk(needCheckFolder, {
      followLinks: false
    });
    walker.on('file', fileHandler);
    walker.on('end', endHandler);
    return walker.on('error', errorsHandler);
  };

  fileHandler = function(root, fileStat, next) {
    var filePath;
    filePath = path.resolve(root, fileStat.name);
    rules.applyRules(filePath);
    return next();
  };

  errorsHandler = function(root, nodeStatsArray, next) {
    nodeStatsArray.forEach(function(n) {
      logger.error("[ERROR] " + n.name);
      return logger.error(n.error.message || (n.error.code + ": " + n.error.path));
    });
    return next();
  };

  endHandler = function() {
    return logger.log('check done');
  };

}).call(this);
