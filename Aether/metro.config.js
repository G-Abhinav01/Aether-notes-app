const { getDefaultConfig } = require('expo/metro-config');
const path = require('path');

const config = getDefaultConfig(__dirname);

config.resolver.extraNodeModules = {
  ...config.resolver.extraNodeModules,
  buffer: path.resolve(__dirname, 'node_modules/buffer'),
  stream: path.resolve(__dirname, 'node_modules/readable-stream'),
  crypto: path.resolve(__dirname, 'node_modules/crypto-browserify'),
};

config.resolver.nodeModulesPaths = [
  path.resolve(path.join(__dirname, './node_modules')),
];

module.exports = config;