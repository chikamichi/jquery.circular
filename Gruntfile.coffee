module.exports = (grunt) ->

  grunt.initConfig
    jshint:
      options:
        jshintrc: '.jshintrc'
      files: ['jquery.circular.js']
    coffee:
      compile:
        files:
          'jquery.circular.js': 'src/circular.coffee',

  grunt.loadNpmTasks('grunt-contrib-jshint')
  grunt.loadNpmTasks('grunt-contrib-coffee')

  grunt.registerTask('test', 'jshint')
  grunt.registerTask('default', 'test')
