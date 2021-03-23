const WorkerPlugin = require('worker-plugin');
const NodeTargetPlugin = require('webpack/lib/node/NodeTargetPlugin');

module.exports = (config, options) => {
  let workerPlugin = config.plugins.find(p => p instanceof WorkerPlugin);
  if (workerPlugin) {
    workerPlugin.options.plugins.push(new NodeTargetPlugin());
  }
	config.target = 'electron-renderer';
  return config;
};