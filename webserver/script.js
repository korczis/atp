var express = require('express');
var http = require('http');
var mongodb = require('mongodb');

var app = express();

app.use(express.static(__dirname));

app.get('/', function(req, res){
  res.send('Hello World');
});

app.listen(3000);