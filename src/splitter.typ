
#let sequence = [].func()
#let space = [ ].func()
#let styled = text(white)[].func()
#let symbol = [...].func()

#let xor(a, b) = {
  return (not a and b) or (a and not b)
}

#let split-sequence-top(
  split-content,
  sequence-to-split,
  target-height,
  target-width,
  split,
) = {
  let children = sequence-to-split.children

  let i = 0
  while i < children.len() {
    // Treat mutltiple refs as one child and ignore spaces
    let child-to-check = children.at(i)
    while ((child-to-check.func() == ref or child-to-check.func() == cite or child-to-check.func() == space) and i < children.len() - 1) {
      i += 1
      child-to-check = children.at(i)
    }

    let top-part = split-content.top + children.slice(0, i + 1).join()
    let height = measure(top-part, width: target-width).height

    if (height >= target-height) {break} else {i += 1}
  }

  if (i == children.len()) {
    return (
      top-part: sequence-to-split,
      bottom-part: []
    )
  } else {
    let top-sequence = children.slice(0, i).join()
    let bottom-sequence = children.slice(i + 1, children.len()).join()

    let child-to-split = children.at(i);
    let result = split(
      (
        top: split-content.top + top-sequence,
        bottom: bottom-sequence + split-content.bottom
      ),
      child-to-split,
      target-height,
      target-width,
    )

    return (
      top-part: top-sequence + result.top-part,
      bottom-part: result.bottom-part + bottom-sequence
    )
  }
}

#let split-sequence-bottom(
  split-content,
  sequence-to-split,
  target-height,
  target-width,
  split,
) = {
  let children = sequence-to-split.children
  
  let i = children.len() - 1
  while i >= 0 {
    // Treat mutltiple refs as one child and ignore spaces
    let child-to-check = children.at(i)
    while ((child-to-check.func() == ref or child-to-check.func() == cite or child-to-check.func() == space) and i > 0) {
      i -= 1
      child-to-check = children.at(i)
    }

    let bottom-part = children.slice(i, children.len()).join() + split-content.bottom
    let height = measure(bottom-part, width: target-width).height

    if (height >= target-height) {break} else {i -= 1}
  }

  if (i < 0) {
    return (
      top-part: [],
      bottom-part: sequence-to-split
    )
  } else {
    let top-sequence = children.slice(0, i).join()
    let bottom-sequence = children.slice(i + 1, children.len()).join()

    let child-to-split = children.at(i);
    let result = split(
      (
        top: split-content.top + top-sequence,
        bottom: bottom-sequence + split-content.bottom
      ),
      child-to-split,
      target-height,
      target-width,
    )

    return (
      top-part: top-sequence + result.top-part,
      bottom-part: result.bottom-part + bottom-sequence
    )
  }
}

#let split-styled(
  split-content,
  styled-to-split,
  target-height,
  target-width,
  split
) = {
  let child = styled-to-split.child

  let result = split(
    (top: split-content.top, bottom: split-content.bottom),
    child,
    target-height,
    target-width,
  )

  let top-styled = (result.top-part, styled-to-split.styles)
  let bottom-styled = (result.bottom-part, styled-to-split.styles)

  return (
    top-part: styled(..top-styled),
    bottom-part: styled(..bottom-styled)
  )
}

#let split-emph(
  split-content,
  emph-to-split,
  target-height,
  target-width,
  split
) = {
  let body = emph-to-split.body

  let result = split(
    (top: split-content.top, bottom: split-content.bottom),
    body,
    target-height,
    target-width,
  )

  return (
    top-part: emph(result.top-part),
    bottom-part: emph(result.bottom-part)
  )
}

#let split-text-top(
  split-content,
  text-to-split,
  target-height,
  target-width,
  split
) = {
  let words = text-to-split.text.split(" ")

  let i = 0
  while i < words.len() {
    let top-part = split-content.top + words.slice(0, i + 1).join(" ")
    let height = measure(top-part, width: target-width).height

    if (height >= target-height) {break} else {i += 1}
  }

  if (i >= words.len()) {
    return (
      top-part: text-to-split,
      bottom-part: []
    )
  } else {
    let top-text = words.slice(0, i + 1).join(" ")
    let bottom-text = words.slice(i + 1, words.len()).join(" ")

    return (
      top-part: top-text,
      bottom-part: bottom-text
    )
  }
}

#let split-text-bottom(
  split-content,
  text-to-split,
  target-height,
  target-width,
  split
) = {
  let words = text-to-split.text.split(" ")

  let i = words.len() - 1
  while i >= 0 {
    let bottom-part = words.slice(i, words.len()).join(" ") + split-content.bottom
    let height = measure(bottom-part, width: target-width).height

    if (height >= target-height) {break} else {i -= 1}
  }

  if (i < 0) {
    return (
      top-part: [],
      bottom-part: text-to-split
    )
  } else {
    let top-text = words.slice(0, i).join(" ")
    let bottom-text = words.slice(i, words.len()).join(" ")

    return (
      top-part: top-text,
      bottom-part: bottom-text
    )
  }
}

