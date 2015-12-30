var mongoose = require('mongoose')

var SessionSchema = new mongoose.Schema({
  'ret_msg': {type: String},
  'session_id': {type: String},
  'timestamp': {type: Date}
})

var Session = mongoose.model('session', SessionSchema)

module.exports = Session

/* using the Schema

var sesseion = new Session({
  'ret_msg': data.ret_msg,
  'session_id': data.session_id,
  'timestamp': Date.parse(data.timestamp)
})

session.save(function(err){})

Session.findOne(query, function(err){})

*/
