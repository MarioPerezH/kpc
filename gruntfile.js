module.exports = function (grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        distFolder: 'dist',
        concat: {
            options: {
                separator: '\n\n'
            },
            kpc: {
                src: ['src/kpc.bat', 'src/**/*.bat'],
                dest: '<%= distFolder %>/kpc.bat'
            }
        },
        clean: {
            all: ['<%= distFolder %>/'],
        },
        replace: {
            kpc: {
                src: ['<%= distFolder %>/kpc.bat'],
                dest: '<%= distFolder %>/kpc.bat',
                replacements: [
                    { from: 'kpc.parameters.bat ', to: ':' },
                    { from: 'kpc.logo.bat ', to: ':' },
                    { from: 'kpc.menu.bat ', to: ':' },
                    { from: 'kpc.config.bat ', to: ':' },
                    { from: 'kpc.utils.bat ', to: ':' },
                    { from: 'kpc.synchronizer.bat ', to: ':' },
                    { from: 'kpc.download.bat ', to: ':' },
                ]
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-text-replace');

    grunt.registerTask('dist', ['clean', 'concat', 'replace']);
};    