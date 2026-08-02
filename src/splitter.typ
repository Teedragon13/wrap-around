
#let sequence = [].func()
#let space = [ ].func()
#let styled = text(white)[].func()

#let xor(a, b) = {
  return (not a and b) or (a and not b)
}

#let split-squence(
  split-content,
  sequence-to-split,
  target-is-top,
  target-height,
  top-width,
  bottom-width,
  split
) = {
  let top-sequence = sequence-to-split
  let bottom-sequence = []

  let children = sequence-to-split.children

  // Split children
  let a = children.len()
  let r = true
  let i = 0
  let height
  while true {
    if target-is-top {
      let part = split-content.top + children.slice(0, i).join()
      height = measure(part, width: top-width).height
    } else {
      let part = children.slice(i, children.len()).join() + split-content.bottom
      height = measure(part, width: bottom-width).height
    }

    if (calc.odd(a)) {
      if (r) {a += 1}
      r = not r
    }
    a = calc.floor(a / 2)
    if xor(height < target-height, target-is-top) {
      i = calc.clamp(i - a, 0, children.len() - 1)
      
      // Treat mutltiple refs as one child
      let child-to-check = children.at(i)
      if child-to-check.func() == ref or child-to-check.func() == cite or child-to-check.func() == space {
        while (i - 1) >= 0 and (i - 1) < children.len() {
          child-to-check = children.at(i - 1)
          if child-to-check.func() != space and child-to-check.func() != ref and child-to-check.func() != cite {
            break
          }
          i -= 1
        }
      }
    } else {
      i = calc.clamp(i + a, 0, children.len() - 1)
      
      // Treat mutltiple refs as one child
      let child-to-check = children.at(i)
      if child-to-check.func() == ref or child-to-check.func() == cite or child-to-check.func() == space {
        while (i + 1) >= 0 and (i + 1) < children.len() {
          child-to-check = children.at(i + 1)
          if child-to-check.func() != space and child-to-check.func() != ref and child-to-check.func() != cite {
            break
          }
          i += 1
        }
      }
    }

    if (a <= 0) {break}
  }
  // Make sure height one step greater than target-height
  while (height < target-height and i > 0 and i < children.len()) {
    if (target-is-top) {
      i += 1

      // Treat mutltiple refs as one child
      let child-to-check = children.at(i)
      if child-to-check.func() == ref or child-to-check.func() == cite or child-to-check.func() == space {
        while (i + 1) < children.len() {
          child-to-check = children.at(i + 1)
          if child-to-check.func() != space and child-to-check.func() != ref and child-to-check.func() != cite {
            break
          }
          i += 1
        }
      }
    } else {
      i -= 1

      // Treat mutltiple refs as one child
      let child-to-check = children.at(i)
      if child-to-check.func() == ref or child-to-check.func() == cite or child-to-check.func() == space {
        while (i - 1) < children.len() {
          child-to-check = children.at(i - 1)
          if child-to-check.func() != space and child-to-check.func() != ref and child-to-check.func() != cite {
            break
          }
          i -= 1
        }
      }
    }
    
    if target-is-top {
      let part = split-content.top + children.slice(0, i).join()
      height = measure(part, width: top-width).height
    } else {
      let part = children.slice(i, children.len()).join() + split-content.bottom
      height = measure(part, width: bottom-width).height
    }
  }
  // Add children until line is filled
  let j = i
  while j < children.len() {
    // Treat mutltiple refs as one child
    let child-to-check = children.at(j)
    if child-to-check.func() == ref or child-to-check.func() == cite or child-to-check.func() == space {
      while (j + 1) < children.len() {
        child-to-check = children.at(j + 1)
        if child-to-check.func() != space and child-to-check.func() != ref and child-to-check.func() != cite {
          break
        }
        j += 1
      }
    }

    let top-part = split-content.top + children.slice(0, (j + 1)).join()
    if (height != measure(top-part, width: top-width).height) {break}
    
    let child-to-check = children.at(j)
    if child-to-check.func() != space {i = j}
    
    j += 1
  }

  let top-splitter = i - 1
  while true {
    let child-to-check = children.at(top-splitter)
    if child-to-check.func() != space and child-to-check.func() != ref and child-to-check.func() != cite {break}
    top-splitter -= 1
  }
  let bottom-splitter = top-splitter + 1
  
  top-sequence = children.slice(0, top-splitter).join()
  let child-to-split = children.at(top-splitter)
  bottom-sequence = children.slice(bottom-splitter, children.len()).join()
    
  let result = split(
    (top: split-content.top + top-sequence, bottom: bottom-sequence + split-content.bottom),
    child-to-split,
    target-is-top,
    target-height,
    top-width,
    bottom-width,
  )

  top-sequence = top-sequence + result.top-part
  bottom-sequence = result.bottom-part + bottom-sequence

  return (top-part: top-sequence, bottom-part: bottom-sequence)
}

#let split-styled(
  split-content,
  styled-to-split,
  target-is-top,
  target-height,
  top-width,
  bottom-width,
  split
) = {
  let child = styled-to-split.child

  let result = split(
    (top: split-content.top, bottom: split-content.bottom),
    child,
    target-is-top,
    target-height,
    top-width,
    bottom-width
  )

  let top-styled = (result.top-part, styled-to-split.styles)
  let bottom-styled = (result.bottom-part, styled-to-split.styles)

  return (top-part: styled(..top-styled), bottom-part: styled(..bottom-styled))
}

