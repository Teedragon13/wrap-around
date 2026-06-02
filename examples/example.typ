
#import "../src/wrapper.typ": wrap

#set par(justify: true)

#wrap()[
  #lorem(200)
][
  #figure(caption: "Some figure",
    box(fill: red, width: 100%, height: 5cm)
  )
]
