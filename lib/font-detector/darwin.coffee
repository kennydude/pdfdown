###
    OSX Font Detector

    For some reason Apple made it so only OSX apps can access CoreText and find this out :/

    findfont.swift does the hard work here, this file just calls out to it
###

spawn = require('child_process').spawn

fs = require "fs"

if fs.existsSync(__dirname + "/findfont")
	# We found a binary
	module.exports = (fontName, cb) ->
		findFont = spawn( __dirname + "/findfont", [ fontName ])

		findFont.stdout.on 'data', (data) ->
			cb data.toString().trim()

		findFont.on 'close', (code, signal) ->
			if code != 0
				cb null # could not be found :/
else
	# This is where we could not find a binary
	module.exports = (fontName, cb) ->
		findFont = spawn("swift", [ __dirname + "/findfont.swift", fontName ])

		findFont.stdout.on 'data', (data) ->
			cb data.toString().trim()

		findFont.on 'close', (code, signal) ->
			if code != 0
				cb null # could not be found :/