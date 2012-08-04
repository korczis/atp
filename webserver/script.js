var express = require('express');
var http = require('http');
var mongo = require('mongodb');

// Express HTTP Server
var app = null;

// MongoDB stuff
var db_server = null;
var db = null;

function initMongoDb() {
	console.log("Initializing MongoDB");

	db_server = new mongo.Server('localhost', 27017, {auto_reconnect: true});
	db = new mongo.Db('exampleDb', db_server);

	db.open(function(err, db) {
	  if(!err) {
	    console.log("Connected to the MongoDB");
	  }
	});
}

function initHttpServer() {
	console.log("Initializing Express web server");
	
	app = express();

	app.use(express.static(__dirname));

	app.get('/', function(req, res){
	  res.send('Hello World');
	});

	app.listen(3000);
}

function run() {
	initMongoDb();
	initHttpServer();
}

run();