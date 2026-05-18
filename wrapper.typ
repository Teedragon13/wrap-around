
#let split-text(
  inner-content,
  outer-content,
  child-to-split,
  wrapper-width,
  wrapped-width,
  wrapped-height,
  reverse
) = {
  let words = child-to-split.text.split(" ")

  let inner-height = 0pt
  let i = 0
  while inner-height < wrapped-height and i < words.len() {
    i += 1

    let inner-text = words.slice(0, i).join(" ")
    let outer-text = words.slice(i, words.len()).join(" ")
    
    let inner-part = inner-content + inner-text
    inner-height = measure(inner-part, width: wrapper-width).height
  }

  let last-height = inner-height

  while last-height == inner-height and i < words.len() {
      i += 1

      let inner-text = words.slice(0, i).join(" ")
      let outer-text = words.slice(i, words.len()).join(" ")
      
      let inner-part = inner-content + inner-text
      last-height = measure(inner-part, width: wrapper-width).height
  }

  let inner-text = words.slice(0, i - 1).join(" ")
  let outer-text = words.slice(i - 1, words.len()).join(" ")
  
  return (inner: inner-text, outer: outer-text)
}

#let split-children(
  inner-content,
  outer-content,
  children-to-split,
  wrapper-width,
  wrapped-width,
  wrapped-height,
  reverse
) = {
  let children = children-to-split.children

  let inner-children
  let outer-children

  // Split children
  let i = 0
  let wrapper-height = 0pt
  while wrapper-height < wrapped-height and i < children.len() {
    i += 1

    // Treat mutltiple refs as one 
    let child-to-split = children.at(i - 1)
    if child-to-split.func() == ref {
      let space = [ ].func()

      while i < children.len() {
        let child-to-check = children.at(i)
        if child-to-check.func() != space and child-to-check.func() != ref {
          break
        }
        i += 1
      }
    }

    inner-children = children.slice(0, i).join()
    outer-children = children.slice(i, children.len()).join()

    let inner-part = inner-content + inner-children     
    wrapper-height = measure(inner-part, width: wrapper-width).height
  }

  // Test if last inner children can be split
  let child-to-split = children.at(i - 1)
  if child-to-split.func() == par {
    inner-children = children.slice(0, i - 1).join()
    outer-children = children.slice(i, children.len()).join()
    
    let inner-part = inner-content + inner-children
    let outer-part = outer-children + outer-content

    let split-children = split-children(inner-part, outer-part, child-to-split.body, wrapper-width, wrapped-width, wrapped-height, reverse)

    let inner-par = par(
      spacing: par.leading,
      split-children.inner
    )

    let outer-par = par(
      spacing: par.leading,
      split-children.outer
    )

    inner-children = inner-children + inner-par
    outer-children = outer-par + outer-children
  } else if child-to-split.func() == text {
    inner-children = children.slice(0, i - 1).join()
    outer-children = children.slice(i, children.len()).join()
    
    let inner-part = inner-content + inner-children
    let outer-part = outer-children + outer-content

    let split-text = split-text(inner-part, outer-part, child-to-split, wrapper-width, wrapped-width, wrapped-height, reverse)

    inner-children = children.slice(0, i - 1).join() + split-text.inner
    outer-children = split-text.outer + children.slice(i, children.len()).join()
  }

  return (inner: inner-children, outer: outer-children)
}

#let splitter(
  wrapper-body,
  wrapper-width,
  wrapped-width,
  wrapped-height,
  reverse: false
) = {
  let split-children = split-children([], [], wrapper-body, wrapper-width, wrapper-width, wrapped-height, reverse)

  return (inner: split-children.inner, outer: split-children.outer)
}

/// Wraps the wrapper-body around the wrapped-body.
///
/// - wrapper-body (): 
/// - wrapped-body (): 
/// - wrapper-fraction (): 
/// - wrapped-fraction (): 
/// - gutter (): 
/// - align (): 
/// ->
#let wrap(
  wrapper-body,
  wrapped-body,
  wrapper-fraction: 1fr,
  wrapped-fraction: 1fr,
  gutter: 1em,
  align: top + right,
) = {context block(width: 100%)[
    // #let isList = part.children.any(child => {if child.func() == list.item or child.func() == enum.item {true} else {false}})

    // #if not isTop {
    //   part1;
    //   if isList {} else {linebreak(justify: par.justify)}
    // }

    // #let grid-cell-content = if not isTop {
    //   part
    // } else {
    //   part;
    //   if isList {} else {linebreak(justify: par.justify)}
    // }

    #layout(size => {
      let is-par-before-wrap = query(selector(par).before(here()).after(selector(heading).before(here()))).len() > 0

      let wrapper-width = length.to-absolute(size.width - gutter) * (wrapper-fraction / (wrapper-fraction + wrapped-fraction))

      let wrapped-width = length.to-absolute(size.width - gutter) * (wrapped-fraction / (wrapper-fraction + wrapped-fraction))
      
      let wrapped-body = {
        set par(spacing: par.spacing)
        wrapped-body
      }

      let wrapped-height = measure(wrapped-body, width: wrapped-width).height

      let result = splitter(wrapper-body, wrapper-width, wrapped-width, wrapped-height, reverse: align.y != top)

      let inner-wrapper = block(width: 100%)[
        #set par(spacing: par.spacing)
        #if is-par-before-wrap {h(par.first-line-indent.amount)}
        #result.inner
        #if align.y == top {linebreak(justify: par.justify)}
      ]

      let outer-wrapper = block(width: 100%)[
        #set par(spacing: par.spacing)
        #result.outer
        #if align.y != top {linebreak(justify: par.justify)}
      ]

      [
        #set par(spacing: par.leading)

        #if align.y != top {
          outer-wrapper
        }

        #box(width: 100%, grid(
          columns: if align.x == left {
            (wrapped-fraction, wrapper-fraction)
          } else {
            (wrapper-fraction, wrapped-fraction)
          },
          column-gutter: 1em,
          row-gutter: 0cm,
          align: horizon,

          if align.x == left {wrapped-body} else {
            inner-wrapper},
          if align.x == left {inner-wrapper} else {wrapped-body}
        ))

        #if align.y == top {outer-wrapper}
      ]
    })
  ]
}
