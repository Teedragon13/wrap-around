
#import "../src/wrapper.typ": wrap

#import "@preview/wrap-it:0.1.1": *

#set par(
  justify: true,
  first-line-indent: 1em
)



#lorem(50)

#wrap(align: horizon)[
  #text(fill: red, lorem(3))
  #text(fill: orange, lorem(4))
  #text(fill: yellow, lorem(2))
  #text(fill: green, lorem(20))
  #text(fill: blue, lorem(2))
  #text(fill: purple, lorem(5))
  #text(fill: fuchsia, lorem(200))
  #text(fill: black, lorem(200))
][
  #figure(caption: "Some figure",
    box(fill: red, width: 100%, height: 5cm)
  )
]

#lorem(50)

#pagebreak()

#let lorem-length = 200

- align: #{top + left}

#wrap(align: top + left)[
  // #lorem(75)
  #lorem(lorem-length)
][
  #figure(caption: "Some figure",
    box(fill: red, width: 100%, height: 5cm)
  )
]

- align: #{top + left}

#wrap(align: top + right)[
  #lorem(lorem-length)
][
  #figure(caption: "Some figure",
    box(fill: red, width: 100%, height: 5cm)
  )
]

#pagebreak()

- align: #{horizon + left}

#wrap(align: horizon + left)[
  #lorem(lorem-length)
][
  #figure(caption: "Some figure",
    box(fill: red, width: 100%, height: 5cm)
  )
]

- align: #{horizon + left}

#wrap(align: horizon + right)[
  #lorem(lorem-length)
][
  #figure(caption: "Some figure",
    box(fill: red, width: 100%, height: 5cm)
  )
]

#pagebreak()

- align: #{bottom + left}

#wrap(align: bottom + left)[
  #lorem(lorem-length)
][
  #figure(caption: "Some figure",
    box(fill: red, width: 100%, height: 5cm)
  )
]

- align: #{bottom + right}

#wrap(align: bottom + right)[
  #lorem(lorem-length)
][
  #figure(caption: "Some figure",
    box(fill: red, width: 100%, height: 5cm)
  )
]
