const WorkerPlugin = require('worker-plugin');
const NodeTargetPlugin = require('webpack/lib/node/NodeTargetPlugin');

module.exports = (config, options) => {
  config.plugins.forEach((plugin) => {
    if (plugin instanceof WorkerPlugin) {
      plugin.options.plugins.push(new NodeTargetPlugin());
    }
  });

  config.target = 'electron-renderer';
  return config;
};
