// Instrument

(
SynthDef("noiseToPitch", { arg freq=440, amp=2, mul=1, out = 0;
	var env = Env(levels: [0, 1, 0.5, 0], times: [2, 2, 0.6], curve: [-6,0, 1]);
    Out.ar(
        out,
        Resonz.ar(
            SinOsc.ar(BrownNoise.ar(300, 400)) * mul,
			freq,
			[0.001, 0.001],
			amp * EnvGen.kr(env, doneAction: 2),
            //LFNoise0.kr(4, 110, 660),

        )
    )
}).add;
)

(
// activate left and right channels
Synth("noiseToPitch", [\freq, 220, \out, 0, \mul, 1]);
Synth("noiseToPitch", [\freq, 220, \out, 0, \mul, 1]);
)

(
SynthDef("subtractive", { arg freq = 440, amp = 0.5,out;
    Out.ar(
        out,
        LPF.ar(
            Pulse.ar(freq, 0.5, 0.1),    // the source to be filtered
            Line.kr(8000, 660, 6)        // control the filter frequency with a line
        )
    )
}).add;
)

Synth("subtractive")

(
SynthDef(\sine, {
	arg freq = 440, amp = 0.5;
	Out.ar(0, SinOsc.ar(freq, 0.0, amp * EnvGen.kr(Env.perc(0.01, 0.25), doneAction: 2)) ! 2);
}).add;
)

// Basic Stochastic L-System
(
l = {
arg iterations = 2;

// define your l system
var axiom = "N";
var variables = "N";
var constants = "+-[]<>";
var rules = Dictionary.new();

// accepts both strings and arrays
// if array, it a random entry
rules.put($N, [
	"N[<++++N<+++N]N>" // dom 7 chord
]);

// iterate
iterations.do({
	|i|
	var output = "";

	axiom.do({
		|c, i|
		if (variables.includes(c), {
			if (rules.at(c).isKindOf(String), {
				output = output ++ rules.at(c)
			}, {
				output = output ++ rules.at(c).choose
			})
		});
		if (constants.includes(c), {
			output = output ++ c
		});
	});

	axiom = output;
});
axiom;
}
)

// Play the song
(
var song = l.value(5);
var cursor = 0.0;
var stack = List.new();
var midi = 50;
var noteLen = 2;

stack.add(midi);

song.do({
	arg c, i;
	switch (c,
		$N, {
			var f = midi.midicps;
			SystemClock.sched(cursor, {
				//Synth(\sine, [\freq, f, \amp, 0.2 ])
				//Synth("subtractive", [\freq, f, \amp, 0.2 ]),
				Synth("noiseToPitch", [\freq, f, \out, 0, \mul, 1])
			});
			cursor = cursor + noteLen;
		},
		$+, { midi = midi + 1 },
		$-, { midi = midi - 1 },
		$[, { stack.add(midi) },
		$], { midi = stack.pop() },
		$>, { cursor = cursor + noteLen; },
		$<, { cursor = cursor - noteLen; },
	)
});
)