s.boot;
Server.killAll;
(
var samplePath = thisProcess.nowExecutingPath.dirname +/+ "/recordings";
~buf_r =Buffer.readChannel(s, samplePath +/+ "./CR_Duomo_Corner.WAV", channels:[1]);

~a =Buffer.read(s, samplePath +/+ "/CR_PRoma2.WAV");
~b =Buffer.read(s, samplePath +/+ "/CR_Duomo_Corner.WAV");
~c =Buffer.read(s, samplePath +/+ "/CR_MarketWalk.WAV");
~d =Buffer.read(s, samplePath +/+ "/CR_PStradivari_Corner.WAV");
~i =Buffer.read(s, samplePath +/+ "/InterestPoint.WAV");
)

(
s.waitForBoot({
	var right, left,bass;
	var n0, n1, n2;
	var note_getter;
	~n1 = NetAddr.new("127.0.0.1",57120);
	NetAddr.localAddr;
	~note_table = 0!127;
	~n = nil;

	/*~lvl_music = 0;
	~lvl_sc = 0;
	~lvl_grain = 0;
	~fcval = 0;*/
	//~master = Bus.audio(s,2);


	//Bus
	~scBus = Bus.audio(s,2);
	~reverbBus = Bus.audio(s,2);
	~lvl1 = Bus.audio(s,2);
	~lvl2 = Bus.audio(s,2);
	~lvl3 = Bus.audio(s,2);

	s.latency = nil;


	SynthDef.new(\synthLvl,{
		arg inA, outBus, ampA=0;
		var sig;
		sig = In.ar(inA,2);

		sig = sig*ampA;

		Out.ar(outBus,sig);
	}).add;

	SynthDef.new(\reverb,{
		arg in, fcvalue=16000;
		var d = in;
		var diffusion = \diffusion.kr(50);
		var spacesize = \spacesize.kr(30);
		//var diffusion = \diffusion.kr(1);
		//var spacesize = \spacesize.kr(1);
		d = In.ar(d,1);
		8.do { |i|
			d = AllpassC.ar(
				d,
				delaytime: LFNoise1.kr(0.01!2).range(0.01, spacesize),
				decaytime: diffusion
			)
		};

		Out.ar([0,1],MoogFF.ar(d,fcvalue, 1));
	}).add;

	SynthDef(\lofi_soundscape,
		{
			arg outBus, outBus2, ampA, ampB, ampC, ampD, fcval=16000, resgain=0, wetval=1,ampOut=1;
			var nfilters = 6;
			var sig;
			var shrate = \shrate.kr(22050).lag(1);
			//var in = PlayBuf.ar(2, ~b.bufnum, BufRateScale.kr(~b.bufnum), loop:1);
			var sigA = PlayBuf.ar(2, ~a.bufnum, BufRateScale.kr(~a.bufnum), loop:1);
			var sigB = PlayBuf.ar(2, ~b.bufnum, BufRateScale.kr(~b.bufnum), loop:1);
			var sigC = PlayBuf.ar(2, ~c.bufnum, BufRateScale.kr(~c.bufnum), loop:1);
			var sigD = PlayBuf.ar(2, ~d.bufnum, BufRateScale.kr(~d.bufnum), loop:1);

			var in = Mix.ar([sigA*ampA,sigB*ampB,sigC*ampC,sigD*ampD]);
			//var in = WhiteNoise.ar(0.1);  //
			var dw,outsig,dryval;
			var trigFreq = LFDNoise3.ar(shrate * \jitterScale.kr(1) !2).range(shrate * ( 1 - \jitter.kr(0.1)), shrate);
			var trig = Impulse.ar(trigFreq);


			sig = Latch.ar(in, trig);

			sig = Slew.ar(sig, \slewrate.kr(4410), \slewrate.kr);

			nfilters.do { |i| // steep LPF
				sig = LPF.ar(sig, ( shrate * \lpfscale.kr( 0.25 ) ).clip(100, SampleRate.ir * 0.45), mul:1.2).atan;
			};
			//ampOut = wetval;
			dryval = 1 - wetval;

			sig = HPF.ar(sig, \hpf.kr(100));

			dw = \drywet.kr(1);

			outsig = (Mix([in * ( 1 - dw.abs ),sig * dw]))*ampOut;
			/*Mix([
			in * ( 1 - dw.abs ),
			sig * dw
			]);*/

			Out.ar(outBus,outsig*1);
			//Out.ar(outBus,outsig*wetval);
			//Out.ar([0,1],outsig*dryval);
		}
	).add;

	SynthDef(\grain_synth,{|outBus,loop = 0,ampOut=1,gate=1,agit|
		var sigL,sigR, trate, dur, rate;
		trate = MouseY.kr(2,200,1);
		dur = 4/200;
		rate = Dseq([1, 1, 1, 0.5, 0.5, 0.2, -1], inf);
		sigR = TGrains.ar(1, Impulse.ar(trate), ~buf_r, rate, BufDur.kr(~buf_r), dur, Dseq([-1,1,inf]), 0.9, 2);
		sigR = Pan2.ar(sigR,LFNoise1.kr(10));
		Out.ar(outBus,sigR*ampOut);
	}).add;

	SynthDef(\sub,{
		arg midinote,cutoff=350, decay=1,outBus;
		var env, sig, ampSynth=0.4;
		env = EnvGen.kr(Env.new([0,1,0.8,0],[0.5,1,2],[0.5,-50]),doneAction:2);
		sig = RLPF.ar(Saw.ar(midinote.midicps,ampSynth),cutoff)*env;
		sig = CombC.ar(sig,1,0.125,decay);
		Out.ar(outBus,sig);
	}).add;

	SynthDef(\sin_pulsar, {
		arg outBus,lev, formantA, formantB, overlapA, overlapB,levA, levB,ampOut;
		var a,b,c,d,e,f, f_ ,t;

		//lev = \lev.kr(0.3);
		f = \freq.kr(440);
		f_ = f.clip(50, 1500);



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
			a * ( levA * e ).pow(f_.linlin( 50, 1500, 1.1, 1.5)) * lev,
			b * ( levB * e ).pow(f_.linlin( 50, 1500, 1.5, 2.5)) * lev,
		]);

		//c = FreeVerb.ar(in:c, mix:0.6, room:0.7, damp:1);

		c = LeakDC.ar(c* 0.45);

		c = Pan2.ar(c, Rand(-1,1));

		Out.ar(outBus, c*ampOut)
	}).store;

	SynthDef(\interestPoint, {| out = 0, bufnum = 0 |
		Out.ar(out,
			PlayBuf.ar(2, ~i, BufRateScale.kr(~i), loop: 1.0)
		)
	}).add;

	~x = Synth.newPaused(\lofi_soundscape,[\outBus,~reverbBus,'shrate',491.25,'drywet', 0.95,'lpfscale', 6.92,'slewrate', 22050,'jitter',0.03,'hpf',166.07,'ampA',0.25,'ampB',0.25,'ampC',0.25,'ampD',0.25]);
	~t = Synth.newPaused(\grain_synth,[\outBus,~reverbBus,\ampOut,~lvl_grain]);
	~v = Synth.newPaused(\interestPoint, [\out, [0,1], \bufnum, ~i]);
	~y = Synth.new(\synthLvl,[\inA,~lvl1,\ampA,~lvl_music,\outBus,~reverbBus],s,\addToTail);
	~r = Synth.new(\reverb,[\in,~reverbBus,\fcvalue,~fcval],s,\addToTail);

	OSCdef.new(\musicVol,{
		arg msg;
		~lvl_music = msg[1];
		postln("music vol:");
		msg[1].postln;

		~y.set(\ampA,~lvl_music);

	},
	path:"/musicVol"
	);

	OSCdef.new(\scVol,{
		arg msg;
		postln("sc vol:");
		msg[1].postln;
		~lvl_sc = msg[1];
		~x.set(\ampOut,~lvl_sc);
	},
	path:"/scVol"
	);

	OSCdef.new(\grainVol,{
		arg msg;
		postln("grain vol:");
		msg[1].postln;
		~lvl_grain = msg[1];
		~t.set(\ampOut,~lvl_grain);
	},
	path:"/grainVol"
	);

	OSCdef.new(\fcVal,{
		arg msg;
		~fcval = msg[1];
		//postln(msg[1]);
		~r.set(\fcvalue,~fcval);
	},
	path:"/fcVal"
	);

	OSCdef.new(\synthAgit,{
		arg msg;
		~agitVal= msg[1].linlin(0,1,0,BufDur.kr(~buf_r));

	},
	path:"/synthAgit"
	);

	/*OSCdef.new(\snrVal,{
		arg msg;
		var dw;

		dw = msg[1]/10;
		~lvl_synth = 1-(msg[1]/10);
		~x.set('drywet',dw);
		~y.set(\amp,~lvl_music);
		~t.stop;
	},
	path:"/snrVal"
	);*/

	OSCdef.new(\noiseOn,{
		arg msg;

		~x.run;
		~t.run;
		postln(msg[1]);
	},
	path:"/noiseOn"
	);

	OSCdef.new(\scMix,{
		arg msg;
		var dw;
		postln(msg);
		//dryrev = 1-(msg[1]+msg[2]+msg[3]+msg[4]);
		dw = msg[1]+msg[2]+msg[3]+msg[4];

		dw.postln;
		~x.set('ampA',1 - msg[1],'ampB',1 - msg[2],'ampC',1 - msg[3],'ampD',1 - msg[4],'drywet',dw,'wetval',dw);

	},
	path:"/scMix"
	);

	OSCdef.new(\arrival,{
		arg msg;
		postln("arrival of point ");
		~v.run;
	},
	path:"/pointArrival"
	);

	OSCdef.new(\noteOn,{
		arg msg, time, addr, port;
		~note_table[msg[1]] = 1;
		~n = ~note_table.selectIndices({|item, i| item != 0});
	},
	path: "/noteOn"
	);

	OSCdef.new(\noteOff,{
		arg msg, time, addr, port;

		~note_table[msg[1]] = 0;
		/*~n = ~note_table.selectIndices({|item, i| item != 0});
		if (~n == []) { ~n = nil; };*/

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

	Pdefn(\ampSynth,1);

	//~seq = [n0,n1,n2].scramble;
	//~seq_dur = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 ].scramble;
	right = Pbind(
		\instrument, \sin_pulsar,
		\midinote, Pseq([ n0, n2, n1, n2] ++ (([ n0, n2, n1, n2] + 12)!2).flatten),
		\dur, Pseq([1, 1, 1, 1, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5 ].normalizeSum*2),
		//\lvl,~lvl_synth,
		\outBus,~lvl1,
		\delta,2,
		//
		\levA,Pdefn(\levA,1),
		\formantA,Pdefn(\formantA,2),
		\overlapB,Pdefn(\overlapB,2),
		\levB,Pdefn(\levB,0.8),
		\lev,Pdefn(\lev,0.3),
		\formantB,Pdefn(\formantB,2),
		\overlapA,Pdefn(\overlapA,2),
	);


	left = Pbind(
		\instrument, \sin_pulsar,
		\midinote, Pseq([ n0, n2, n0, n2, n0, n2, n0, n2] - 12),
		\dur, Pseq([1, 1, 1, 1, 1, 1, 1, 1].normalizeSum*2),
		\outBus,~lvl1,
		\delta, 2,
		//
		\levA,Pdefn(\levA,1),
		\formantA,Pdefn(\formantA,2),
		\overlapB,Pdefn(\overlapB,2),
		\levB,Pdefn(\levB,0.8),
		\lev,Pdefn(\lev,0.3),
		\formantB,Pdefn(\formantB,2),
		\overlapA,Pdefn(\overlapA,2),
	);

	bass = Pbind(
	 	\instrument, \sub,
	 	\midinote, Pseq([ n0, n0, n0, n0, n0, n0, n0, n0] - 24),
		\dur, Pseq([1, 1, 1, 1, 1, 1, 1, 1].normalizeSum*2),
		\delta,2,
		\ampSynth,Pdefn(\ampSynth),
		\cutoff,450,
		\decay,4,
		\outBus,~lvl1,
		\delta,2,
		//
		\levA,Pdefn(\levA,1),
		\formantA,Pdefn(\formantA,2),
		\overlapB,Pdefn(\overlapB,2),
		\levB,Pdefn(\levB,0.8),
		\lev,Pdefn(\lev,0.3),
		\formantB,Pdefn(\formantB,2),
		\overlapA,Pdefn(\overlapA,2),

	 );


	if (~player.notNil) { ~player.stop; };
	~player = Pn(Ppar([right,left,bass])).play;


});
)



(
Pdefn(\levA,1);
Pdefn(\formantA,2);
Pdefn(\overlapB,2);
Pdefn(\levB,0.8);
Pdefn(\lev,0.3);
Pdefn(\formantB,2);
Pdefn(\overlapA,2);
)


(
Pdefn(\levA,0.303);
Pdefn(\formantA,3.6);
Pdefn(\overlapB,0.4);
Pdefn(\levB,0.3);
Pdefn(\lev,0.82);
Pdefn(\formantB,4.27);
Pdefn(\overlapA,2.2);
)

(
Pdefn(\levA,0.2);
Pdefn(\formantA,7.0);
Pdefn(\overlapB,3.6);
Pdefn(\levB,0.23);
Pdefn(\lev,0.92);
Pdefn(\formantB,8.2);
Pdefn(\overlapA,6.2);
)




s.record(duration:20);

s.freeAll;

~t.free;
~x.free;
~r.free;
~y.free;

