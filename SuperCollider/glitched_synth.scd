~n1 = NetAddr.new("127.0.0.1",57120);
NetAddr.localAddr;

OSCFunc.trace(true);
OSCFunc.trace(false);


~notes = Array.newClear(128);

(
f = { |msg, time, addr|
    if(msg[0] != '/status.reply') {
        //"time: % sender: %\nmessage: %\n".postf(time, addr, msg);
    }
};
thisProcess.addOSCRecvFunc(f);


OSCdef.new(\noteOn,{
	arg msg, time, addr, port;
	var note;
	postln("AAAAAAAAAAAAA");
	~notes [msg[1]] = Synth("noiseToPitch", [\freq, msg[1].midicps.postln, \out, 0, \mul, 1]);
	postln("freqqqqq");
	msg[1].midicps.postln


	},
path: "/noteOn"
);

OSCdef.new(\noteOff,{
	arg msg, time, addr, port;
	var note;
	postln("AAAAAAAAAAAAA");
	//~notes [msg[1]] = Synth("noiseToPitch", [\freq, 0, \out, 0, \mul, 1]);
	//~notes [msg[1]].release;
	~notes [msg[1]].free;
	postln("freqqqqq");
	msg[1].midicps.postln


	},
path: "/noteOff"
)


)

// stop posting.
thisProcess.removeOSCRecvFunc(f);



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

SynthDef(\,{
	var snd, freqs, n, scale;
	n=(1..16);
	freqs = \freq.kr(440) * n *XLine.kr(ExpRand(1,8),1,ExpRand(0.001,0.03)) * (SinOsc.ar(ExpRand(0.3,8))*Rand(0,0.2)).midiratio;
	snd = SinOsc.ar(freqs);
	snd = snd*((n*2pi*Line.kr(Rand(0,0.3),Rand(0,0.3),ExpRand(0.01,0.5)))+Rand(0,2pi)).cos;
	snd = snd / n;
	snd = snd.sum;
	snd = (snd * Rand(0.3,2) + Rand(0,1)).fold2;
	snd = RLPF.ar(snd, XLine.kr(1,0.3,ExpRand(0.01,0.3)) * ExpRand(100,8000),ExpRand(0.03,1.0));
	snd = (snd * Rand(0.3,2) + Rand(0,1)).fold2;
	snd = RLPF.ar(snd, XLine.kr(1,0.5,ExpRand(0.01,0.3)) * ExpRand(100,16000),ExpRand(0.1,1));
	snd = Latch.ar(snd,Impulse.ar(Rand(4000,16e3)));
	scale = 2**Rand(3,8);
	snd = (snd *scale).round / scale;
	snd = snd * -10.dbamp;
	snd = snd*Env.perc(ExpRand(0.001,0.03), \decay.kr(1),1,Rand(-8,8)).ar(Done.freeSelf);
	snd = Pan2.ar(snd, Rand(-0.5,0.5));
	Out.ar(\out.kr(0),snd);
}).add;

SynthDef(\beep,{
	var snd, freq, trigger;
	freq = \freq.kr(440) * (2 ** ToggleFF.ar(Impulse.ar(Rand(8,16))));
	trigger = T2A.ar(\trigger.tr);
	snd = (LFPulse.ar(freq)* -0.5)*(LFPulse.ar(freq*TIRand.ar(1,8,trigger))-0.5);
	snd = snd * -5.dbamp;
	snd = snd * Env.asr(0.00,1,0.001).ar(Done.freeSelf, \gate.kr(1));
	snd = Pan2.ar(snd, 0);
	Out.ar(\out.kr(0),snd);
}).add;


SynthDef(\fx,{
	var snd, wet,rate;
	snd = In.ar(\out.kr,2);
	rate = LFNoise2.kr(0.1).linexp(-1,1,0.1,1);
	snd = snd + (
		GVerb.ar(snd.sum * ToggleFF.ar(Dust.ar(rate*3)).lag(0.01),10,3)
		* ToggleFF.ar(Dust.ar(rate*3)).lag(0.01)
	);
	wet = LocalIn.ar(2);
	wet = wet *ToggleFF.ar({Dust.ar(rate)} ! 2).lag(0.01);
	wet = DelayC.ar(wet,1,[0.3,0.2]);
	wet = wet * TRand.ar(0,-10,Dust.ar(rate)).lag(0.01).dbamp;
	wet = LPF.ar(wet,8000);
	wet = HPF.ar(wet,100);
	wet = Latch.ar(snd, Impulse.ar(TExpRand.ar(1000,16e3,Dust.ar(rate))));
	wet =Limiter.ar(wet);
	snd = snd + wet;
	LocalOut.ar(snd);

	snd = SelectX.ar(ToggleFF.ar(Dust.ar(rate*0.2)).lag(0.01),[snd,HPF.ar(snd,1000)* 2.dbamp]);
	snd = SelectX.ar(ToggleFF.ar(Dust.ar(rate*0.2)).lag(0.01),[snd,LPF.ar(snd,1000)* 10.dbamp]);

	snd = LeakDC.ar(snd);
	snd = Limiter.ar(snd);
	ReplaceOut.ar(\out.kr(0),snd);
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
var noteLen = 6;

stack.add(midi);

song.do({
	arg c, i;
	switch (c,
		$N, {
			var f = midi.midicps;
			SystemClock.sched(cursor, {
				//Synth(\fx, [\freq, f, \amp, 0.2 ])
				//Synth(\beep, [\freq, f ])
				Synth("noiseToPitch", [\freq, f, \out, 0, \mul, 1])
				//Synth(\, [freq: f, duration: exprand(0.01,1)*10]);
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



/*

(
var s,scale,chords;
s = Server.default;

scale = [0,2,3,5,7,10];
chords = [
	([0] + (12 * -2)) ++ ([0,7]+(12 * -1)) ++ (scale + (12*0)) ++ (scale + (12 * 1)),
	([-4] + (12 * -2)) ++ ([-4,3]+(12 * -1)) ++ (scale + (12*0)) ++ (scale + (12 * 1)),
];

Routine({
	var chord;
	s.bind{Synth.tail(nil,\fx)};
	chord = chords[0];

	Routine({
		var synth;
		loop {
			rrand(1.0,8.0).wait;
			s.bind{synth = Synth(\beep,[freq:(48+chord).midicps.choose]); };
			rrand(5,10).do{
				s.bind{synth.set(\freq,(48+chord).midicps,\trigger,1)};
				rrand(0.01,0.1).wait;
			};
			s.bind{synth.set(\gate,0);};
		};
	}).play;

	loop{
		chords.do{|argChord|
			chord = argChord;
			100.do{
				var freqs,duration;
				freqs = {(48+chord).midicps.choose } ! ([3,2,1].wchoose([5,2,1].normalizeSum));
				duration = exprand(0.01,1);
				s.bind{
					freqs.do{|freq|
						Synth(\,[freq: freq, decay: duration*10]);
					};
				};
				duration.wait;
			};
		};
	};
}).play;
)*/
