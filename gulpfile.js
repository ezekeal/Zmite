var gulp = require('gulp')
var gulpLoadPlugins = require('gulp-load-plugins')
var plugins = gulpLoadPlugins()

gulp.task('elm-init', plugins.elm.init)

gulp.task('elm', ['elm-init'], function () {
  return gulp.src('src/*.elm')
    .pipe(plugins.plumber())
    .pipe(plugins.elm())
    .pipe(gulp.dest('dist/'))
})

gulp.task('copy', ['clean'], function () {
  gulp.src('src/index.html')
    .pipe(gulp.dest('dist/index.html'))
  gulp.src('src/styles/**')
    .pipe(gulp.dest('dist/styles'))
})

gulp.task('clean', function () {
  plugins.rimraf('./dist')
})

gulp.task('build', ['copy', 'elm'])

gulp.task('watch', function () {
  gulp.watch('src/**/*.elm', ['elm'])
  gulp.watch(['src/index.html', 'src/styles/**/*.css'], ['copy'])
})

gulp.task('default', ['build', 'watch'])
