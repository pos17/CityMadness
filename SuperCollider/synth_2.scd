s.boot;
NetAddr.localAddr;
(
~n = NetAddr("127.0.0.1", NetAddr.langPort);
NetAddr.localAddr;

s.latency = nil;            // for immediate response;

~grainsin_pulsar = ~grainsin_pulsar ? ();

~grainsin_pulsar[\name] = \grainsin_pulsar;
~grainsin_pulsar[\midiChannel] = 0;
// ~grainsin_pulsar[\midiSrcID] =  2097152;

Ndef( ~grainsin_pulsar[\name] ).clear;
Ndef( ~grainsin_pulsar[\name] ).ar(2);



SynthDef(\sin_pulsar, { |out=0|
	var a,b,c,d,e,f, f_ ,t,lev, formantA, formantB, overlapA, overlapB;

	lev = \lev.kr(0.3);
	f = \freq.kr(440);
	f_ = f.clip(50, 1500);

	formantA = \formantA.kr(2);
	formantB = \formantB.kr(6);
	overlapA = \overlapA.ar(2);
	overlapB = \overlapB.kr(2);

	e = EnvGen.kr(
		Env.perc(
			// attackTime: ( f_.linlin( 50, 1500, 0.02, 0.005) ),
			attackTime: 0.001,
			releaseTime: Rand(0.1,3.3)
			// releaseTime: 0.5,
		),
		gate: \gt.kr(1),
		doneAction: 2
	);

	// c = e * SinOsc.ar(f*3!2);	//test

	e = e * PinkNoise.ar(1!2).range( 0.1, 1 ).lag(0.02) ;

// c = WhiteNoise.ar(0.2!2);
// c = SinOsc.ar(100,0,0.5!2);

	a = GrainSin.ar(
		numChannels: 1,
		trigger: Impulse.ar(f),
		// dur:  overlapA * ( 1.05 - e.pow(0.5) )
		dur:  overlapA * ( 0.05 + e.pow(0.5) )
		* SinOsc.ar(e * 6, {Rand(0, 6.28)}.dup).range(0.87,1.15)
		/ f,
		freq: f *
		( formantA  * SinOsc.ar(7 * e, {Rand(0, 6.28)}.dup).range(0.9,1.1) ),
		pan: PinkNoise.ar(0.5!2),
	);


	b = GrainSin.ar(
		numChannels: 1,
		trigger: Impulse.ar(f + Rand(-3,3)),
		// dur:  overlapB * ( 1.05 - e.pow(0.5) )
		dur:  overlapB * ( 0.05 + e.pow(0.5) )
		*SinOsc.ar(e * 2, {Rand(0, 6.28)}.dup).range(0.87,1.15)
		/ f,
		freq: f *
		( formantB * SinOsc.ar(e * 3, {Rand(0, 6.28)}.dup).range(0.9,Rand(1,1.5)) ),
		pan: PinkNoise.ar(0.5!2),
	);


	c = GrainSin.ar(
		numChannels: 1,
		trigger: Impulse.ar(f),
		// dur: Rand(0.5,2)  * ( 0.05 + e.pow(0.5) )
		dur: 1.5  * ( 0.05 + e.pow(0.5) )
		*SinOsc.ar(e * 6, {Rand(0, 6.28)}.dup).range(0.87,1.15)
		/ f,
		freq: f
		* SinOsc.ar(e * 8, {Rand(0, 6.28)}.dup).range(0.9,Rand(1,1.5))
		,
		pan: PinkNoise.ar(0.5!2),
	);

	c = Mix([
		c * ( e ).pow(0.7),
		a * ( \levA.kr(1) * e ).pow(f_.linlin( 50, 1500, 1.1, 1.5)) * lev,
		b * ( \levB.kr(0.8) * e ).pow(f_.linlin( 50, 1500, 1.5, 2.5)) * lev,
	]);


	c = LeakDC.ar(c* 0.45);



    Out.ar(out, c)
}).add;
)




