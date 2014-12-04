class PDFRenderer

	renderInline : (inline) ->
		switch inline.t
			when "Text", "Str"
				return inline.c
			else
				console.warn "E: unknown inline element", inline

	removeUndefined : (items) ->
		r = []
		for item in items
			if item != null && item != undefined
				r.push item
		return r

	addBodyStyle : (b) ->
		b?.style?.unshift("body")
		return b

	render : (block, in_tight_list) ->
		switch block.t
			when "Document"
				return @removeUndefined(@addBodyStyle(@render(b)) for b in block.children)
			when "Header", "ATXHeader", "SetextHeader"
				return {
					text : @removeUndefined(@renderInline(i) for i in block.inline_content),
					style : [ "heading", "h" + block.level ]
				}
			when "Paragraph"
				return {
					text : @removeUndefined(@renderInline(i) for i in block.inline_content),
					style : ["p"]
				}
			when "HtmlBlock"
				console.warn "E: html is not valid"
				return undefined
			else
				console.warn "E: unknown element", block


module.exports = PDFRenderer