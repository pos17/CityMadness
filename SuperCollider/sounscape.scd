s.boot;

(
~buf_l =Buffer.readChannel(s, "C:/Users/jcalb/Desktop/cose sc/CR_Duomo_Corner.WAV", channels:[0]);
~buf_r =Buffer.readChannel(s, "C:/Users/jcalb/Desktop/cose sc/CR_Duomo_Corner.WAV", channels:[1]);
)

(
~b =Buffer.read(s, "C:/Users/jcalb/Desktop/cose sc/CR_Duomo_Corner.WAV");
)

(
Ndef(\lofi_soundscape,
	{
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
		Mix([
			in * ( 1 - dw.abs ),
			sig * dw
		]);


	}
).play;


Ndef(\lofi_soundscape).addSpec(
	\jitterScale, [0.0001,1, \exp],
	\slewrate, [20,22050, \exp],
).gui;

Ndef('lofi_soundscape').set('shrate',1420.75,'drywet', 0.85,'lpfscale', 1.0,'slewrate', 500,'jitter',0.03);
//Ndef('lofi_soundscape').set('lpfscale', 0.98372093023256, 'hpf', 4.2498292124156, 'drywet', 0.86046511627907, 'jitterScale', 0.180224551525, 'shrate', 9303.8311061316, 'jitter', 0.43410852713178, 'slewrate', 2512.0911012046);




SynthDef(\grain_synth,{
	arg outL=0, outR=1, loop = 0, amp = 1,gate=1;
	var testPos = EnvGen.kr(Env.new(levels:[-1,-1,1,1], times:[5,5,5] ,releaseNode:1), gate:gate);
	var sigL,sigR, trate, dur, rate;
    trate = MouseY.kr(2,200,1);
    dur = 4/trate;
    rate = Dseq([1, 1, 1, 0.5, 0.5, 0.2, -1], inf);
	//sigL = Latch.ar(~buf_l,Impulse.ar(200));
	//sigR = Latch.ar(~buf_r,Impulse.ar(200));
	sigL = TGrains.ar(1, Impulse.ar(trate), ~buf_l, rate, MouseX.kr(0,BufDur.kr(~buf_l)), dur, Dseq([-1,1,inf]), 0.1, 2);
	sigR = TGrains.ar(1, Impulse.ar(trate), ~buf_r, rate, MouseX.kr(0,BufDur.kr(~buf_l)), dur, Dseq([-1,1,inf]), 0.1, 2);
	//sig = PlayBuf.ar(2, ~duomo_buf, rate=1, loop, doneAction: 2);
	Out.ar(outL,(testPos.linlin(-1,1,1,0)*FreeVerb.ar(in:sigL, mix:testPos.linlin(-1,1,0,1), room:15, damp:0.01)));
	Out.ar(outR,(testPos.linlin(-1,1,1,0)*FreeVerb.ar(in:sigR, mix:testPos.linlin(-1,1,0,1), room:15, damp:0.01)));
}).add;

//MouseX.kr(0,BufDur.kr(~buf_l))
t = Synth("grain_synth");
Ndef(\lofi_soundscape).fadeTime = 4;
)

(
Ndef('lofi_soundscape').xset('drywet', 0.6,'lpfscale', 0.1,'slewrate', 500,'hpf',3321.32,'lpfscale',0.1,'shrate',84.57);
t.set(\gate,0);
)
//t.free;


