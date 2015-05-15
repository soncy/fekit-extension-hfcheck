FEKIT header合规检查
=====================

### 检查规则 ###

* 不能使用.q-header,.qhf-,.q_header,.qhf_开头的class定义
* 定义标签的样式必须要有命名空间，不允许直接定义标签样式


### 安装 ###
	
	npm install fekit-extension-hfcheck -g

mac 用户需要在`~/.fekit/.extensions/`目录下新增`hfcheck.js`，内容如下：
	
	exports.version = '0.0.1';
	exports.path = '/usr/local/lib/node_modules/fekit-extension-hfcheck/index.js';

### 使用 ###
	
	fekit hfcheck 目录(如src)

### 联系 ###
song.chen@qunar.com, congxue.zhang@qunar.com