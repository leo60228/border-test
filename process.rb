require 'open-uri'
require 'nokogiri'
doc = Nokogiri::XML(open(ARGV[0]))
bordered_doc = doc.dup
svg = doc.at_css("svg")
bordered_svg = bordered_doc.at_css("svg")
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
g = Nokogiri::XML::Node.new "g", bordered_doc
for elem in bordered_doc.css("svg > *")
    border_elem = elem.dup

    if border_elem.key?("fill")
        border_elem.delete("fill")
    end
    border_elem["stroke"] = "white"

    style = ""
    if border_elem.key?("style")
        style = border_elem["style"]
    end
    old_width = "0px"
    if border_elem.key?("stroke-width")
        old_width = border_elem["stroke-width"]
    end
    style += " stroke-width: calc(#{old_width} + 4px)"
    border_elem["style"] = style.strip

    g.add_child(border_elem)
end
bordered_svg.prepend_child(g)
bordered_svg["viewBox"] = viewBox
svg["viewBox"] = viewBox
puts(bordered_doc.to_xml)
STDERR.puts(doc.to_xml)
