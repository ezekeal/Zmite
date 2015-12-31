const express = require('express')
const creds = require('../creds')
const moment = require('moment')
const md5 = require('md5')
const mongoose = require('mongoose')
const Session = require('../schemas/Session')
const fetch = require('node-fetch')

const DEV_ID = creds.devId
const AUTH_KEY = creds.authKey
const SMITE_URL = 'http://api.smitegame.com/smiteapi.svc'

var router = express.Router()

router.get('/', function (req, res) {
  res.end('this is the api!')
})

router.get('/timestamp', function (req, res) {
  var timestamp = getTimestamp()
  res.end('timestamp: ' + timestamp)
})

router.get('/sessionid', function (req, res) {
  getSessionId(function (sessionId) {
    res.end('Session ID: ' + JSON.stringify(sessionId, null, 4))
  })
})

router.get('/url/:method', function (req, res) {
  var url = getRequestURL(req.params.method)
  res.end('url: ' + url)
})

function getRequestURL (method) {
  var timestamp = getTimestamp()
  var signature = getSignature(method, timestamp)
  var url = `${SMITE_URL}/${method}Json/${DEV_ID}/${signature}/${timestamp}`
  return url
}

function getSessionId (cb) {
  var cutoff = moment().subtract(15, 'minutes').toDate()
  Session.findOne().where('timestamp').gt(cutoff).exec(function (err, result) {
    if (err) { throw err }

    if (result) {
      cb(result)
    } else {
      var url = getRequestURL('createsession')
      fetch(url)
      .then(function (res) {
        return res.json()
      }).then(function (json) {
        Session.create({
          'ret_msg': json.ret_msg + ' created',
          'session_id': json.session_id,
          'timestamp': Date.parse(json.timestamp)
        }, function (err, small) {
          if (err) { return console.log(err) };
          // saved!
        })
        cb(json)
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

  const DATE_FORMAT = 'YYYYMMDDHHmmss'

  var timestamp = date.format(DATE_FORMAT)

  return timestamp
}

module.exports = router
