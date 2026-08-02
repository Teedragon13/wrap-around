
#import "../src/wrapper.typ": wrap

#import "@preview/wrap-it:0.1.1": *

#set par(
  justify: true,
)

#let lorem-length = 170

#[
  #wrap(alignment: horizon)[
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
]

#pagebreak()

= `alignment`

Default: #{top + right}

#[
  == #{top + left}

  This section shows how the result looks, when the figure hast a #{top + left} alignment specified in the #wrap function header.

  #wrap(alignment: left)[
    #lorem(lorem-length)
  ][
    #figure(caption: "Some figure",
      box(fill: red, width: 100%, height: 5cm)
    )
  ]
]

#[
  == #{top + right}

  This section shows how the result looks, when the figure hast a #{top + right} alignment specified in the #wrap function header.

  #wrap()[
    #lorem(lorem-length)
  ][
    #figure(caption: "Some figure",
      box(fill: red, width: 100%, height: 5cm)
    )
  ]
]

#pagebreak()

#[
  == #{horizon + left}

  This section shows how the result looks, when the figure hast a #{horizon + left} alignment specified in the #wrap function header.

  #wrap(alignment: horizon + left)[
    #lorem(lorem-length)
  ][
    #figure(caption: "Some figure",
      box(fill: red, width: 100%, height: 5cm)
    )
  ]
]

#[
  == #{horizon + right}

  This section shows how the result looks, when the figure hast a #{horizon + right} alignment specified in the #wrap function header.

  #wrap(alignment: horizon)[
    #lorem(lorem-length)
  ][
    #figure(caption: "Some figure",
      box(fill: red, width: 100%, height: 5cm)
    )
  ]
]

#pagebreak()

#[
  == #{bottom + left}

  This section shows how the result looks, when the figure hast a #{bottom + left} alignment specified in the #wrap function header.

  #wrap(alignment: bottom + left)[
    #lorem(lorem-length)
  ][
    #figure(caption: "Some figure",
      box(fill: red, width: 100%, height: 5cm)
    )
  ]
]

#[
  == #{bottom + right}

  The following section shows how the result looks, when the figure hast a #{bottom + right} alignment specified in the #wrap function header.

  #wrap(alignment: bottom)[
    #lorem(lorem-length)
  ][
    #figure(caption: "Some figure",
      box(fill: red, width: 100%, height: 5cm)
    )
  ]
]

#pagebreak()

= `indent-first-line`

Default: #false

#[
  #set par(first-line-indent: 1em)

  == #true

  When set to #true, the first line of the first paragraph is indented based on the value specified in `first-line-indent` of #par. I used this variable because I found no way to determine automatically if there is an paragraph directly before the #wrap function.

  #wrap(indent-first-line: true)[
    #lorem(50)

    #lorem(50)
  ][
    #figure(caption: "Some figure",
      box(fill: red, width: 100%, height: 4cm)
    )
  ]

  #lorem(40)
]

#[
  #set par(first-line-indent: 1em)

  == #false

  When set to #false, the first line of the first paragraph is not indented. But if `first-line-indent` is specified in #par, paragraphs within the #wrap function and the following par will still be indented.

  #wrap(indent-first-line: false)[
    #lorem(50)
    
    #lorem(50)
  ][
    #figure(caption: "Some figure",
      box(fill: red, width: 100%, height: 4cm)
    )
  ]

  #lorem(40)
]

#pagebreak()

= `padding`

Default: #(h: 1em, v: 0.5em)

#[]

#pagebreak()

= `width`

Default: #50%

#[
  Width of wrapped content including padding
]
