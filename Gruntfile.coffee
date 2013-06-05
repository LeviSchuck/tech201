lrSnippet = require("grunt-contrib-livereload/lib/utils").livereloadSnippet
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    coffee:
      compile:
        options:
          bare: true

        files:
          "www/assets/js/_main.js": "coffee/main.coffee"


    regarde:
      coffee:
        files: ["coffee/*"]
        tasks: ["coffee", "livereload"]

      assets:
        files: ["static/*", "static/*/*", "static/*/*/*"]
        tasks: ["copy", "livereload"]

    copy:
      main:
        files: [
          expand: true
          cwd: "static/"
          src: ["**"]
          dest: "www/"
        ]

    connect:
      
      livereload:
        options:
          port: 8192
          base: "www"
          middleware: (connect, options) ->
            [lrSnippet, mountFolder(connect, options.base)]

  grunt.loadNpmTasks "grunt-contrib-livereload"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-regarde"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.registerTask "default", ["copy", "coffee", "livereload-start", "connect", "regarde"]