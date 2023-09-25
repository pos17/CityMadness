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