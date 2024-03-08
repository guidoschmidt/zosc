[![CI](https://github.com/guidoschmidt/zosc/actions/workflows/build.yml/badge.svg)](https://github.com/guidoschmidt/zosc/actions/workflows/build.yml)

# OSC Open Sound Control package for [zig](https://ziglang.org/)

Target zig version: `0.12.0-dev.2063+804cee3b9`

### Features
- [x] OSC Messages
- [x] OSC Arguments 
  - [x] integer, i32
  - [x] float, f32
  - [ ] OSC-string
  - [ ] OSC-blob

### Examples
- `zig build server` to run an OSC server example
- `zig build client` to run an OSC client example, which sends a sine wave as OSC message to
  `/ch/1`
- Open [`vcv/receive-osc.vcv`](./vcv) in [VCV Rack 2](https://vcvrack.com/Rack)
  to receive messages from `zig build client`

### Links & References
- [OSC Specifications](https://opensoundcontrol.stanford.edu/)