#let split-emph(
  split-content,
  emph-to-split,
  target-is-top,
  target-height,
  top-width,
  bottom-width,
  split
) = {
  let body = emph-to-split.body

  let result = split(
    (top: split-content.top, bottom: split-content.bottom),
    body,
    target-is-top,
    target-height,
    top-width,
    bottom-width
  )

  return (top-part: emph(result.top-part), bottom-part: emph(result.bottom-part))
}

#let split-text(
  split-content,
  text-to-split,
  target-is-top,
  target-height,
  top-width,
  bottom-width,
  split
) = {
  let top-text = text-to-split
  let bottom-text = []

  let words = text-to-split.text.split(" ")

  // Split text
  let a = calc.floor(words.len() / 2)
  let r = true
  let i = a
  let height
  while true {
    if target-is-top {
      let part = split-content.top + words.slice(0, i).join(" ")
      height = measure(part, width: top-width).height
    } else {
      let part = words.slice(i, words.len()).join(" ") + split-content.bottom
      height = measure(part, width: bottom-width).height
    }

    if (calc.odd(a)) {
      if (r) {a += 1}
      r = not r
    }
    a = calc.floor(a / 2)
    if xor(height < target-height, target-is-top) {
      i -= a
    } else {
      i += a
    }
    i = calc.clamp(i, 0, words.len() - 1)

    if (a <= 0) {break}
  }
  // Make sure height one step greater than target-height
  while (height < target-height and i > 0 and i < words.len()) {
    if (target-is-top) {i += 1}
    else {i -= 1}

    if target-is-top {
      let part = split-content.top + words.slice(0, i).join(" ")
      height = measure(part, width: top-width).height
    } else {
      let part = words.slice(i, words.len()).join(" ") + split-content.bottom
      height = measure(part, width: bottom-width).height
    }
  }
  // Add words until line is filled
  let j = i
  while j < words.len() {
    let top-part = split-content.top + words.slice(0, j).join(" ")
    if (height != measure(top-part, width: top-width).height) {break}

    i = j
    j += 1
  }
  
  top-text = words.slice(0, i).join(" ")
  bottom-text = words.slice(i, words.len()).join(" ")

  return (top-part: top-text, bottom-part: bottom-text)
}

#let split(
  split-content,
  content-to-split,
  target-is-top,
  target-height,
  top-width,
  bottom-width,
) = {
  let result = (top-part: content-to-split, bottom-part: [])
  
  assert(content-to-split.func() != ref, message: "content-to-split is a ref. Normally split-sequence should prevent this from happening.")
  assert(content-to-split.func() != cite, message: "content-to-split is a cite. Normally split-sequence should prevent this from happening.")
  assert(content-to-split.func() != space, message: "content-to-split is a space. Normally split-sequence should prevent this from happening.")
  
  if content-to-split.func() == sequence {
    result = split-squence(split-content, content-to-split, target-is-top, target-height, top-width, bottom-width, split)
  } else if content-to-split.func() == styled {
    result = split-styled(split-content, content-to-split, target-is-top, target-height, top-width, bottom-width, split)
  } else if content-to-split.func() == text {
    result = split-text(split-content, content-to-split, target-is-top, target-height, top-width, bottom-width, split)
  } else if content-to-split.func() == emph {
    result = split-emph(split-content, content-to-split, target-is-top, target-height, top-width, bottom-width, split)
  } else if content-to-split.func() == parbreak {
    // Default
  } else {
    panic(content-to-split, content-to-split.func())
  }

  return result
}

#let splitter(
  content-to-split,
  full-width,
  inner-width,
  inner-height,
  has-outer-top,
  has-outer-bottom,
) = {
  let outer-top-part = []
  let inner-part = content-to-split
  let outer-bottom-part = []

  let full-height = measure(inner-part, width: inner-width).height

  if (full-height > inner-height) {
    if has-outer-top and has-outer-bottom {
      let outer-height = (full-height - inner-height) / 2
      let target-height = measure(inner-part, width: full-width).height * (outer-height / full-height)

      let result = split((top: [], bottom: []), inner-part, true, target-height - 1.5em.to-absolute(), full-width, inner-width)
      outer-top-part = result.top-part
      inner-part = result.bottom-part

      result = split((top: [], bottom: []), inner-part, true, inner-height, inner-width, full-width)
      inner-part = result.top-part
      outer-bottom-part = result.bottom-part
    } else if has-outer-top {
      let result = split((top: [], bottom: []), inner-part, false, inner-height, full-width, inner-width)
      outer-top-part = result.top-part
      inner-part = result.bottom-part
    } else if has-outer-bottom {
      let result = split((top: [], bottom: []), inner-part, true, inner-height, inner-width, full-width)
      inner-part = result.top-part
      outer-bottom-part = result.bottom-part
    }
  }

  return (inner: inner-part, outer-top: outer-top-part, outer-bottom: outer-bottom-part)
}
