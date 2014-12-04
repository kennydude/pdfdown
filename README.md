**NOTE: THIS DOCUMENTATION DOES NOT WORK BECAUSE I HAVE NOT DEPLOYED IT TO NPM!!!!!!!*

# pdfdown

pdfdown is a tool to turn Markdown documents into PDFs

	[sudo] npm install -g pdfdown

	pdfdown AwesomeMarkdownFile.md AwesomePDFFile.pdf

You can also use style sheets in order to customize what your documents look like (but it's not full on CSS, so
don't expect to be able to use CSS3 etc).

If you are using the version out of git you will need to run `./compile.sh` otherwise it will not work correctly.

## Stylesheets

Stylesheets look similar to CSS but are not as powerful due to Markdown not needing mass complexity. Rules are
interpreted from top to bottom, there is no other logic going on.

A [default stylesheet](lib/stylesheets/default.css) is always used first, and you can specify your own like so:

	pdfdown -s MyStyles.css AwesomeMarkdownFile.md AwesomePDFFile.pdf

## TODO

* Support for Linux ([fc-match](http://linux.die.net/man/1/fc-match) might work?) and Windows font detection

## Tips for OSX

**Note:** if you installed via npm, this does not apply :)

Font lookups on OSX may take a moment to do due to Swift needing to be called. You can speed this up by running:

	./compileosx.sh

That will compile the `findfont` command we use to ask OSX where fonts are located