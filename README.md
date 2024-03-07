# Open Sound Control package for [zig](https://ziglang.org/)

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
