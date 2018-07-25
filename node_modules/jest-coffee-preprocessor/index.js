module.exports = {
  process: function (src, path) {
    var coffee = require('coffee-script')
    if (coffee.helpers.isCoffee(path)) {
      return coffee.compile(src, {
        'bare': true,
        'inlineMap': true
      })
    }
    return null
  }
}
