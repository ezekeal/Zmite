const express = require('express')
const creds = require('../creds')
const moment = require('moment')
const md5 = require('md5')
const Session = require('../schemas/Session')
const fetch = require('node-fetch')

const DEV_ID = creds.devId
const AUTH_KEY = creds.authKey
const SMITE_URL = 'http://api.smitegame.com/smiteapi.svc'
const DATE_FORMAT = 'YYYYMMDDHHmmss'
const RES_TIMESTAMP_FORMAT = 'M/D/YYYY h:mm:ss a'

var router = express.Router()

router.get('/', function (req, res) {
  res.end('this is the api!')
})

router.get('/timestamp', function (req, res) {
  var timestamp = getTimestamp()
  res.end('timestamp: ' + timestamp)
})

router.get('/sessionid', function (req, res) {
  getSessionId(function (err, sessionId) {
    if (err) {
      res.end('Error: ' + err)
    }
    res.end('Session ID: ' + JSON.stringify(sessionId, null, 4))
  })
})

router.get('/:method', function (req, res) {
  getRequestURL(req.params.method, function (err, url) {
    if (err) { res.end('Error: ' + err) }

    fetch(url)
    .then(function (res) {
      return res.json()
    }).then(function (json) {
      res.json(json)
    })
  })
})

function getRequestURL (method, cb) {
  getSessionId(function (err, sessionID) {
    var timestamp = getTimestamp()
    var signature = getSignature(method, timestamp)

    var url = `${SMITE_URL}/${method}Json/${DEV_ID}/${signature}/${sessionID}/${timestamp}`
    cb(err, url)
  })
}

function getSessionId (cb) {
  var cutoff = moment.utc().subtract(15, 'minutes').toDate()
  console.log('cutoff is: ', cutoff)
  Session.findOne({timestamp: {$gt: cutoff}}, function (err, result) {
    if (err) { cb(err) }

    if (result) {
      var recordTime = new Date(result.timestamp)
      console.log('pulling from record')
      console.log('timestamp is', moment(recordTime).toDate())
      cb(null, result.session_id)
    } else {
      var timestamp = getTimestamp()
      var signature = getSignature('createsession', timestamp)
      var url = `${SMITE_URL}/createsessionJson/${DEV_ID}/${signature}/${timestamp}`

      fetch(url)
      .then(function (res) {
        return res.json()
      }).then(function (json) {
        Session.create({
          'ret_msg': json.ret_msg,
          'session_id': json.session_id,
          'timestamp': moment(json.timestamp, RES_TIMESTAMP_FORMAT).toDate()
        }, function (err, session) {
          cb(err, session.session_id)
        })
      })
    }
  })
}

// takes a method without the response type and a timestamp
function getSignature (method, timestamp) {
  var message = DEV_ID + method + AUTH_KEY + timestamp
  return md5(message)
}

// Takes an optional date object and returns a timestamp
function getTimestamp (date) {
  if (date) {
    date = moment(date)
  } else {
    date = moment.utc()
  }

  // format the date yyyyMMddHHmmss

  var timestamp = date.format(DATE_FORMAT)

  return timestamp
}

module.exports = router
