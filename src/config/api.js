var express = require('express')

var router = express.Router()

router.get('/', function (req, res) {
  res.end('this is the api!')
})

module.exports = router
