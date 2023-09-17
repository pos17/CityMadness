NetAddr.localAddr;
NetAddr.disconnectAll;
NetAddr.connections;
~n1 = NetAddr.new("127.0.0.1",57120);
NetAddr.localAddr;
(
//Server booting
if(s.hasBooted==false,{s.boot}, {s.reboot});

s.doWhenBooted({
s.latency=0; //Set server latency
~n1 = NetAddr.new("127.0.0.1",57120);

/*
OSCFunc.trace(true);
OSCFunc.trace(false);
*/
~dry = Array.newClear(128);
//Global Arrays
//Constant scale array definition
~scaleThird = Array.new(12);
~scaleFifth = Array.new(12);
~scaleSixth = Array.new(12);
~scaleSeventh = Array.new(12);
//Temporary array definition
~tmpThird = Array.new(12);
~tmpFifth = Array.new(12);
~tmpSixth = Array.new(12);
~tmpSeventh = Array.new(12);
~tmp2Third = Array.new(12);

//Scale arrays initialization
//C Ionian scale intervals: 0 = major/perfect , 1 = minor/diminished
~scaleThird = [0,1,1,0,1,0,1,0,1,1,0,1];
~scaleFifth = [0,1,0,1,0,0,1,0,1,0,0,1];
~scaleSixth = [0,1,0,1,0,0,1,0,0,1,0,1];
~scaleSeventh = [0,0,1,0,1,0,0,1,0,1,0,1];
//Temporary arrays initialization
//These arrays are changed in the GUI section
~tmpThird = [0,1,1,0,1,0,1,0,1,1,0,1];
~tmpFifth = [0,1,0,1,0,0,1,0,1,0,0,1];
~tmpSixth = [0,1,0,1,0,0,1,0,0,1,0,1];
~tmpSeventh = [0,0,1,0,1,0,0,1,0,1,0,1];

//Buffers
//Server buffers loaded with intervals scale array. Loaded with Ionian sequence at the beginning
~bufThird = Buffer.loadCollection(s, ~scaleThird,1);
~bufFifth = Buffer.loadCollection(s, ~scaleFifth,1);
~bufSixth = Buffer.loadCollection(s, ~scaleSixth,1);
~bufSeventh = Buffer.loadCollection(s, ~scaleSeventh,1);

//Busses
~input = Bus.audio(s, 1); //Input bus, microphone output
~thirdOut = Bus.audio(s, 1);
~fifthOut = Bus.audio(s, 1);
~sixthOut = Bus.audio(s, 1);
~seventhOut = Bus.audio(s, 1);
~mixVoices = Bus.audio(s, 1); // Bus from mix of harmonized voices to reverb
~revVoices = Bus.audio(s, 1); // Bus from reverb to delay
~delVoices = Bus.audio(s, 1); // Bus from delay to final mixer
~pitch = Bus.control(s, 1);

~mixerAvol = Bus.control(s, 2);
~mixerBvol = Bus.control(s, 2);
~mixerCvol = Bus.control(s, 2);
~mixerDvol = Bus.control(s, 2);
~mixerEvol = Bus.control(s, 2);

OSCdef.new(\noteOff,{
	arg msg, time, addr, port;
	var note;
	postln("AAAAAAAAAAAAA");
	//~notes [msg[1]] = Synth("noiseToPitch", [\freq, 0, \out, 0, \mul, 1]);
	//~notes [msg[1]].release;
	~notes [msg[1]].free;
	postln("freqqqqq");
	msg[1].midicps.postln

~mixerStripAout = Bus.audio(s, 2);
~mixerStripBout = Bus.audio(s, 2);
~mixerStripCout = Bus.audio(s, 2);
~mixerStripDout = Bus.audio(s, 2);
~mixerStripEout = Bus.audio(s, 2);

~mixerReverbSend = Bus.audio(s, 2);
~mixerDelaySend = Bus.audio(s, 2);

~mixerReverbReturn = Bus.audio(s, 2);
~mixerDelayReturn = Bus.audio(s, 2);


//SYNTHDEFS
/*
SynthDef(\input,{
	var snd;
	snd = Saw.ar(\freq.kr(440))*({LFNoise2.kr(8)} ! 16 * Line.kr(0,0.5,3)).midiratio * [1,2,1,2,1,2,1,2,1,2,1,2,1,2,1]);
	//snd = DelayC.ar(snd,0.01,{Rand(0,0.01)}! snd.size);
	snd = Splay.ar(snd);
	snd = LPF.ar(snd,1000);
	snd = BPeakEQ.ar(snd,\freq.kr(440) * 8,0.1,8);
	snd = snd * Env.asr(1,1,8).ar(Done.freeSelf,\gate.kr(1));
	snd = snd * \amp.kr(-10.dbamp);
	snd = snd ! 2;
	Out.ar(~input,snd);
}).add;
*/
SynthDef(\input, {
	arg freq=440, amp=2, mul=0.1, out = 0, gate =1;
	var snd, freqs;

		snd = Resonz.ar(Saw.ar(BrownNoise.ar(300, 400)),freq,[0.001, 0.001]);//amp * EnvGen.kr(env, gate,doneAction: 2));
		snd = Splay.ar(snd);
		snd = snd * Env.asr(0.1,0.5,2).ar(Done.freeSelf,\gate.kr(1));
		snd = snd * \amp.kr(-10.dbamp);
	Out.ar(~input,snd);
}).add;

/*(
SynthDef("noiseToPitch", { arg freq=440, amp=2, mul=1, out = 0;
	var env = Env(levels: [0, 1, 0.5, 0], times: [2, 2, 0.6], curve: [-6,0, 1]);
    Out.ar(
        out,
        Resonz.ar(
            SinOsc.ar(BrownNoise.ar(300, 400)) * mul,
			freq,
			[0.05, 0.05 ],
			amp * EnvGen.kr(env, doneAction: 2),
            //LFNoise0.kr(4, 110, 660),

        )
    )
}).add;
)*/
// Microphone/Audio card input --> output signal in audio bus ~input
/*SynthDef(\input, {
	arg input_bus = 0;
	var sig;

	sig = SoundIn.ar(input_bus);
	Out.ar(~input, sig);
}).add;*/

// Pitch Detection --> output freq in control bus ~pitch
SynthDef(\pitchDec, {
	var sig, freq, hasFreq;

	sig = In.ar(~input, 1); //Read mono input
	//Filter signal to optimize pitch recognition for voice/guitar
	sig = LPF.ar(sig, 2000); //Apply LPF filtering
	sig = HPF.ar(sig, 65); //Apply HPF filtering
	# freq, hasFreq = Pitch.kr(sig);
	Out.kr(~pitch, freq);
}).add;

// Pitch_Shifting Third --> output audio 2 channels in bus ~thirdOut
SynthDef(\Third, {
	var control, out, in, freq, hasFreq, midi;

	in = In.ar(~input, 1);
	freq = In.kr(~pitch, 1);
	midi = (freq.cpsmidi.round)%12; //Convert frequency to normalized midi note number (0: C - 11: B)

	control = WrapIndex.kr(~bufThird.bufnum, midi); //Extract the interval type from the buffer

	//Store inside 'out' the pitch shifted signal
	out = SelectXFocus(control,
		[
			PitchShiftPA.ar(in, freq, 1.25992105, nil), // Major third ratio
			PitchShiftPA.ar(in, freq, 1.18920711, nil)  // Minor third ratio
		]
	);

	Out.ar(~thirdOut, out);
}).add;

// Pitch_Shifting Fifth --> output audio 2 channels in bus ~fifthOut
// Same procedure than before
SynthDef(\Fifth, {
	var control, out, in, freq, hasFreq, midi;

	in = In.ar(~input, 1);
	freq = In.kr(~pitch, 1);

	midi = (freq.cpsmidi.round)%12;

	control = WrapIndex.kr(~bufFifth.bufnum, midi);

	out = SelectXFocus(control,
		[
			PitchShiftPA.ar(in, freq, 1.498307077, nil), // Perfect fifth ratio
			PitchShiftPA.ar(in, freq, 1.414213562, nil)  // Diminished fifth ratio
		]
	);

	Out.ar(~fifthOut, out);
}).add;

// Pitch_Shifting Sixth --> output audio 2 channels in bus ~sixthOut
// Same procedure than before
SynthDef(\Sixth, {
	var control, out, in, freq, hasFreq, midi;

	in = In.ar(~input, 1);
	freq = In.kr(~pitch, 1);

	midi = (freq.cpsmidi.round)%12;

	control = WrapIndex.kr(~bufSixth.bufnum, midi);

	out = SelectXFocus(control,
		[
			PitchShiftPA.ar(in, freq, 1.681792831, nil), // Major sixth ratio
			PitchShiftPA.ar(in, freq, 1.587401052, nil)  // Minor sixth ratio
		]
	);

	Out.ar(~sixthOut, out);
}).add;

// Pitch_Shifting Seventh --> output audio 2 channels in bus ~seventhOut
// Same procedure than before
SynthDef(\Seventh, {
	var control, out, in, freq, hasFreq, midi;

	in = In.ar(~input, 1);
	freq = In.kr(~pitch, 1);

	midi = (freq.cpsmidi.round)%12;

	control = WrapIndex.kr(~bufSeventh.bufnum, midi);

	out = SelectXFocus(control,
		[
			PitchShiftPA.ar(in, freq, 1.887748625, nil), // Major seventh ratio
			PitchShiftPA.ar(in, freq, 1.781797436, nil) // Minor seventh ratio
		]
	);

	Out.ar(~seventhOut, out);
}).add;

// Mixer Strips --> will be one for each voice + 1 for dry --> output: send to Reverb and send to Delay
SynthDef(\mixerStrip, {
	arg outBus = 0, input, volSignal;
	var output, channel;
	channel = In.ar(input, 1);
	output = channel * \channelvol.kr(); // Single voice volume control (slider)
	output = LinPan2.ar(channel * \channelvol.kr(), ((\channelPan.kr() * 2) - 1)); // Single voice panning, mono to stereo (Pan knob)
	Out.ar(~mixerReverbSend, output * \reverbSend.kr()); // Reverb volume, stereo bus
	Out.ar(~mixerDelaySend, output * \delaySend.kr()); // Delay volume, stereo bus
	Out.kr(volSignal, Amplitude.kr(output));
	Out.ar(outBus, output);
}).add;

// Reverb --> Output: Return to final mixer
SynthDef(\Reverb, {
	arg dry_wet = 0, room = 0;
	var in, out, wet;

	in = In.ar(~mixerReverbSend, 2);
	out = FreeVerb.ar(in, dry_wet, room); //dry_wet: 0 = full dry (no reverb); 1 = full wet
	//Since the FreeVerb function provides an already mixed signal the dry part must be subtracted in order to have a pure wet output signal
	wet = out - (in*(1-dry_wet));
	Out.ar(~mixerReverbReturn, wet);
}).add;

//Delay --> Output: Return to final mixer
SynthDef(\Delay, {
	arg delTime = 0, delEcho = 0;
	var in, out;

	in = In.ar(~mixerDelaySend, 2);
	out = AllpassC.ar(in, 2, delTime, delEcho);

	Out.ar(~mixerDelayReturn, out);
}).add;

// Mixer ---> Output Bus
SynthDef(\mixer, {
	arg inputA, inputB, inputC, inputD, inputE, inputDelay, inputReverb, out_bus = 0;

	var output = In.ar(inputA, 2) + In.ar(inputB, 2) + In.ar(inputC, 2) + In.ar(inputD, 2) + In.ar(inputE, 2) + In.ar(inputDelay, 2) + In.ar(inputReverb, 2);

	Out.ar(out_bus , output);
}).add;

//SYNTHS
{
~mixer = Synth.newPaused(\mixer);
~delay = Synth.newPaused(\Delay);
~reverb = Synth.newPaused(\Reverb);
a = Synth.newPaused(\mixerStrip);
b = Synth.newPaused(\mixerStrip);
c = Synth.newPaused(\mixerStrip);
d = Synth.newPaused(\mixerStrip);
e = Synth.newPaused(\mixerStrip);
~seventh = Synth.newPaused(\Seventh);
~sixth = Synth.newPaused(\Sixth);
~fifth = Synth.newPaused(\Fifth);
~third = Synth.newPaused(\Third);
~pitch = Synth.newPaused(\pitchDec);
~dry = Synth.newPaused(\input);

OSCdef.new(\noteOn,{
	arg msg, time, addr, port;
	var note;
	//postln("AAAAAAAAAAAAA");
	~dry[msg[1]] = Synth.new(\input, [\freq, msg[1].midicps,\gate,1, \out, ~input, \mul, 1]);
	postln("on");
	},
path: "/noteOn"
);

OSCdef.new(\noteOff,{
	arg msg, time, addr, port;
	var note;
	//postln("AAAAAAAAAAAAA");
	~dry[msg[1]] = Synth.new(\input, [\freq, msg[1].midicps,\gate, 0,\out, ~input, \mul, 1]);
	postln("off");
	~dry[msg[1]].free
	},
path: "/noteOff"
);

// Bus connections and initial parameters values
~mixer.set(\inputA, ~mixerStripAout);
~mixer.set(\inputB, ~mixerStripBout);
~mixer.set(\inputC, ~mixerStripCout);
~mixer.set(\inputD, ~mixerStripDout);
~mixer.set(\inputE, ~mixerStripEout);
~mixer.set(\inputReverb, ~mixerReverbReturn);
~mixer.set(\inputDelay, ~mixerDelayReturn);

a.set(\input, ~input);
a.set(\volSignal, ~mixerAvol);
a.set(\outBus, ~mixerStripAout);
a.set(\channelPan, 0.5);
a.set(\channelvol, 0.5);

b.set(\input, ~thirdOut);
b.set(\volSignal, ~mixerBvol);
b.set(\outBus, ~mixerStripBout);
b.set(\channelPan, 0.5);
b.set(\channelvol, 0.5);

c.set(\input, ~fifthOut);
c.set(\volSignal, ~mixerCvol);
c.set(\outBus, ~mixerStripCout);
c.set(\channelPan, 0.5);
c.set(\channelvol, 0.5);

d.set(\input, ~sixthOut);
d.set(\volSignal, ~mixerDvol);
d.set(\outBus, ~mixerStripDout);
d.set(\channelPan, 0.5);
d.set(\channelvol, 0.5);

e.set(\input, ~seventhOut);
e.set(\volSignal, ~mixerEvol);
e.set(\outBus, ~mixerStripEout);
e.set(\channelPan, 0.5);
e.set(\channelvol, 0.5);



~getMixerStripBounds = {
	arg stripN, stripMax, width, height;
	Rect.new((width * ((stripN - 1) / stripMax)), 0, (width / stripMax), height);
};

~maximizeKnobs = {
	arg width, height;
	if ((width * 3) > (height / 3), {width = height / 6});
	width;
};

~getKnobBounds = {
	arg bounds, n;
	var width = ~maximizeKnobs.value(bounds.width, bounds.height);
	Rect(width / 6, (width * n) + (width / 6), width - (width / 3), width - (width / 3))
};

~getSliderNumboxComboBounds = {
	arg bounds;
	var knobsHeight = ~maximizeKnobs.value(bounds.width, bounds.height) * 3;
	Rect.new(0, knobsHeight, bounds.width / 2, bounds.height - knobsHeight)
};

~getMeterBounds = {
	arg bounds, n;
	var knobsHeight = ~maximizeKnobs.value(bounds.width, bounds.height) * 3;
	Rect.new((bounds.width / 2) + ((bounds.width / 4) * n)-10, knobsHeight, (bounds.width / 4) - 2, bounds.height - knobsHeight)
};

~makeSliderNumBoxCombo = {
	arg bounds, maxVal, parent, strip;
	var view, number, slider, step;
	step = ControlSpec(0, maxVal, \linear, 0.1);
	view = View.new(parent, bounds);
	number = NumberBox(view, Rect(0, bounds.height - 20, bounds.width-10, 20));
	slider = Slider(view, Rect(0, 0, bounds.width -10, bounds.height - 20))
	    .action_({
		    w.refresh;
            number.string_(step.map(slider.value).asString);
		    strip.set(\channelvol, slider.value);
        });
	slider.value_(0.5);
	view;
};

~makeMixerStrip = {
	arg bounds, maxVal, view, volumeBus, strip;
	var sliderView, meterL, meterR, panKnob, sendReverbKnob, sendDelayKnob, updateIndicatorL, updateIndicatorR, viewNew;
	viewNew = View.new(view, bounds);
	sliderView = ~makeSliderNumBoxCombo.value(~getSliderNumboxComboBounds.value(bounds), 100, viewNew, strip);

	panKnob = Knob(viewNew, ~getKnobBounds.value(bounds, 0));
	panKnob.mode = \vert;
	panKnob.color_([Color.grey(0.7, 0.9), Color.black, Color.white, Color.black]);
	panKnob.value_(0.5);
	panKnob.centered_(true);
	panKnob.action_({
		w.refresh;
		    strip.set(\channelPan, panKnob.value);
        });

	sendReverbKnob = Knob(viewNew, ~getKnobBounds.value(bounds, 1));
	sendReverbKnob.mode = \vert;
			sendReverbKnob.color_([Color(0, 0.4, 0.3, 0.9), Color(0, 0.4, 0.3), Color.white, Color(0, 0.7, 0.3)]);
	sendReverbKnob.action_({
		w.refresh;
		    strip.set(\reverbSend, sendReverbKnob.value);
        });

	sendDelayKnob = Knob(viewNew, ~getKnobBounds.value(bounds, 2));
	sendDelayKnob.mode = \vert;
	sendDelayKnob.color_([Color(1, 0.6, 0.2, 0.9), Color(1, 0.6, 0.2), Color.white, Color(0.9, 0.8, 0.2)]);
	sendDelayKnob.action_({
		w.refresh;
		    strip.set(\delaySend, sendDelayKnob.value);
        });

	meterL = LevelIndicator.new(viewNew, ~getMeterBounds.value(bounds, 0));
	meterL.warning_(0.5);
    meterL.critical_(0.7);
	meterL.background_(Color.blue(0.1, 0.2));
    meterL.numTicks_(0);
    meterL.numMajorTicks_(0);
    meterL.drawsPeak_(true);

	updateIndicatorR = fork{loop{
		volumeBus.get({
			arg value;
			{meterL.value_(value[0]*5);
				meterL.peakLevel_(value[0]*5);
			}.defer();
		});
		    0.05.wait;
	    }};
			w.onClose_({
				updateIndicatorL.stop;
			});

	meterR = LevelIndicator.new(viewNew, ~getMeterBounds.value(bounds, 1));
	meterR.warning_(0.5);
    meterR.critical_(0.7);
	meterR.background_(Color.blue(0.2, 0.2));
    meterR.numTicks_(0);
    meterR.numMajorTicks_(0);
    meterR.drawsPeak_(true);

	updateIndicatorR = fork{loop{
		volumeBus.get({
			arg value;
			{meterR.value_(value[1]*5);
				meterR.peakLevel_(value[1]*5);
			}.defer();
		});
		    0.05.wait;
	    }};
			w.onClose_({
				updateIndicatorR.stop;
			});
	viewNew;
};
}.defer(1);

// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------
// ----------------------------------------------  GUI  ---------------------------------------------
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------
{
var height = 740, width = 740;
Window.closeAll;
w = Window.new("HARMONIZOR", Rect((Window.screenBounds.width / 2) - (width / 2),(Window.screenBounds.height / 2) - (height / 2),height,width));
w.drawFunc = {
	Pen.addRect(w.view.bounds);
	Pen.fillRadialGradient(w.view.bounds.center, w.view.bounds.center, 0, w.bounds.width-50, Color.cyan(0.7), Color.black);
	k=0;

// DRY

    Pen.translate(width/2, height/2);
	40.do({
		Pen.translate(0,0);
		Pen.fillColor = Color.hsv(k.fold(0, 1), 1, ~stripA.children[0].children[1].value/2 + 0.5, ~stripA.children[0].children[1].value*6/7 +0.1);
		Pen.moveTo(0@0); // you have to set a starting point...
		Pen.lineTo(10@height/10);
		Pen.lineTo(24@height*2/10);
		Pen.lineTo(50@height*3/10);
		Pen.lineTo(80@height*4/10);
		Pen.lineTo(120@height/2);
		Pen.lineTo(60@height*19/40);
		Pen.lineTo(40@height*17/40);
		Pen.lineTo(30@height*14/40);
		Pen.lineTo(0@height/2);
		Pen.lineTo(-30@height*14/40);
		Pen.lineTo(-40@height*17/40);
		Pen.lineTo(-60@height*19/40);
		Pen.lineTo(-120@height/2);
		Pen.lineTo(-80@height*4/10);
		Pen.lineTo(-50@height*3/10);
		Pen.lineTo(-24@height*2/10);
		Pen.lineTo(-10@height/10);
		Pen.lineTo(0@0);
		Pen.fill;
		Pen.rotate(0.025pi + (~stripA.children[1].value/600)*pi*2);
		k = k + 0.05;
		w.refresh;
	});

// THIRD

	40.do({
		Pen.fillColor = Color.hsv(k.fold(0, 1), 1, ~stripB.children[0].children[1].value/2 + 0.5, ~stripB.children[0].children[1].value*6/7 +0.1);
		Pen.moveTo(0@0); // you have to set a starting point...
		Pen.lineTo(10*4/5@(height/10)*4/5);
        Pen.lineTo(24*4/5@(height*2/10)*4/5);
        Pen.lineTo(50*4/5@(height*3/10)*4/5);
        Pen.lineTo(80*4/5@(height*4/10)*4/5);
		Pen.lineTo(120*4/5@(height/2)*4/5);
		Pen.lineTo(60*4/5@(height*19/40)*4/5);
		Pen.lineTo(40*4/5@(height*17/40)*4/5);
		Pen.lineTo(30*4/5@(height*14/40)*4/5);
		Pen.lineTo(0@(height/2)*4/5);
		Pen.lineTo(-30*4/5@(height*14/40)*4/5);
        Pen.lineTo(-40*4/5@(height*17/40)*4/5);
		Pen.lineTo(-60*4/5@(height*19/40)*4/5);
		Pen.lineTo(-120*4/5@(height/2)*4/5);
		Pen.lineTo(-80*4/5@(height*4/10)*4/5);
		Pen.lineTo(-50*4/5@(height*3/10)*4/5);
		Pen.lineTo(-24*4/5@(height*2/10)*4/5);
		Pen.lineTo(-10*4/5@(height/10)*4/5);
		Pen.lineTo(0@0);
		Pen.fill;
		Pen.rotate(0.025pi + (~stripB.children[1].value/600)*pi*2);
		k = k + 0.05;
	});

// FIFTH

	40.do({
		Pen.fillColor = Color.hsv(k.fold(0, 1), 1, ~stripC.children[0].children[1].value/2 + 0.5, ~stripC.children[0].children[1].value*6/7 +0.1);
		Pen.moveTo(0@0); // you have to set a starting point...
		Pen.lineTo(10*3/5@(height/10)*3/5);
        Pen.lineTo(24*3/5@(height*2/10)*3/5);
        Pen.lineTo(50*3/5@(height*3/10)*3/5);
        Pen.lineTo(80*3/5@(height*4/10)*3/5);
		Pen.lineTo(120*3/5@(height/2)*3/5);
		Pen.lineTo(60*3/5@(height*19/40)*3/5);
		Pen.lineTo(40*3/5@(height*17/40)*3/5);
		Pen.lineTo(30*3/5@(height*14/40)*3/5);
		Pen.lineTo(0@(height/2)*3/5);
		Pen.lineTo(-30*3/5@(height*14/40)*3/5);
        Pen.lineTo(-40*3/5@(height*17/40)*3/5);
		Pen.lineTo(-60*3/5@(height*19/40)*3/5);
		Pen.lineTo(-120*3/5@(height/2)*3/5);
		Pen.lineTo(-80*3/5@(height*4/10)*3/5);
		Pen.lineTo(-50*3/5@(height*3/10)*3/5);
		Pen.lineTo(-24*3/5@(height*2/10)*3/5);
		Pen.lineTo(-10*3/5@(height/10)*3/5);
		Pen.lineTo(0@0);
		Pen.fill;
		Pen.rotate(0.025pi + (~stripC.children[1].value/600)*pi*2);
		k = k + 0.05;
	});

// SIXTH

	40.do({
		Pen.fillColor = Color.hsv(k.fold(0, 1), 1, ~stripD.children[0].children[1].value/2 + 0.5, ~stripD.children[0].children[1].value*6/7 +0.1);
		Pen.moveTo(0@0); // you have to set a starting point...
		Pen.lineTo(10*2/5@(height/10)*2/5);
        Pen.lineTo(24*2/5@(height*2/10)*2/5);
        Pen.lineTo(50*2/5@(height*3/10)*2/5);
        Pen.lineTo(80*2/5@(height*4/10)*2/5);
		Pen.lineTo(120*2/5@(height/2)*2/5);
		Pen.lineTo(60*2/5@(height*19/40)*2/5);
		Pen.lineTo(40*2/5@(height*17/40)*2/5);
		Pen.lineTo(30*2/5@(height*14/40)*2/5);
		Pen.lineTo(0@(height/2)*2/5);
		Pen.lineTo(-30*2/5@(height*14/40)*2/5);
        Pen.lineTo(-40*2/5@(height*17/40)*2/5);
		Pen.lineTo(-60*2/5@(height*19/40)*2/5);
		Pen.lineTo(-120*2/5@(height/2)*2/5);
		Pen.lineTo(-80*2/5@(height*4/10)*2/5);
		Pen.lineTo(-50*2/5@(height*3/10)*2/5);
		Pen.lineTo(-24*2/5@(height*2/10)*2/5);
		Pen.lineTo(-10*2/5@(height/10)*2/5);
		Pen.lineTo(0@0);
		Pen.fill;
		Pen.rotate(0.025pi + (~stripD.children[1].value/200)*pi*2);
		k = k + 0.05;
	});

// SEVENTH

	40.do({
		Pen.fillColor = Color.hsv(k.fold(0, 1), 1, ~stripE.children[0].children[1].value/2 + 0.5, ~stripE.children[0].children[1].value*6/7 +0.1);
		Pen.moveTo(0@0); // you have to set a starting point...
		Pen.lineTo(10*2/5@(height/10)*1/5);
        Pen.lineTo(24*2/5@(height*2/10)*1/5);
        Pen.lineTo(50*2/5@(height*3/10)*1/5);
        Pen.lineTo(80*2/5@(height*4/10)*1/5);
		Pen.lineTo(120*2/5@(height/2)*1/5);
		Pen.lineTo(60*2/5@(height*19/40)*1/5);
		Pen.lineTo(40*2/5@(height*17/40)*1/5);
		Pen.lineTo(30*2/5@(height*14/40)*1/5);
		Pen.lineTo(0@(height/2)*1/5);
		Pen.lineTo(-30*2/5@(height*14/40)*1/5);
        Pen.lineTo(-40*2/5@(height*17/40)*1/5);
		Pen.lineTo(-60*2/5@(height*19/40)*1/5);
		Pen.lineTo(-120*2/5@(height/2)*1/5);
		Pen.lineTo(-80*2/5@(height*4/10)*1/5);
		Pen.lineTo(-50*2/5@(height*3/10)*1/5);
		Pen.lineTo(-24*2/5@(height*2/10)*1/5);
		Pen.lineTo(-10*2/5@(height/10)*1/5);
		Pen.lineTo(0@0);
		Pen.fill;
		Pen.rotate(0.025pi + (~stripE.children[1].value/200)*pi*2);
		k = k + 0.05;
	});
};


// Key Menù
~m1 = PopUpMenu(w, Rect(50, 50, 65, 50));
~m1.items_([
	"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"
]);
~m1.background_(Color.green(0.4, 0));
~m1.stringColor_(Color.white);
~m1.font_(Font("Arial", 24, true, false, false));
~m1.action_({ arg menu;

	~tmpThird = ~scaleThird.rotate(menu.value); //Array rightshift
	//~tmpThird.postln;
	~bufThird.free;
	~bufThird = Buffer.loadCollection(s,~tmpThird,1); //Reload buffer when changing mode

	~tmpFifth = ~scaleFifth.rotate(menu.value); //Array rightshift
	//~tmpFifth.postln;
	~bufFifth.free;
	~bufFifth = Buffer.loadCollection(s,~tmpFifth,1); //Reload buffer when changing mode

	~tmpSixth = ~scaleSixth.rotate(menu.value); //Array rightshift
	//~tmpSixth.postln;
	~bufSixth.free;
	~bufSixth = Buffer.loadCollection(s,~tmpSixth,1); //Reload buffer when changing mode

	~tmpSeventh = ~scaleSeventh.rotate(menu.value); //Array rightshift
	//~tmpSeventh.postln;
	~bufSeventh.free;
	~bufSeventh = Buffer.loadCollection(s,~tmpSeventh,1); //Reload buffer when changing mode
	//(" ").postln;

	~m2.value=0; //Every time this menu is changed the mode menu will return to the initial position (Ionian)
	w.refresh;
});

~m2 = PopUpMenu(w, Rect(190, 50, 150, 50));
~m2.items_(["Ionian","Dorian","Phrygian","Lydian","Mixolydian","Aeolian","Locrian", "Fixed Min", "Fixed Maj"]); //0:Ionian, ... , 6:Locrian, 7:Fixed minor interval, 8: Fixed major interval
~m2.background_(Color.green(0.4, 0.2));
		~m2.stringColor_(Color.white(0.5));
~m2.font_(Font("Arial", 24, true, false, false));
~m2.action_({arg menu;
	var add_shift, tmp;

	if (menu.value < 7, {
		add_shift = if (menu.value < 3, { 0 },{ 1 }); //Dopo il frigio devi tornare indietro di un semitono

		~tmp2Third = ~tmpThird.rotate(-2*menu.value + add_shift); //Array leftshift
		//~tmp2Third.postln;
		~bufThird.free;
		~bufThird = Buffer.loadCollection(s,~tmp2Third,1); //Reload buffer when changing mod

		~tmp2Fifth = ~tmpFifth.rotate(-2*menu.value + add_shift); //Array leftshift
		//~tmp2Fifth.postln;
		~bufFifth.free;
		~bufFifth = Buffer.loadCollection(s,~tmp2Fifth,1); //Reload buffer when changing mod

		~tmp2Sixth = ~tmpFifth.rotate(-2*menu.value + add_shift); //Array leftshift
		//~tmp2Sixth.postln;
		~bufSixth.free;
		~bufSixth = Buffer.loadCollection(s,~tmp2Sixth,1); //Reload buffer when changing mod

		~tmp2Seventh = ~tmpSeventh.rotate(-2*menu.value + add_shift); //Array leftshift
		//~tmp2Seventh.postln;
		~bufSeventh.free;
		~bufSeventh = Buffer.loadCollection(s,~tmp2Seventh,1); //Reload buffer when changing mod
		//(" ").postln;
	} , {
		switch (menu.value,
			7, {~tmpmin = [1,1,1,1,1,1,1,1,1,1,1,1];
				//.postln;
				~bufThird.free;
				~bufFifth.free;
				~bufSixth.free;
				~bufSeventh.free;
				~bufThird = Buffer.loadCollection(s,~tmpmin,1);
				~bufFifth = Buffer.loadCollection(s,~tmpmin,1);
				~bufSixth = Buffer.loadCollection(s,~tmpmin,1);
				~bufSeventh = Buffer.loadCollection(s,~tmpmin,1);
				//(" ").postln;
			},
			8, {~tmpmax = [0,0,0,0,0,0,0,0,0,0,0,0];
				//~tmpmax.postln;
				~bufThird.free;
				~bufFifth.free;
				~bufSixth.free;
				~bufSeventh.free;
				~bufThird = Buffer.loadCollection(s,~tmpmax,1);
				~bufFifth = Buffer.loadCollection(s,~tmpmax,1);
				~bufSixth = Buffer.loadCollection(s,~tmpmax,1);
				~bufSeventh = Buffer.loadCollection(s,~tmpmax,1);
				//(" ").postln;
		});
	});
});



~mixerWidth = 400;
~mixerHeight = 450;
~mixerXPos = (width - ~mixerWidth) / 2;
~mixerYPos = (height - ~mixerHeight) / 2;

~mixerView = View.new(w, Rect.new(~mixerXPos, ~mixerYPos, ~mixerWidth, ~mixerHeight));

~mixerN = 5;

// strips initialized used should be equal to ~mixerN (change mixer synthdef when ~mixerN > 5)
~stripA = ~makeMixerStrip.value(~getMixerStripBounds.value(1, ~mixerN, ~mixerWidth, ~mixerHeight), 100, ~mixerView, ~mixerAvol, a);
~stripB = ~makeMixerStrip.value(~getMixerStripBounds.value(2, ~mixerN, ~mixerWidth, ~mixerHeight), 100, ~mixerView, ~mixerBvol, b);
~stripC = ~makeMixerStrip.value(~getMixerStripBounds.value(3, ~mixerN, ~mixerWidth, ~mixerHeight), 100, ~mixerView, ~mixerCvol, c);
~stripD = ~makeMixerStrip.value(~getMixerStripBounds.value(4, ~mixerN, ~mixerWidth, ~mixerHeight), 100, ~mixerView, ~mixerDvol, d);
~stripE = ~makeMixerStrip.value(~getMixerStripBounds.value(5, ~mixerN, ~mixerWidth, ~mixerHeight), 100, ~mixerView, ~mixerEvol, e);


// SLIDER 2D DELAY -- ORANGE
~s1 = Slider2D(w, Rect(590, 590, 130, 130));
~s1.x_(0.0);
~s1.y_(0.0);
~s1.knobColor_(Color(0.9, 0.8, 0.2));
~s1.background_(Color(1, 0.6, 0.2, 0.7));
~s1.action_({
	arg s2d;
	~delay.set(\delTime, s2d.x, \delEcho, s2d.y*3);
	w.refresh;
});

// SLIDER 2D Reverb -- GREEN
~s2 = Slider2D(w, Rect(20, 590, 130, 130));
~s2.x_(0.0);
~s2.y_(0.0);
~s2.knobColor_(Color(0, 0.7, 0.3));
~s2.background_(Color(0, 0.4, 0.3, 0.7));
~s2.action_({
	arg s2d;
	~reverb.set(\dry_wet, s2d.x, \room, s2d.y*2);
	w.refresh;
});

//BUTTON HARMONIZER ACTIVATION
~b1 = Button(w, Rect(width - 150, 25, 110, 110));
~b1.states_([
			["Harmonizer\nOff", Color.black, Color.cyan(0.8, 0.7)],
			["Harmonizer\nOn", Color.black, Color.green(0.8, 0.7)]
]);
~b1.font_(Font("Arial", 15, false, false, false));
~b1.action_({ arg button;
	~mixer.run(button.value.asBoolean);
	~delay.run(button.value.asBoolean);
	~reverb.run;
	a.run(button.value.asBoolean);
	b.run(button.value.asBoolean);
	c.run(button.value.asBoolean);
	d.run(button.value.asBoolean);
	e.run(button.value.asBoolean);
	~seventh.run(button.value.asBoolean);
	~sixth.run(button.value.asBoolean);
	~fifth.run(button.value.asBoolean);
	~third.run(button.value.asBoolean);
	~pitch.run(button.value.asBoolean);
	~dry.run(button.value.asBoolean);
});

		~t1 = StaticText(w, Rect(120, 170, 55, 25));
		~t1.string_(" Panning");
		~t1.stringColor_(Color.white);
		~t1.font_(Font("Arial", 13, false, false, false));
		~t1.background_(Color.blue(0.2, 0.3));

		~t2 = StaticText(w, Rect(120, 237, 55, 40));
		~t2.string_(" Reverb \n amount ");
		~t2.stringColor_(Color.white);
		~t2.font_(Font("Arial", 13, false, false, false));
		~t2.background_(Color.blue(0.2, 0.3));

		~t3 = StaticText(w, Rect(120, 315, 55, 40));
		~t3.string_(" Delay \n amount");
		~t3.stringColor_(Color.white);
		~t3.font_(Font("Arial", 13, false, false, false));
		~t3.background_(Color.blue(0.2, 0.3));

		~t4 = StaticText(w, Rect(155, 660, 20, 60));
		~t4.string_(" R\n o\n o\n m");
		~t4.stringColor_(Color.white);
		~t4.font_(Font("Arial", 13, false, false, false));
		~t4.background_(Color.blue(0.2, 0.3));

		~t5 = StaticText(w, Rect(565, 660, 20, 60));
		~t5.string_(" E\n c\n h\n o");
		~t5.stringColor_(Color.white);
		~t5.font_(Font("Arial", 13, false, false, false));
		~t5.background_(Color.blue(0.2, 0.3));

		~t6 = StaticText(w, Rect(20, 560, 60, 25));
		~t6.string_(" Dry/Wet");
		~t6.stringColor_(Color.white);
		~t6.font_(Font("Arial", 13, false, false, false));
		~t6.background_(Color.blue(0.2, 0.3));

		~t7 = StaticText(w, Rect(680, 560, 40, 25));
		~t7.string_(" Time");
		~t7.stringColor_(Color.white);
		~t7.font_(Font("Arial", 13, false, false, false));
		~t7.background_(Color.blue(0.2, 0.3));

		~t8 = StaticText(w, Rect(55, 530, 60, 25));
		~t8.string_(" REVERB");
		~t8.stringColor_(Color.black);
		~t8.font_(Font("Arial", 13, true, false, false));
		~t8.background_(Color.grey(0.7, 0.9));

		~t9 = StaticText(w, Rect(625, 530, 60, 25));
		~t9.string_(" DELAY");
		~t9.stringColor_(Color.black);
		~t9.font_(Font("Arial", 13, true, false, false));
		~t9.background_(Color.grey(0.7, 0.9));

		~t10 = StaticText(w, Rect(170, 600, 35, 25));
		~t10.string_(" Dry");
		~t10.stringColor_(Color.white);
		~t10.font_(Font("Arial", 13, false, false, false));
		~t10.background_(Color.blue(0.2, 0.3));

		~t11 = StaticText(w, Rect(250, 600, 40, 25));
		~t11.string_(" Third");
		~t11.stringColor_(Color.white);
		~t11.font_(Font("Arial", 13, false, false, false));
		~t11.background_(Color.blue(0.2, 0.3));

		~t12 = StaticText(w, Rect(330, 600, 40, 25));
		~t12.string_(" Fifth");
		~t12.stringColor_(Color.white);
		~t12.font_(Font("Arial", 13, false, false, false));
		~t12.background_(Color.blue(0.2, 0.3));

		~t13 = StaticText(w, Rect(410, 600, 40, 25));
		~t13.string_(" Sixth");
		~t13.stringColor_(Color.white);
		~t13.font_(Font("Arial", 13, false, false, false));
		~t13.background_(Color.blue(0.2, 0.3));

		~t14 = StaticText(w, Rect(490, 600, 55, 25));
		~t14.string_(" Seventh");
		~t14.stringColor_(Color.white);
		~t14.font_(Font("Arial", 13, false, false, false));
		~t14.background_(Color.blue(0.2, 0.3));

w.front;
w.alwaysOnTop_(true);
w.onClose = {s.freeAll};
}.defer(1);
});
)





/*


(
f = { |msg, time, addr|
    if(msg[0] != '/status.reply') {
        //"time: % sender: %\nmessage: %\n".postf(time, addr, msg);
    }
};
thisProcess.addOSCRecvFunc(f);

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
var noteLen = 2;

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
