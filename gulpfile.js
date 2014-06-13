var gulp    = require("gulp")
var clean   = require("gulp-clean");

var coffee  = require("gulp-coffee");

var mocha   = require("gulp-mocha")

paths = {
  test: "./test/",
  lib: "./lib/",
  src: "./src/"
}

gulp.task("default", ["build"])

gulp.task("clean", function() {
  return gulp.src(paths.lib, {read: false})
    .pipe(clean())
})

gulp.task("build", ["clean"], function() {
  return gulp.src(paths.src + "*.coffee")
    .pipe(coffee())
    .pipe(gulp.dest(paths.lib))
})

gulp.task("test", function() {
  require("coffee-script/register");

  return gulp.src("test/*.test.coffee")
    .pipe(mocha({
      reporters: "list"
    }))
})

gulp.task("watch:test", function() {
  gulp.watch([paths.test + "**/*", paths.src + "**/*"], ["test"])
})