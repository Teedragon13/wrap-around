
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
  alignment: top + right,
  width: 50%,
  padding: (h: 1em, v: 0.5em),
  indent-first-line: false
) = {context [
    #let has-top-content = alignment.y != top and alignment.y != none
    #let has-bottom-content = alignment.y != bottom

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
        has-top-content,
        has-bottom-content,
      )

      let inner-height = measure(result.inner, width: wrapper-width).height

      let inner-wrapper = block(width: 100%)[
        #set par(spacing: original-spacing)
        #if indent-first-line and not has-top-content {h(par.first-line-indent.amount)}
        #result.inner
        #if alignment.y != bottom {linebreak(justify: par.justify)}
      ]

      let outer-top-wrapper = block(width: 100%)[
        #set par(spacing: original-spacing)
        #if indent-first-line and alignment.y != top {h(par.first-line-indent.amount)}
        #result.outer-top
        #linebreak(justify: par.justify)
      ]

      let outer-bottom-wrapper = block(width: 100%)[
        #set par(spacing: original-spacing)
        #result.outer-bottom
      ]

      [
        #set par(spacing: par.leading)

        #if alignment.y != top {outer-top-wrapper}

        #box(width: 100%, grid(
          columns: if alignment.x == left {
            (width, 100% - width)
          } else {
            (100% - width, width)
          },
          align: if inner-height < wrapped-height {top} else {horizon},

          if alignment.x == left {wrapped} else {inner-wrapper},
          if alignment.x == left {inner-wrapper} else {wrapped}
        ))

        #if alignment.y != bottom {outer-bottom-wrapper}
      ]
    })
    #box(width: 100%, height: 0cm)
  ]
}
