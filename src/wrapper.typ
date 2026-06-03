
#import "splitter.typ": *

#let add-padding(body, padding: 1em) = {
  if type(padding) == length {
    return pad(body, x: padding, y: padding)
  } else if type(padding) == dictionary {
    if padding.keys().contains("h") or padding.keys().contains("v") {
      return pad(
        body,
        x: padding.at("h", default: 0cm),
        y: padding.at("v", default: 0cm),
      )
    } else {
      return pad(
        body,
        top: padding.at("top", default: 0cm),
        bottom: padding.at("bottom", default: 0cm),
        left: padding.at("left", default: 0cm),
        right: padding.at("right", default: 0cm),
      )
    }
  }
}

#let wrap(
  wrapper-body,
  wrapped-body,
  align: top + right,
  width: 50%,
  padding: (h: 1em),
  indent-first-line: true
) = {context [
    #let original-spacing = par.spacing
    #set par(spacing: 0em)
    #layout(size => {
      set par(spacing: original-spacing)

      // let indent-first-line = content-before-wrap-is-par()

      let wrapped = add-padding(wrapped-body, padding: padding)

      // let wrapped-body = {
      //   set par(spacing: original-spacing)
      //   wrapped-body
      // }

      let wrapper-width = size.width * (100% - width)
      let wrapped-width = size.width * width
      let wrapped-height = measure(wrapped, width: wrapped-width).height

      let wrapper-body-valid = wrapper-body.func() != [ ].func() and wrapper-body.func() != parbreak()
      let result = splitter(
        wrapper-body,
        size.width,
        wrapper-width,
        wrapped-height,
        align.y != top,
        align.y != bottom,
      )

      let inner-wrapper = block(width: 100%)[
        #set par(spacing: original-spacing)
        #if indent-first-line and align.y == top {h(par.first-line-indent.amount)}
        #result.inner
        #if align.y != bottom {linebreak(justify: par.justify)}
      ]

      let outer-top-wrapper = block(width: 100%)[
        #set par(spacing: original-spacing)
        #if indent-first-line and align.y != top {h(par.first-line-indent.amount)}
        #result.outer-top
        #linebreak(justify: par.justify)
      ]

      let outer-bottom-wrapper = block(width: 100%)[
        #set par(spacing: original-spacing)
        #result.outer-bottom
      ]

      [
        #set par(spacing: par.leading)

        #if align.y != top {outer-top-wrapper}

        #box(width: 100%, grid(
          columns: if align.x == left {
            (width, 100% - width)
          } else {
            (100% - width, width)
          },
          align: horizon,

          if align.x == left {wrapped} else {inner-wrapper},
          if align.x == left {inner-wrapper} else {wrapped}
        ))

        #if align.y != bottom {outer-bottom-wrapper}
      ]
    })
    #box(width: 100%, height: 0cm)
  ]
}
