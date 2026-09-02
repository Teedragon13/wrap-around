
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
  indent-first-line: false,
  debug-wrap: false,
  debug-split: false,
) = {context [
  #let calc-top-wrapper = alignment.y != top and alignment.y != none
  #let calc-bottom-wrapper = alignment.y != bottom

  #let original-spacing = par.spacing

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
      calc-top-wrapper,
      calc-bottom-wrapper,
    )

    let outer-top-height = measure(result.outer-top, width: size.width).height

    let inner-height = measure(result.inner, width: wrapper-width).height

    let outer-bottom-height = measure(result.outer-bottom, width: size.width).height

    let has-outer-top = calc-top-wrapper and outer-top-height > 0pt
    let has-outer-bottom = calc-bottom-wrapper and outer-bottom-height > 0pt

    let outer-top-wrapper = block(width: 100%)[
      #set par(spacing: original-spacing)
      #if indent-first-line {h(par.first-line-indent.amount)}
      #result.outer-top
      #linebreak(justify: par.justify)
    ]

    let outer-bottom-wrapper = block(width: 100%)[
      #set par(spacing: original-spacing)
      #result.outer-bottom
    ]

    let inner-wrapper = block(width: 100%)[
      #set par(spacing: original-spacing)
      #if indent-first-line and not has-outer-top {h(par.first-line-indent.amount)}
      #result.inner
      #if has-outer-bottom {linebreak(justify: par.justify)}
    ]

    if debug-wrap {
      wrapped = block(stroke: red, wrapped)
      inner-wrapper = block(stroke: blue, inner-wrapper)
      outer-top-wrapper = block(stroke: yellow, outer-top-wrapper)
      outer-bottom-wrapper = block(stroke: green, outer-bottom-wrapper)
    }

    [
      #set par(spacing: par.leading)

      #if has-outer-top {outer-top-wrapper}

      #box(width: 100%, stroke: if debug-wrap {black} else {none}, grid(
        gutter: 0cm,
        columns: if alignment.x == left {(width, 100% - width)}
                  else {(100% - width, width)},
        align: horizon,

        if alignment.x == left {wrapped} else {inner-wrapper},
        if alignment.x == left {inner-wrapper} else {wrapped}
      ))

      #if has-outer-bottom {outer-bottom-wrapper}

      #if debug-wrap {
        place(alignment.y + center,
          dy: if alignment.y == top or alignment.y == none {1em}
              else if alignment.y == bottom {-1em},
          box(
            fill: rgb("#ffffffdd"),
            stroke: rgb("#00000022"),
            inset: 1em,
            align(left)[
              #if inner-height < wrapped-height {
                text(fill: red)[inner-height < wrapped-height!]
              }
              \ Width = #size.width (1/2 = #{size.width/2})
              \ Wrapper: width = #wrapper-width, height = #inner-height
              \ Wrapped: width = #wrapped-width, height = #wrapped-height
              \
              #text(fill: yellow)[outer-top-wrapper]
              #text(fill: blue)[inner-wrapper]
              #text(fill: green)[outer-bottom-wrapper]
              #text(fill: red)[wrapped]
              #text(fill: black)[inner-wrapper/wrapped - grid]
            ]
          )
        )
      }
      #if debug-split [
        \ outer-top = #result.outer-top.fields()
        \ inner = #result.inner.fields()
        \ outer-bottom = #result.outer-bottom.fields()
      ]
    ]
  })
]}
