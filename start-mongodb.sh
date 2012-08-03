#! /bin/bash

mongod --rest --journal --fork --logpath /var/log/mongodb.log --logappend

