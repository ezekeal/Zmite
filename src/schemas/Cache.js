var mongoose = require('mongoose')

var CacheSchema = new mongoose.Schema({
  'method': {type: String},
  'data': {type: Array},
  'timestamp': {type: Date}
})

var Cache = mongoose.model('cache', CacheSchema)

module.exports = Cache
