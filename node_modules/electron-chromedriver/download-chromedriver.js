var fs = require('fs')
var path = require('path')
var electronDownload = require('electron-download')
var extractZip = require('extract-zip')

var versionToDownload = require('./package').version

download(versionToDownload, function (err, zipPath) {
  if (err) {
    var versionSegments = versionToDownload.split('.')
    var baseVersion = versionSegments[0] + '.' + versionSegments[1] + '.0'
    download(baseVersion, processDownload)
  } else {
    processDownload(err, zipPath)
  }
})

function download (version, callback) {
  electronDownload({
    version: version,
    chromedriver: true,
    platform: process.env.npm_config_platform,
    arch: process.env.npm_config_arch,
    strictSSL: process.env.npm_config_strict_ssl === 'true',
    quiet: ['info', 'verbose', 'silly', 'http'].indexOf(process.env.npm_config_loglevel) === -1
  }, callback)
}

function processDownload (err, zipPath) {
  if (err != null) throw err
  extractZip(zipPath, {dir: path.join(__dirname, 'bin')}, function (error) {
    if (error != null) throw error
    console.log('successfully dowloaded and extracted!')
    if (process.platform !== 'win32') {
      fs.chmod(path.join(__dirname, 'bin', 'chromedriver'), '755', function (error) {
        if (error != null) throw error
      })
    }
  })
}
