~n1 = NetAddr.new("127.0.0.1",57120);
NetAddr.localAddr;
~newnote = Array.newClear(128);
(
SynthDef(\pad, { arg freq=261, amp=2, mul=1, out = 0, gate = 1;
	var snd, env, echo;
	env = Env(levels: [0, 1, 0.5, 0], times: [1, 1.5, 0.6], curve: [-6,0, 1]);
	snd = Resonz.ar(SinOsc.ar(BrownNoise.ar(300, 400)) * mul,freq,[0.001, 0.001],amp * EnvGen.kr(env,gate, doneAction: 2));
	snd = DelayC.ar(snd,0.01,{Rand(0,0.01)}! snd.size);
	snd = Splay.ar(snd);
	//snd = Latch.ar(snd,Impulse.ar(Rand(8000,16e3)));
	snd = Pan2.ar(snd, Rand(-0.5,0.5));
	Out.ar(out,snd);

}).add;
)
(
OSCdef.new(\noteOn,{
	arg msg, time, addr, port;
	var note;
	~newnote[msg[1]] = Synth.new(\pad, [\freq, msg[1].midicps,\gate,1, \out, 0, \mul, 1]);
	postln("on");
	},
path: "/noteOn"
);

OSCdef.new(\noteOff,{
	arg msg, time, addr, port;
	var note;
	~newnote[msg[1]] = Synth.new(\pad, [\freq, msg[1].midicps,\gate, 0,\out, 0, \mul, 1]);
	postln("off");
	~newnote[msg[1]].free
	},
path: "/noteOff"
);

)
(
var echo;
echo = {
		// using CombC as an echo device
	{{(CombC.ar(Decay.ar(Dust.ar(0.1,0.5), LFTri.kr(0.11).range(0.5,0.7), BrownNoise.ar), 0.5, LFTri.ar(0.1).range(0.2,0.4), 0.8)  +
	   CombC.ar(Decay.ar(Dust.ar(0.1,0.5), LFTri.kr(0.13).range(0.2,0.3), Resonz.ar(WhiteNoise.ar)), 0.5, LFTri.kr(0.1).range(0.2,0.4), 0.5))}!2}
	};

Ndef(\percussion,echo).play;
)

(
SynthDef(\bg_forest,{
	arg cosa = 9;
	var snd;
	snd = {CombC.ar(Formant.ar(LFNoise0.kr([1,0.7],8,cosa),LFNoise0.kr([1,0.7],4e3,4e3),200,0.3))};
	snd = Pan2.ar(snd,1);
	Out.ar(0,snd);
}).play
)

Synth(\bg_forest,[\cosa,9]);



