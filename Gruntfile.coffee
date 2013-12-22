module.exports = (grunt) ->

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-jshint')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-mocha-cov')

  grunt.initConfig

    pkg: grunt.file.readJSON('package.json')

    jshint:
      options:
        jshintrc: '.jshintrc'
      files: ['jquery.circular.js']

    coffee:
      compile:
        files:
          'jquery.circular.js': 'src/circular.coffee'
          'build/circular.js': 'src/circular.coffee'

    mochacov:
      coverage:
        options:
          coveralls:
            serviceName: 'travis-ci'
            repoToken: 'EPwLMGsbXbKvvVk9hGRSTK0CY2ueNZsEr'
      test:
        options:
          reporter: 'spec'
      options:
        compilers: ['coffee:coffee-script']
        files: ['test/**/*.coffee']

    watch:
      files: ['src/circular.coffee', 'test/**/*.coffee']
      tasks: ['check', 'test']

  grunt.registerTask('check', ['coffee', 'jshint'])
  grunt.registerTask('test', 'mochacov:test')

  grunt.registerTask('default', 'watch')
  grunt.registerTask('travis', ['check', 'mochacov:coverage'])
