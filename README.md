[![CI](https://github.com/guidoschmidt/zosc/actions/workflows/build.yml/badge.svg)](https://github.com/guidoschmidt/zosc/actions/workflows/build.yml)

# zosc
### Open Sound Control package for [zig](https://ziglang.org/)

Target zig version: `0.12.0`

### Features
- [x] OSC Messages
- [x] OSC Arguments 
  - [x] integer, i32
  - [x] float, f32
  - [ ] OSC-string
  - [ ] OSC-blob

### Examples
- `zig build exapmles/server` to run an [OSC server example](src/examples/server.zig)
- `zig build exapmles/client` to run an [OSC client example](src/examples/client.zig), which sends a sine wave as OSC message to
  `/ch/1`
- Open [`vcv/receive-osc.vcv`](./vcv) in [VCV Rack 2](https://vcvrack.com/Rack)
  to receive messages from `zig build client`

### Links & References
- [OSC Specifications](https://opensoundcontrol.stanford.edu/)
