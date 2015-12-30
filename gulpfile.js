var gulp = require('gulp')
var gulpLoadPlugins = require('gulp-load-plugins')
var rimraf = require('rimraf')
var plugins = gulpLoadPlugins()

gulp.task('elm-init', plugins.elm.init)

gulp.task('elm', ['elm-init'], function () {
  return gulp.src('src/public/*.elm')
    .pipe(plugins.plumber())
    .pipe(plugins.elm())
    .pipe(gulp.dest('dist/public/'))
})

gulp.task('copy', function () {
  gulp.src('src/public/index.html')
    .pipe(gulp.dest('dist/public'))
  gulp.src('src/public/styles/**')
    .pipe(gulp.dest('dist/public/styles'))
    gulp.src('src/creds.js')
      .pipe(gulp.dest('dist'))
})

gulp.task('js', function () {
  gulp.src('src/**/*.js')
    .pipe(gulp.dest('dist'))
})

gulp.task('clean', function (cb) {
  rimraf('./dist', cb)
})

gulp.task('build', ['copy', 'js', 'elm'])

gulp.task('watch', ['build'], function () {
  gulp.watch('src/**/*.elm', ['elm'])
  gulp.watch(['src/public/index.html', 'src/public/styles/**/*.css'], ['copy'])
  gulp.watch('src/**/*.js', ['js'])
})

gulp.task('default', ['build', 'watch'])
