require 'open-uri'
require 'nokogiri'
doc = Nokogiri::XML(open(ARGV[0]))
svg = doc.at_css("svg")
viewBox = "0 0 36 36"
if svg.key?("viewBox")
    viewBox = svg["viewBox"].split(" ").map { |s| s.to_i }
    width = viewBox[2]
    height = viewBox[3]
    viewBox[0] -= width * 0.1
    viewBox[1] -= height * 0.1
    viewBox[2] *= 1.2
    viewBox[3] *= 1.2
    svg.delete("viewBox")
    viewBox = viewBox.join(" ")
end
symbol = Nokogiri::XML::Node.new "symbol", doc
symbol["viewBox"] = viewBox
symbol["id"] = "emoji"
g = Nokogiri::XML::Node.new "g", doc
for elem in doc.css("svg > *")
    border_elem = elem.dup
    elem.parent = symbol
    style = ""
    if border_elem.key?("style")
        style = border_elem["style"]
    end
    border_elem["fill"] = "transparent"
    if border_elem.key?("stroke")
        border_elem.delete("stroke")
        style += " stroke: inherit;"
    else
        elem["stroke"] = "transparent"
    end
    old_width = "0px"
    if border_elem.key?("stroke-width")
        old_width = border_elem["stroke-width"]
    end
    style += " stroke-width: calc(#{old_width} + 4px)"
    border_elem["style"] = style.strip
    g.add_child(border_elem)
end
symbol.prepend_child(g)
svg.add_child(symbol)
print(doc.to_xml)
