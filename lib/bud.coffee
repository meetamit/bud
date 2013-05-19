path = require 'path'
jade = require 'jade'
fs = require 'fs'

class Bud
  preparePages: (options) ->
    pages = options.pages
    if typeof pages == 'string'
      pages = require path.join process.cwd(), pages
    
    for page in pages
      page.id ?= page.url
      page.partial ?= page.url
    pages
      
  gruntJadeConfig: (options) ->
    pages = @preparePages options
    
    partialsDir = options.partialsDir
    outputDir = options.outputDir
    
    config = {}
    pages.forEach (page) ->
      # partialHtml = ''
      # if page.partial
      #   jade.renderFile "#{partialsDir}/#{page.partial}.jade", 
      #     page: page,
      #     (err, str) ->
      #       throw err if err
      #       partialHtml = str

      config[page.id] =
        options:
          data:
            page: page
            pages: pages
            renderPartial: jade.compile(
              fs.readFileSync("#{partialsDir}/#{page.partial}.jade", 'utf8'), filename: "#{partialsDir}/#{page.partial}.jade"
            )
        files: [
          src: "app/templates/main.jade"
          dest: "#{outputDir}/#{page.url}/index.html"
        ]
    config

module.exports = new Bud