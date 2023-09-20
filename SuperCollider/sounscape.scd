s.boot;
(
~buf_l =Buffer.readChannel(s, "C:/Users/jcalb/Documents/MAE/2nd year/CPAC/PROJECT/CityMadness/SuperCollider/CR_Duomo_Corner.WAV", channels:[0]);
~buf_r =Buffer.readChannel(s, "C:/Users/jcalb/Documents/MAE/2nd year/CPAC/PROJECT/CityMadness/SuperCollider/CR_Duomo_Corner.WAV", channels:[1]);
~b =Buffer.read(s, "C:/Users/jcalb/Documents/MAE/2nd year/CPAC/PROJECT/CityMadness/SuperCollider/CR_Duomo_Corner.WAV");
)
(
s.waitForBoot({
	var right, left;
	var n0, n1, n2;
	var note_getter;
	~n1 = NetAddr.new("127.0.0.1",57120);
	NetAddr.localAddr;
	~note_table = 0!127;
	~n = nil;

	~master = Bus.audio(s,2);
	~reverbBus = Bus.audio(s,2);


	s.latency = nil;

	SynthDef(\lofi_soundscape,
		{
			arg outBus;
			var nfilters = 6;
			var sig;
			var shrate = \shrate.kr(22050).lag(1);
			var in = PlayBuf.ar(2, ~b.bufnum, BufRateScale.kr(~b.bufnum), loop:1);
			//var in = WhiteNoise.ar(0.1);  /// for lowpass examples
			var dw;
			var trigFreq = LFDNoise3.ar(shrate * \jitterScale.kr(1) !2).range(shrate * ( 1 - \jitter.kr(0.1)), shrate);
			var trig = Impulse.ar(trigFreq);


			sig = Latch.ar(in, trig);

			sig = Slew.ar(sig, \slewrate.kr(4410), \slewrate.kr);

			nfilters.do { |i| // steep LPF
				sig = LPF.ar(sig, ( shrate * \lpfscale.kr( 0.25 ) ).clip(100, SampleRate.ir * 0.45), mul:1.2).atan;
			};

			sig = HPF.ar(sig, \hpf.kr(100));



			dw = \drywet.kr(1);
			/*Mix([
			in * ( 1 - dw.abs ),
			sig * dw
			]);*/
			Out.ar(outBus,Mix([
				in * ( 1 - dw.abs ),
				sig * dw
			]))

		}
	).add;

	SynthDef(\grain_synth,{|outBus,loop = 0, amp = 1,gate=1|
		//var testPos = EnvGen.kr(Env.new(levels:[-1,-1,1,1], times:[5,5,5] ,releaseNode:1), gate:gate);
		var sigL,sigR, trate, dur, rate;
		trate = MouseY.kr(2,200,1);
		dur = 4/trate;
		rate = Dseq([1, 1, 1, 0.5, 0.5, 0.2, -1], inf);
		//sigL = Latch.ar(~buf_l,Impulse.ar(200));
		//sigR = Latch.ar(~buf_r,Impulse.ar(200));
		//sigL = TGrains.ar(1, Impulse.ar(trate), ~buf_l, rate, MouseX.kr(0,BufDur.kr(~buf_l)), dur, Dseq([-1,1,inf]), 0.1, 2);
		sigR = TGrains.ar(1, Impulse.ar(trate), ~buf_r, rate, MouseX.kr(0,BufDur.kr(~buf_r)), dur, Dseq([-1,1,inf]), 0.9, 2);
		//sig = PlayBuf.ar(2, ~duomo_buf, rate=1, loop, doneAction: 2);
		//Out.ar(outL,(testPos.linlin(-1,1,1,0)*FreeVerb.ar(in:sigL, mix:testPos.linlin(-1,1,0,1), room:15, damp:0.01)));
		//Out.ar(outR,(testPos.linlin(-1,1,1,0)*FreeVerb.ar(in:sigR, mix:testPos.linlin(-1,1,0,1), room:15, damp:0.01)));
		//Out.ar(outL,sigL*amp);
		sigR = Pan2.ar(sigR,LFNoise1.kr(10));
		Out.ar(outBus,sigR*amp);
	}).add;



	SynthDef(\pad, {
		arg freq, amp=1, mul=1, outBus, gate = 1;
		var snd, env, echo;
		env = Env(levels: [0, 1, 0.5, 0], times: [1, 1.5, 0.6], curve: [-6,0, 1]);
		snd = Resonz.ar(SinOsc.ar(BrownNoise.ar(300, 400)) * mul,freq,[0.001, 0.001],amp * EnvGen.kr(env,gate, doneAction: 2));
		snd = DelayC.ar(snd,0.01,{Rand(0,0.01)}! snd.size);
		snd = Splay.ar(snd);
		//snd = Latch.ar(snd,Impulse.ar(Rand(8000,16e3)));
		snd = Pan2.ar(snd, Rand(-0.5,0.5));
		Out.ar(outBus,snd*amp);

	}).add;

	SynthDef(\sin_pulsar, {
		arg outBus;
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

		c = FreeVerb.ar(in:c, mix:0.6, room:0.7, damp:1);

		c = LeakDC.ar(c* 0.45);

		c = Pan2.ar(c, Rand(-1,1));

		Out.ar(outBus, c)
	}).add;


	SynthDef.new(\reverb,{
		arg in,outBus;
		var d = in;
		var diffusion = \diffusion.kr(50);
		var spacesize = \spacesize.kr(15);
		d = In.ar(d,1);
		8.do { |i|
			d = AllpassC.ar(
				d,
				delaytime: LFNoise1.kr(0.01!2).range(0.01, spacesize),
				decaytime: diffusion
			)
		};

		Out.ar(outBus,d);
	}).add;

	SynthDef.new(\master,{
		arg in, out=0;
		var sig;
		sig = In.ar(in,2);
		Out.ar(out,sig);
	}).add;


	~x = Synth.newPaused(\lofi_soundscape,[\outBus,~reverbBus.index,'shrate',491.25,'drywet', 0.85,'lpfscale', 6.92,'slewrate', 22050,'jitter',0.03,'hpf',166.07]);
	~t = Synth.newPaused(\grain_synth,[\outBus,~reverbBus.index]);
	~r = Synth.new(\reverb,[\in,~reverbBus,\outBus,~master],s,\addToTail);
	~m = Synth.new(\master,[\in,~master],s,\addToTail);


	OSCdef.new(\noiseOn,{
	~x.set(\lofi_soundscape,[\outBus,~reverbBus.index,'shrate',491.25,'drywet', 0.85,'lpfscale', 6.92,'slewrate', 22050,'jitter',0.03,'hpf',166.07]);
	~t.set(\grain_synth,[\outBus,~reverbBus.index]);
	},
	path:"/noiseOn"
	);



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
	//~seq = [n0,n1,n2].scramble;
	//~seq_dur = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 ].scramble;
	right = Pbind(
		\instrument, \sin_pulsar,
		\midinote, Pseq([ n0, n2, n1, n2]),
		\dur, Pseq([1, 1, 1, 1, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5 ].normalizeSum*2),
		\outBus,~reverbBus,
	);


	left = Pbind(
		\instrument, \sin_pulsar,
		\midinote, Pseq([ n0, n2, n0, n2, n0, n2, n0, n2] - 12),
		\dur, Pseq([2, 2, 2, 2, 2, 2, 2, 2].normalizeSum*2),
		\outBus,~reverbBus,
	);


	if (~player.notNil) { ~player.stop; };
	~player = Pn(Ppar([right,left])).play;


});
)

(
~x.set(\drywet,0.2);
~t.free;
)


~x.free;
s.record(duration:20);

s.freeAll;