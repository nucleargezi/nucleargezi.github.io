#import "shared.typ": *

#let main = shared-template.with()

#let msk = "■";
#let HL(s) = text(size: 9pt)[*#s*]
#let tab = text[#h(8pt)]
#let endl = linebreak()
#let prod = $product$