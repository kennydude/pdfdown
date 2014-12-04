###
    Stylesheet Manager

    This deals with the parser and makes it really easy for the main
    part of pdfdown to deal with styling the pdf
###

parser = require "./parser.js"
async = require "async"

fontDetector = null
try
	# Load some form of font detector
	# At some point we should add more than just OSX support
	fontDetector = require "../font-detector/" + process.platform
catch e
	# Load a terrible version which does nothing just to make code simple
	fontDetector = require "../font-detector/dummy.coffee"
	console.warn "E: Font Detection is not available: ", e

# Basic Element
class Element
	canDoText : () -> return false

	toPdfMake: () ->
		return {
			margin : [ @marginLeft, @marginTop, @marginRight, @marginBottom ],
			font : @fontFace,
			fontSize : @fontSize
		}

	constructor : () ->
		@marginLeft   = 0
		@marginRight  = 0
		@marginTop    = 0
		@marginBottom = 0

class HeaderFooterElement extends Element
	constructor : () ->
		super()
	canDoText : () -> return true
	toPdfMake : () ->
		if !@text
			return null
		o = super()

		o['style'] = ['body']
		o['text'] = @text
		return o

# Stylesheet in general
class Stylesheet
	constructor : () ->
		@fonts = {} # Cache of fonts looked up
		@elements = {
			"p" : new Element(),
			"heading" : new Element(),
			"body" : new Element(),
			"header" : new HeaderFooterElement(),
			"footer" : new HeaderFooterElement()
		}

	locateFont : (font, cb) ->
		# Remove any garbage
		font = @parseString(font)
		console.log font

		# In cache?
		if @fonts[font]
			return cb @fonts[font]['normal'], font

		# Ask system
		fontDetector font, (result) =>
			@fonts[font] = {
				'normal' : result
			} # cache result
			return cb result, font

	setAttribute : (selectors, attribute, value) ->
		for selector in selectors
			selector = selector.trim()
			console.log selector, attribute, value

			if @elements[selector] != undefined
				switch attribute
					when "text"
						if !@elements[selector].canDoText()
							console.warn "E: #{selector} does not support text attribute"
				@elements[selector][attribute] = value
			else
				console.warn "E: Selector does not exist #{selector}"

	parseUnit : (m) ->
		m = m.trim()

		if m.indexOf("px") != -1
			m = parseInt(m.substr(0, m.length-2))

		return m

	parseString : (m) ->
		m = m.trim()
		if m.charAt(0) == '"' && m.charAt(m.length-1) == '"'
			m = m.substring(1, m.length - 1)
		if m.charAt(0) == "'" && m.charAt(m.length-1) == "'"
			m = m.substring(1, m.length - 1)
		return m

	addSheet : (input, cb) ->
		ast = parser.parse(input)
		console.log ast

		# TODO: parse through any @font-faces and add them
		for element in ast
			if element[0] == "@font-face"
				# do something?
				console.warn "Not implemented @font-face yet!"

		# Async is used here so stuff like font detection works seamlessly
		async.eachSeries ast, (element, next_element) =>
			# Skip @font-face on second pass
			if element[0] == "@font-face" then return next_element()
			selectors = element[0]
			contents = element[1]
			async.eachSeries contents, (rule, next_rule) =>
				# Now we actually parse the rule
				# and use setAttribute to set everything
				switch rule[0]
					when "text"
						@setAttribute selectors, "text", @parseString rule[1]
					when "font-size"
						@setAttribute selectors, "fontSize", @parseUnit rule[1]
					when "font-family"
						fonts = rule[1].split(",")
						async.eachSeries fonts, (font, next_font) =>
							@locateFont font, (result, font) =>
								if result != null
									# Set font because we've already got the font cached
									@setAttribute(selectors, "fontFace", font)
									return next_rule()
								return next_font()
						, () ->
							console.warn "E: Could not find any fonts"
							return next_rule()
						return
					when "margin"
						parts = rule[1].split(" ")
						if parts.length == 1
							m = parts[0].trim()
							@setAttribute selectors, "marginTop", @parseUnit m
							@setAttribute selectors, "marginLeft", @parseUnit m
							@setAttribute selectors, "marginRight", @parseUnit m
							@setAttribute selectors, "marginBottom", @parseUnit m
						else if parts.length == 2
							@setAttribute selectors, "marginTop", @parseUnit parts[0]
							@setAttribute selectors, "marginLeft", @parseUnit parts[1]
							@setAttribute selectors, "marginRight", @parseUnit parts[1]
							@setAttribute selectors, "marginBottom", @parseUnit parts[0]
						else if parts.length == 4
							@setAttribute selectors, "marginTop", @parseUnit parts[0]
							@setAttribute selectors, "marginLeft", @parseUnit parts[3]
							@setAttribute selectors, "marginRight", @parseUnit parts[1]
							@setAttribute selectors, "marginBottom", @parseUnit parts[2]
						else
							console.warn "E: margin is not set correctly"
					when "margin-top", "margin-bottom", "margin-left", "margin-right"
						m = @parseUnit rule[1]

						r = rule[0].split("-")[1]
						r = r.charAt(0).toUpperCase() + r.substr(1)
						@setAttribute(selectors, "margin" + r, m)
					else
						console.warn "E: Unknown rule: #{rule[0]}"
				return next_rule()
			, () ->
				next_element()
		, () ->
			cb()

module.exports = Stylesheet