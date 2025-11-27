// 1. Start audio server with Cmd + B

// Attempt to open 1121
thisProcess.openUDPPort(1121);
// List all open ports
thisProcess.openPorts;

// Create a simple synth
SynthDef(\zigsynth, { |out|
    Out.ar(out, SinOsc.ar(
		\freq.kr(440, 4) + [0, 1], 0,
		Decay2.kr(\trig.tr, 0.005, 1.0),
		\pan.kr(0),
	));
}).add;
z = Synth(\zigsynth);
z.set(\trig, 1);

// Create an OpenSound processing function
o = OSCdef(\oscin, {
	arg msg;
	msg[0].postln; // address
	z.set(\trig, 1);
	z.set(\trig, 1, \freq, msg[1]);
	z.set(\trig, 1, \freq, msg[1], \pan, msg[2]);
}, '/zigsynth');

// Cleanup the OSC function
o.free;

// Stop all synths
CmdPeriod.run;