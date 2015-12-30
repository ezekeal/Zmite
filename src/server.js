const mongoose = require('mongoose')
const express = require('express')
const bodyParser = require('body-parser')
const routes = require('./config/routes')
const api = require('./config/api')

const app = express()

const DB_URI = 'mongodb://localhost/zmite'
const PORT = 5000

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }))
app.use(express.static(__dirname + '/public'))

app.use('/', routes)

app.use('/api', api)

app.use(function (req, res, next) {
  var err = new Error('Not Found')
  err.status = 404
  next(err)
})

mongoose.connect(DB_URI)

var db = mongoose.connection

db.on('error', console.error.bind(console, 'connection error:'))
db.once('open', function () {
  app.listen(PORT)
  console.log('Zmite server started on port ' + PORT)
})
