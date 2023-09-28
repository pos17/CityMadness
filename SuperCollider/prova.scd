(
var samplePath = thisProcess.nowExecutingPath.dirname +/+ "/recordings";
~buf_r =Buffer.readChannel(s, samplePath +/+ "./CR_Duomo_Corner.WAV", channels:[1]);

~a =Buffer.read(s, samplePath +/+ "/CR_PRoma2.WAV");
~b =Buffer.read(s, samplePath +/+ "/CR_Duomo_Corner.WAV");
~c =Buffer.read(s, samplePath +/+ "/CR_MarketWalk.WAV");
~d =Buffer.read(s, samplePath +/+ "/CR_PStradivari_Corner.WAV");
)

~busss = Bus.audio(s,2);


SynthDef.new(\reverb,{
	arg in;
	var d = in;
	var diffusion = \diffusion.kr(50);
	var spacesize = \spacesize.kr(30);
	d = In.ar(d,1);
	8.do { |i|
		d = AllpassC.ar(
			d,
			delaytime: LFNoise1.kr(0.01!2).range(0.01, spacesize),
			decaytime: diffusion
		)
	};

	Out.ar([0,1],d);
}).add;

SynthDef.new(\buffer_play,{
		arg outBus, ampA=0.25, ampB=0.25, ampC=0.25, ampD=0.25;
		var sigA, sigB, sigC, sigD;

		sigA = PlayBuf.ar(2, ~a.bufnum, BufRateScale.kr(~a.bufnum), loop:1);
		sigB = PlayBuf.ar(2, ~b.bufnum, BufRateScale.kr(~b.bufnum), loop:1);
		sigC = PlayBuf.ar(2, ~c.bufnum, BufRateScale.kr(~c.bufnum), loop:1);
		sigD = PlayBuf.ar(2, ~d.bufnum, BufRateScale.kr(~d.bufnum), loop:1);

		Out.ar(outBus,sigA*ampA);
		Out.ar(outBus,sigB*ampB);
		Out.ar(outBus,sigC*ampC);
		Out.ar(outBus,sigD*ampD);
	}).add;

h = Synth.newPaused(\buffer_play,[\outBus,~buss]);
~r = Synth.new(\reverb,[\in,~buss],s,\addToTail);




(
SynthDef(\lofi_soundscape,
	{
		arg outBus, ampA, ampB, ampC, ampD, fcval=16000, resgain=0;
		var nfilters = 6;
		var sig;
		var shrate = \shrate.kr(22050).lag(1);
		//var in = PlayBuf.ar(2, ~b.bufnum, BufRateScale.kr(~b.bufnum), loop:1);
		var sigA = PlayBuf.ar(2, ~a.bufnum, BufRateScale.kr(~a.bufnum), loop:1);
		var sigB = PlayBuf.ar(2, ~b.bufnum, BufRateScale.kr(~b.bufnum), loop:1);
		var sigC = PlayBuf.ar(2, ~c.bufnum, BufRateScale.kr(~c.bufnum), loop:1);
		var sigD = PlayBuf.ar(2, ~d.bufnum, BufRateScale.kr(~d.bufnum), loop:1);

		var in = Mix.ar([sigA*ampA,sigC*ampC,sigC*ampC,sigD*ampD]);
		//var in = WhiteNoise.ar(0.1);  //
		var dw;
		var trigFreq = LFDNoise3.ar(shrate * \jitterScale.kr(1) !2).range(shrate * ( 1 - \jitter.kr(0.1)), shrate);
		var trig = Impulse.ar(trigFreq);


		sig = Latch.ar(in, trig);

		sig = Slew.ar(sig, \slewrate.kr(4410), \slewrate.kr);

		nfilters.do { |i| // steep LPF
			sig = LPF.ar(sig, ( shrate * \lpfscale.kr( 0.25 ) ).clip(100, SampleRate.ir * 0.45), mul:1.2).atan;
		};

		sig = HPF.ar(sig, \hpf.kr(100));

		sig = MoogFF.ar(sig, MouseY.kr(100, 10000, 1), MouseX.kr(0, 4));

			dw = \drywet.kr(1);
		/*Mix([
		in * ( 1 - dw.abs ),
		sig * dw
		]);*/
		Out.ar([0,1],(Mix([
			in * ( 1 - dw.abs ),
			sig * dw
		])))

	}
).add;

)


~x = Synth.newPaused(\lofi_soundscape,['shrate',491.25,'drywet', 1,'lpfscale', 6.92,'slewrate', 22050,'jitter',0.03,'hpf',166.07,'ampA',0.25,'ampB',0.25,'ampC',0.25,'ampD',0.25]);

~x.run;
~x.set(\fcval,12000,\regain,1);
~x.set(\fcval,8000,\regain,2);
~x.set(\fcval,100,\regain,3);

(
{
    var trate, dur, rate;
    trate = MouseY.kr(2,200,1);
    dur = 4 / trate;
    rate = Dseq([10, 1, 1, 0.5, 0.5, 0.2, 0.1], inf);
    TGrains.ar(2, Impulse.ar(trate), ~b, rate, MouseX.kr(0,BufDur.kr(~b)), dur, Dseq([-1, 1], inf), 0.1, 2);
}.play;
)


(
SynthDef(\grain_synth,{|outBus,loop = 0,amp=1,gate=1|
		var sigL,sigR, trate, dur, rate;
		trate = MouseY.kr(2,200,1);
		dur = 4/trate;
		rate = Dseq([1, 1, 1, 0.5, 0.5, 0.2, -1], inf);
		sigR = TGrains.ar(1, Impulse.ar(trate), ~buf_r, rate, MouseX.kr(0,BufDur.kr(~buf_r)), dur, Dseq([-1,1,inf]), 0.9, 2);
		sigR = Pan2.ar(sigR,LFNoise1.kr(10));
		Out.ar(outBus,sigR*amp);
	}).play;

)