css = element +

element = whitespace selector:selector whitespace "{" whitespace contents:contents whitespace "}" whitespace { return [selector, contents] }

selector = items:(item+) { return items } / "@font-face"
item = item:([a-zA-Z]+) whitespace ","? whitespace { return item.join(""); }

contents = rule+
rule = name:([a-zA-Z\-]+) ":" whitespace value:([a-z\" A-Z\-,0-9\(\)] +) ";" whitespace { return [name.join(""),value.join("")]; }

whitespace = space*
space = [ \n\t] / "/*" [^"*/*]+ "*/"