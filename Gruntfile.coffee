module.exports = (grunt) ->
  SERVER_PORT = 8001
  APP_DIR = 'app'
  DEV_BUILD = 'build/development'
  
  bud = require './lib/bud'

  grunt.initConfig
    clean:
      development: [DEV_BUILD]
    
    copy:
      development:
        files: [
          expand:true
          cwd: "#{APP_DIR}/public"
          src: ['**']
          dest: DEV_BUILD
        ]

    jade: bud.gruntJadeConfig
      pages: './pages'
      partialsDir: "#{APP_DIR}/partials"
      outputDir: DEV_BUILD
    
    coffee:
      development:
        options:
          sourceMap: true
        files: [
          expand: true
          cwd: "coffee"
          dest: "#{DEV_BUILD}/js"
          src: "#{APP_DIR}/**/*.coffee"
          ext: ".js"
        ]
      
    sass:
      development:
        files: [
          src: '#{APP_DIR}/sass/main.scss'
          dest: "#{DEV_BUILD}/css/main.css"
        ]
    
    connect:
      server:
        options:
          hostname: ''
          port: SERVER_PORT
          middleware: (connect, options) -> [
            connect.compress()
            connect.static(DEV_BUILD)
          ]

    watch:
      jade:
        files: ["#{APP_DIR}/templates/*.jade", "#{APP_DIR}/partials/**/*.jade"]
        tasks: ['jade']#, 'templates']
      coffee:
        files: "#{APP_DIR}/coffee/**/*.coffee"
        tasks: 'coffee'
      sass:
        files: "#{APP_DIR}/sass/**/*.scss"
        tasks: 'sass'
    
    simplemocha:
      options:
        ignoreLeaks: false,
        reporter: 'spec'
      all:
        src: 'test/**/*.coffee'
  
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-simple-mocha'
  
  grunt.registerTask 'templates', 'Compile and concatenate Jade templates for client.', -> 
    fs = require 'fs'
    jade = require 'jade'
    
    hash =
      "": "jade/partials"
    
    for templateFileId, templateDir of hash
      tmplFileContents = "define(['jade'], function(jade) {\n"
      tmplFileContents += 'window.JST = {};\n'
      
      for filename in fs.readdirSync templateDir
        path = "#{templateDir}/#{filename}"
        contents = jade.compile(
          fs.readFileSync(path, 'utf8'), { client: true, compileDebug: false, filename: path }
        ).toString()
        tmplFileContents += "JST['#{filename.split('.')[0]}'] = #{contents};\n"
      
      tmplFileContents += 'return JST;\n'
      tmplFileContents += '});\n'
      fs.writeFileSync "#{DEV_BUILD}/js/#{if templateFileId then templateFileId + '.' else ''}templates.js", tmplFileContents
  
  grunt.registerTask 'test', 'Run the tests', ->
    Browser = require 'zombie'
    Browser.default.site = "amitair.local:3000"
    grunt.config.data.connect.server.options.port = 3000
    grunt.task.run ['connect', 'simplemocha']
  
  grunt.registerTask 'default', [
    'clean',
    'copy',
    'jade',
    # 'templates',
    'coffee',
    # 'sass',
    'connect'
    'watch'
  ]
