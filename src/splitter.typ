
#let sequence = [].func()
#let space = [ ].func()
#let styled = text(white)[].func()


#let split-squence(
  split-content,
  sequence-to-split,
  target-width,
  target-top-height,
  target-type,
  split
) = {
  let top-sequence = sequence-to-split
  let bottom-sequence = []

  let children = sequence-to-split.children

  let i = 0
  let top-height = 0cm
  while top-height < target-top-height and i < children.len() {
    // Treat mutltiple refs as one child
    let child-to-check = children.at(i)
    if child-to-check.func() == ref {
      let space = [ ].func()

      while (i+1) < children.len() {
        child-to-check = children.at(i + 1)
        if child-to-check.func() != space and child-to-check.func() != ref {
          break
        }
        i += 1
      }
    }

    let top-part = split-content.top + children.slice(0, i).join()
    top-height = measure(top-part, width: target-width).height

    i += 1
  }

  i -= 1
  // if (target-type == "max") {i -= 2}
  // else if (target-type == "min") {i -= 1}

  if (i > 0) {
    top-sequence = children.slice(0, i - 1).join()
    let child-to-split = children.at(i - 1)
    bottom-sequence = children.slice(i, children.len()).join()
    
    let result = split(
      (top: split-content.top + top-sequence, bottom: bottom-sequence + split-content.bottom),
      child-to-split,
      target-width,
      target-top-height,
      target-type
    )

    top-sequence = top-sequence + result.top-part
    bottom-sequence = result.bottom-part + bottom-sequence
  }

  return (top-part: top-sequence, bottom-part: bottom-sequence)
}

#let split-styled(
  split-content,
  styled-to-split,
  target-width,
  target-top-height,
  target-type,
  split
) = {
  let child = styled-to-split.child

  let result = split(
    (top: split-content.top, bottom: split-content.bottom),
    child,
    target-width,
    target-top-height,
    target-type
  )

  let top-styled = (result.top-part, styled-to-split.styles)
  let bottom-styled = (result.bottom-part, styled-to-split.styles)

  return (top-part: styled(..top-styled), bottom-part: styled(..bottom-styled))
}

#let split-text(
  split-content,
  text-to-split,
  target-width,
  target-top-height,
  target-type,
  split
) = {
  let top-text = text-to-split
  let bottom-text = []

  let words = text-to-split.text.split(" ")

  let i = 0
  let top-height = 0cm
  while top-height < target-top-height and i < words.len() {
    let top-part = split-content.top + words.slice(0, i).join(" ")
    top-height = measure(top-part, width: target-width).height

    i += 1
  }

  if (target-type == "max") {i -= 2}
  else if (target-type == "min") {i -= 1}

  if (i > 0) {
    top-text = words.slice(0, i).join(" ")
    bottom-text = words.slice(i, words.len()).join(" ")
  }

  return (top-part: top-text, bottom-part: bottom-text)
}

#let split(
  split-content,
  content-to-split,
  target-width,
  target-top-height,
  target-type,
) = {
  let result = (top-part: content-to-split, bottom-part: [])

  if (target-type != "min" and target-type != "max") {return (top-part: [target-type #target-type is not "min" or "max"])}

  if content-to-split.func() == sequence {
    result = split-squence(split-content, content-to-split, target-width, target-top-height, target-type, split)
  } else if content-to-split.func() == styled {
    result = split-styled(split-content, content-to-split, target-width, target-top-height, target-type, split)
  } else if content-to-split.func() == text {
    result = split-text(split-content, content-to-split, target-width, target-top-height, target-type, split)
  } else {
    result = (top-part: result.top-part, bottom-part: [#result.bottom-part No splitter for #content-to-split.func(). #content-to-split.fields()])
  }

  return result
}

#let splitter(
  content-to-split,
  full-width,
  target-inner-width,
  target-inner-height,
  has-outer-top,
  has-outer-bottom,
) = {
  let outer-top-part = []
  let inner-part = content-to-split
  let outer-bottom-part = []

  if has-outer-top {
    let target-top-height = measure(inner-part, width: target-inner-width).height - target-inner-height
    if has-outer-bottom {target-top-height /= 2}

    let result = split((top: [], bottom: []), inner-part, target-inner-width, target-top-height, "max")
    outer-top-part = result.top-part
    inner-part = result.bottom-part
  }

  if has-outer-bottom {
    let result = split((top: [], bottom: []), inner-part, target-inner-width, target-inner-height, "min")
    inner-part = result.top-part
    outer-bottom-part = result.bottom-part
  }

  return (inner: inner-part, outer-top: outer-top-part, outer-bottom: outer-bottom-part)
}
