# CLI
args = process.argv.slice(2)
fs = require("fs")
commonmark = require("commonmark")

Stylesheet = require "./stylesheets/stylesheet.coffee"
styles = new Stylesheet()

styles.addSheet fs.readFileSync(__dirname + "/stylesheets/default.css").toString(), (err) ->
	if err then return console.error err

	for k, arg of args
		if arg == "-s"
			if !fs.existsSync(args[k*1+1])
				return console.error "E: Provided stylesheet (#{args[k*1+1]}) does not exist"
			styles.addSheet fs.readFileSync( args[k*1+1] ).toString(), (err) ->
				if err then return console.error err
				args.splice(k, 2)
				return doIt()
			return
		return doIt()


doIt = () ->
	if args.length != 2
		console.log("Usage: pdfdown in.md out.pdf")
		process.exit(-1)

	reader = new commonmark.DocParser()
	PDFRenderer = require("./pdf-renderer")
	pdf = new PDFRenderer()

	input = fs.readFileSync( args[0] ).toString()

	s = {}
	for k, v of styles.elements
		r = v.toPdfMake()
		if r != null
			s[k] = r

	doc = {
		header : styles.elements.header.toPdfMake(),
		footer : styles.elements.footer.toPdfMake()
		content: pdf.render(reader.parse(input)),
		styles : s
	}
	console.log JSON.stringify doc, null, 2

	pdfMake = require "pdfmake"

	printer = new pdfMake(styles.fonts)
	pdfDoc = printer.createPdfKitDocument(doc)

	pdfDoc.pipe(fs.createWriteStream(args[1]))
	pdfDoc.end()