(
Ndef( ~grainsin_pulsar[\name]).prime( \sin_pulsar );

/// .....prime() is same as
 //Ndef( ~grainsin_pulsar[\name], \sin_pulsar);
// But without starting the synth


//////// reverb

Ndef( ~grainsin_pulsar[\name] ).put( 150, \filter -> { arg in;
	var d = in;
	var diffusion = \diffusion.kr(1);
	var spacesize = \spacesize.kr(0.1);
	8.do { |i|
		d = AllpassC.ar(
			d,
			delaytime: LFNoise1.kr(0.01!2).range(0.01, spacesize),
			decaytime: diffusion
		)
	};

	d

});



//////// SPECS

Ndef( ~grainsin_pulsar[\name]).addSpec(
	\lev, \amp,
	\freq, \freq,
	\formantA, [1,7],
	\formantB, [1,7],
	\overlapA, [0.01, 20,\exp],
	\overlapB, [0.01, 20,\exp],
	\levA, [0.01, 3,\exp],
	\levB, [0.01, 3,\exp],
	\gt, \gt,
	\diffusion, [0.0001, 4],
	\spacesize, [0.02, 0.2],
).edit;


)

Ndef(~grainsin_pulsar.name).objects


(
OSCdef.new((~grainsin_pulsar[\name] ++ "_On").asSymbol,{
	arg msg;
	Ndef(~grainsin_pulsar[\name]).put(
		msg[1],
		Ndef(~grainsin_pulsar[\name]).source,
		0,
		[\freq, msg[1].midicps, \gt, 1, \lev, 1]
		);
	msg[1] = msg[1] - 12;
	Ndef(~grainsin_pulsar[\name]).put(
		msg[1],
		Ndef(~grainsin_pulsar[\name]).source,
		0,
		[\freq, msg[1].midicps, \gt, 1, \lev, 1]
		);
	postln(msg[1]);
	},
path: "/noteOn"
);

OSCdef.new((~grainsin_pulsar[\name] ++ "_off").asSymbol,{
	arg msg;
	Ndef( ~grainsin_pulsar[\name] ).removeAt( msg[1] );
	//postln("off");
	},
path: "/noteOff"
);
)



//Arpeggio, ancora non funziona bene
/*
(
s.waitForBoot({
 var right, left;
 var n0, n1, n2;
 var note_getter;
	~n1 = NetAddr.new("127.0.0.1",57120);
	NetAddr.localAddr;
 ~note_table = 0!127;
 ~n = nil;

 OSCdef.new(\noteOn,{
	arg msg, time, addr, port;
	var note;
	~note_table[msg[1]] = 1;
	//~note_table[msg[1]] = Synth.new(\pad, [\freq, msg[1].midicps,\gate,1, \out, 0, \mul, 1]);
	~n = ~note_table.selectIndices({|item, i| item != 0});
		postln(msg[1]);
	},
path: "/noteOn"
);

OSCdef.new(\noteOff,{
	arg msg, time, addr, port;
	var note;
	//~note_table[msg[1]] = Synth.new(\pad, [\freq, msg[1].midicps,\gate, 0,\out, 0, \mul, 1]);
	~note_table[msg[1]] = 0;
		postln(msg[1]);
	},
path: "/noteOff"
);

 note_getter = {
  | index |
  Plazy {
   if (~n.isNil) {
    Pseq([Rest(1)]);
   } {
    ~n[index] ?? (~n[0] ?? Pseq([Rest(1)]));
   };
  };
 };

	n0 = note_getter.(0);
	n1 = note_getter.(1);
	n2 = note_getter.(2);
	~seq = [n0,n1,n2].scramble;
	~seq_dur = [1, 1, 1, 1, 0.5, 0.5, 2, 0.5, 0.5, 2, 0.5, 0.5 ].scramble;
		right =
		Pbind(
			\instrument, \sin_pulsar,
			\midinote, Pseq(~seq ++ ((~seq + 12)!2).flatten),
			\dur, Pseq(~seq_dur.normalizeSum*2)
		);

		left =
		Pbind(
			\instrument,\sin_pulsar,
			\midinote, Pseq([ n0, n2, n0, n2, n0, n2, n0, n2] - 12),
			\dur, Pseq([1, 1, 1, 1, 1, 1, 1, 1].normalizeSum*2)
		);

 if (~player.notNil) { ~player.stop; };

	~player = Pn(Ppar([right,left])).play;

});
)

*/
Ndef('grainsin_pulsar').set('levA', 0.49765180538124, 'formantA', 6.007874015748, 'levB', 0.31759720095202, 'spacesize', 0.16952380952381, 'overlapB', 1.0651340032941, 'wet150', 0.34391534391534, 'lev', 0.19443238886478, 'formantB', 3.2204724409449, 'diffusion', 1.6931793650794, 'overlapA', 1.8253052748325, 'freq', 69.877455494983);

