module.exports = (grunt) ->

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-jshint')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-mocha-test')

  grunt.initConfig

    jshint:
      options:
        jshintrc: '.jshintrc'
      files: ['jquery.circular.js']

    coffee:
      compile:
        files:
          'jquery.circular.js': 'src/circular.coffee',

    mochaTest:
      test:
        options:
          reporter: 'spec'
          clearRequireCache: true # play well with `grunt watch`
          require: 'coffee-script'
        src: ['test/**/*.coffee']

    watch:
      files: ['src/circular.coffee', 'test/**/*.coffee']
      tasks: ['check', 'test']

  grunt.registerTask('check', ['coffee', 'jshint'])
  grunt.registerTask('test', 'mochaTest')
  grunt.registerTask('default', 'watch')
