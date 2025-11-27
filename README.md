[![CI](https://github.com/guidoschmidt/zig-osc/actions/workflows/build.yml/badge.svg)](https://github.com/guidoschmidt/zig-osc/actions/workflows/build.yml)

# zig-osc
### Open Sound Control package for [zig](https://ziglang.org/)

### Features
- [x] OSC Messages
- [x] OSC Arguments 
  - [x] integer, i32
  - [x] float, f32
  - [x] OSC-string
  - [ ] OSC-blob

### Examples
All examples live in their own subfolder inside [examples](examples/).
Building and running an example is just about:
```
cd examples/client
zig build
zig build run
```
  
### Acknowledgements
`zig-osc` wouldn't be possible without the great work on
[`zig-network`](https://github.com/MasterQ32/zig-network), thanks to [Felix
Queißner (@ikskuh)](https://github.com/ikskuh) and all contributors. Please
consider a star or sponsorship on the [zig-network repository](https://github.com/MasterQ32/zig-network).

### Links & References
- [OSC Specifications](https://opensoundcontrol.stanford.edu/)
- [Features and Future of Open Sound](https://opensoundcontrol.stanford.edu/files/2009-NIME-OSC-1.1.pdf)
