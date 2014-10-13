module.exports = (grunt) ->
  buildPlatforms = parseBuildPlatforms(grunt.option('platforms'))
  packageJson = grunt.file.readJSON('package.json')
  _VERSION = packageJson.version
  grunt.log.writeln 'Building ' + packageJson.version


  grunt.initConfig
    clean: ['build/releases/**']

    coffee:
      compileBare:
        options:
          bare: true
        files:
          'js/main.js': ['coffee/main.coffee', 'coffee/_*.coffee']

    sass:
      dist:
        options:
          style: 'expanded'
        files:
          'css/main.css': 'sass/main.sass'

    shell:
      runnw:
        options:
          stdout: true
        command: [ '/build/cache/mac/0.9.2/node-webkit.app/Contents/MacOS/node-webkit --debug' , '\\build\\cache\\win\\0\.9\.2\\nw.exe --debug' ].join('&')

    'regex-replace':
      windows_installer:
        src: ['dist/win/windows-installer.iss']
        actions:
          name: 'version'
          search: '#define AppVersion "[\.0-9]+"'
          replace: '#define AppVersion "' + _VERSION + '"'

    nodewebkit:
      options:
        build_dir: './build'
        mac_icns: './images/icon.icns'
        mac: buildPlatforms.mac
        win: buildPlatforms.win
        linux32: buildPlatforms.linux32
        linux64: buildPlatforms.linux64
      src: ['./css/**', './fonts/**', './images/**', './tpl/**', './js/**', './l10n/**', './node_modules/**', '!./node_modules/grunt*/**', './index.html', './package.json']


    compress:
      linux32:
        options:
          mode: 'tgz'
          archive: 'build/releases/piratebay-downloader/linux32/piratebay-downloader-' + _VERSION + '.tgz'
        expand: true
        cwd: 'build/releases/piratebay-downloader/linux32/'
        src: '**'
      linux64:
        options:
          mode: 'tgz'
          archive: 'build/releases/piratebay-downloader/linux64/piratebay-downloader-' + _VERSION + '.tgz'
        expand: true
        cwd: 'build/releases/piratebay-downloader/linux64/'
        src: '**'



  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-shell'
  grunt.loadNpmTasks 'grunt-regex-replace'
  grunt.loadNpmTasks 'grunt-node-webkit-builder'
  grunt.loadNpmTasks 'grunt-contrib-compress'

  grunt.registerTask 'default', ['sass', 'coffee']
  grunt.registerTask 'nodewkbuild', ['nodewebkit']
  grunt.registerTask 'run', ['default', 'shell:runnw']
  grunt.registerTask 'build', ['default', 'clean', 'regex-replace', 'nodewkbuild']

parseBuildPlatforms = (argumentPlatform) ->

  # this will make it build no platform when the platform option is specified
  # without a value which makes argumentPlatform into a boolean
  inputPlatforms = argumentPlatform or process.platform + ';' + process.arch

  # Do some scrubbing to make it easier to match in the regexes bellow
  inputPlatforms = inputPlatforms.replace('darwin', 'mac')
  inputPlatforms = inputPlatforms.replace(/;ia|;x|;arm/, '')
  buildAll = /^all$/.test(inputPlatforms)
  buildPlatforms =
    mac: /mac/.test(inputPlatforms) or buildAll
    win: /win/.test(inputPlatforms) or buildAll
    linux32: /linux32/.test(inputPlatforms) or buildAll
    linux64: /linux64/.test(inputPlatforms) or buildAll

  buildPlatforms