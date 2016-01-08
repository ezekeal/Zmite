const express = require('express')
const creds = require('../creds')
const moment = require('moment')
const md5 = require('md5')
const Session = require('../schemas/Session')
const Cache = require('../schemas/Cache')
const fetch = require('node-fetch')

const DEV_ID = creds.devId
const AUTH_KEY = creds.authKey
const SMITE_URL = 'http://api.smitegame.com/smiteapi.svc'
const DATE_FORMAT = 'YYYYMMDDHHmmss'
const RES_TIMESTAMP_FORMAT = 'M/D/YYYY h:mm:ss a'

var router = express.Router()

router.get('/', function (req, res) {
  res.end('This is the API!')
  console.log('/api hit')
})

router.post('/', function (req, res) {
  if (req.body && req.body.method) {
    var method = req.body.method
    console.log('method is: ', method)
    getRequestURL(method, function (err, url) {
      if (err) { res.end('Error: ' + err) }

      req.body.params.map(function (param) {
        url += `/${param}`
      })

      console.log('url: ' + url)

      getCache(method, url, function (err, json) {
        if (err) { res.err }
        res.json(json)
      })
    })
  } else {
    res.end('No method given, make a request in the form:\n' +
      '{ "method": "[method name]" "params": ["optional param"] }')
  }
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
  var cutoff = moment.utc().subtract(14, 'minutes').toDate()
  Session.findOne({timestamp: {$gt: cutoff}}, function (err, result) {
    if (err) { cb(err) }

    if (result) {
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
          'timestamp': moment.utc(json.timestamp, RES_TIMESTAMP_FORMAT).toDate()
        }, function (err, session) {
          cb(err, session.session_id)
        })
      })
    }
  })
}

function getCache (method, url, cb) {
  switch (method) {

    case 'getitems':
      var cutoff = moment.utc().subtract(1, 'day').toDate()
      Cache.findOne({method: method}, function (err, result) {
        if (err) { cb(err) }

        if (result) {
          var expired = moment(result.timestamp).isBefore(cutoff)
          if (result.data && !expired) {
            var recordTime = new Date(result.timestamp)
            console.log('pulling from cache for: ' + method)
            console.log('time created: ', moment(recordTime).fromNow())
            cb(null, result.data)
          } else {
            console.log('cache expired; updating')
            fetchJson(url, function (json) {
              result.data = json
              result.timestamp = moment.utc().toDate()
              result.save()
              cb(null, result.data)
            })
          }
        } else {
          fetchJson(url, function (json) {
            console.log('creating cache')
            var timestamp = moment.utc().toDate()
            Cache.create({
              'method': method,
              'data': json,
              'timestamp': timestamp
            }, function (err, cache) {
              cb(err, cache.data)
            })
          })
        }
      })
      break

    default:
      fetch(url)
      .then(function (response) {
        return response.json()
      }).then(function (json) {
        cb(null, json)
      })
      break
  }
}

function fetchJson (url, cb) {
  fetch(url)
  .then(function (res) {
    return res.json()
  }).then(function (json) {
    cb(json)
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
