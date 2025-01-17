import WorkerPlugin from "worker-plugin";
import NodeTargetPlugin from "webpack/lib/node/NodeTargetPlugin.js";

export default (config, options) => {
  config.plugins.forEach((plugin) => {
    if (plugin instanceof WorkerPlugin) {
      plugin.options.plugins.push(new NodeTargetPlugin());
    }
  });
  config.target = "electron-renderer";
  return config;
};