#let split-top(
  split-content,
  content-to-split,
  target-height,
  target-width,
) = {
  let result = (top-part: content-to-split, bottom-part: [])
  
  assert(content-to-split.func() != ref, message: "content-to-split is a ref. Normally split-sequence should prevent this from happening.")
  assert(content-to-split.func() != cite, message: "content-to-split is a cite. Normally split-sequence should prevent this from happening.")
  assert(content-to-split.func() != space, message: "content-to-split is a space. Normally split-sequence should prevent this from happening.")
  
  if content-to-split.func() == sequence {
    result = split-sequence-top(split-content, content-to-split, target-height, target-width, split-top)
  } else if content-to-split.func() == styled {
    result = split-styled(split-content, content-to-split, target-height, target-width, split-top)
  } else if content-to-split.func() == text {
    result = split-text-top(split-content, content-to-split, target-height, target-width, split-top)
  } else if content-to-split.func() == emph {
    result = split-emph(split-content, content-to-split, target-height, target-width, split-top)
  } else if content-to-split.func() == parbreak {
    // Default
  } else if content-to-split.func() == figure {
    // Default
  } else if content-to-split.func() == image {
    // Default
  } else if content-to-split.func() == symbol {
    // Default
  } else if content-to-split.func() == smartquote {
    // Sollte in split-sequence behoben werden
  } else {
    panic(content-to-split, content-to-split.func())
  }

  return result
}

#let split-bottom(
  split-content,
  content-to-split,
  target-height,
  target-width,
) = {
  let result = (top-part: [], bottom-part: content-to-split)
  
  assert(content-to-split.func() != ref, message: "content-to-split is a ref. Normally split-sequence should prevent this from happening.")
  assert(content-to-split.func() != cite, message: "content-to-split is a cite. Normally split-sequence should prevent this from happening.")
  assert(content-to-split.func() != space, message: "content-to-split is a space. Normally split-sequence should prevent this from happening.")
  
  if content-to-split.func() == sequence {
    result = split-sequence-bottom(split-content, content-to-split, target-height, target-width, split-bottom)
  } else if content-to-split.func() == styled {
    result = split-styled(split-content, content-to-split, target-height, target-width, split-bottom)
  } else if content-to-split.func() == text {
    result = split-text-bottom(split-content, content-to-split, target-height, target-width, split-bottom)
  } else if content-to-split.func() == emph {
    result = split-emph(split-content, content-to-split, target-height, target-width, split-bottom)
  } else if content-to-split.func() == parbreak {
    // Default
  } else if content-to-split.func() == figure {
    // Default
  } else if content-to-split.func() == image {
    // Default
  } else if content-to-split.func() == symbol {
    // Default
  } else if content-to-split.func() == smartquote {
    // Sollte in split-sequence behoben werden
  } else {
    panic(content-to-split, content-to-split.func())
  }

  return result
}

#let splitter(
  content-to-split,
  full-width,
  inner-width,
  target-inner-height,
  has-outer-top,
  has-outer-bottom,
) = {
  let outer-top-part = []
  let inner-part = content-to-split
  let outer-bottom-part = []

  let full-height = measure(inner-part, width: inner-width).height

  if (full-height > target-inner-height) {
    if has-outer-top and has-outer-bottom {
      let outer-height = (full-height - target-inner-height) / 2
      let target-height = measure(inner-part, width: full-width).height * (outer-height / full-height)

      let result = split-top(
        (top: [], bottom: []),
        inner-part,
        target-height - 1em.to-absolute(),
        full-width,
      )
      outer-top-part = result.top-part
      inner-part = result.bottom-part

      result = split-top(
        (top: [], bottom: []),
        inner-part,
        target-inner-height,
        inner-width,
      )
      inner-part = result.top-part
      outer-bottom-part = result.bottom-part
    } else if has-outer-top {
      let result = split-bottom(
        (top: [], bottom: []),
        inner-part,
        target-inner-height,
        inner-width
      )
      outer-top-part = result.top-part
      inner-part = result.bottom-part
    } else if has-outer-bottom {
      let result = split-top(
        (top: [], bottom: []),
        inner-part,
        target-inner-height,
        inner-width,
      )
      inner-part = result.top-part
      outer-bottom-part = result.bottom-part
    }
  }

  return (inner: inner-part, outer-top: outer-top-part, outer-bottom: outer-bottom-part)
}
