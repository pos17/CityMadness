~n = NetAddr("127.0.0.1", NetAddr.langPort);
NetAddr.localAddr;
(
// INPUT PARAMETERS
~octaves = 1;
~tempo = 100;
~arp_rate = 0.25;
~mode = "stairs"; // up, down, up-down, down-up, funnel-up, funnel-down, stairs, random
~amp_mode = "drunk"; // static, ascend, descend, drunk, random
~pan_mode = "ping-pong"; // static, waveLR, waveRL, ping-pong, random
~density = 1;
~chord_chance = 0.1;
~swap_chance = 0.2;
~chaos = 0;

~cc1 = 14; // Controls ~tempo
~cc2 = 15; /* Controls ~mode (the 128 values are divided equally among the 8 modes, such that 0-15 correspond to the "up" mode,
           16-31 correspond to the "down" mode, 32-63 correspond to the "up-down" mode, etc. The same is true of the pan_mode
           and amp_mode controls  */
~cc3 = 16; // Controls ~amp_mode
~cc4 = 17; // Controls ~pan_mode
~cc5 = 18; /* Controls ~density (Note that a cc value of 0 corresponds to a density of 1. As you increase the cc value, the
           density will get lower */
~cc6 = 19; // Controls ~chord_chance
~cc7 = 20; // Controls ~swap_chance
~cc8 = 21; // Controls ~chaos

// END INPUT PARAMETERS


// Boot server
s.boot;

// Creates arrays for storing active notes and patterns
~active = Array.new(30);
~pattern = Array.new(30);


// Create tempo clock
t = TempoClock.new();
t.tempo = ~tempo/60;

// MIDI Input func
OSCdef('noteOn',{
    arg msg, time, addr, recvPort;

    // If Routine was yielded because there were no active notes, start it again
	if (~active.size == 0,
        {~scheduler.play(t)}
    );
    // Add new note to currently active notes
	~active.add(msg[1]);


},path:"/noteOn");



// Midi note off function
OSCdef('noteOff',{
    arg msg, time, addr, recvPort;
    // remove note from active note list when it gets note off message
	~active[msg[1]].remove(msg[1]);
},path:"/noteOff");

// Midi CC function
~ccFunc = MIDIFunc.cc({
    arg val, num, chan, src;
    [num, val].postln;

    // Map CC values to parameters values based on CC input number
    if (num == ~cc1, {
        ~tempo = val.linlin(0, 127, 60, 200);
        t.tempo = ~tempo/60
    });

    if (num == ~cc2, {
        var mode = case
        {val < 16} {~mode = "up".postln}
        {val >= 16 && val < 32} {~mode = "down".postln}
        {val >= 32 && val < 48} {~mode = "up-down".postln}
        {val >= 48 && val < 64} {~mode = "down-up".postln}
        {val >= 64 && val < 80} {~mode = "funnel-up".postln}
        {val >= 80 && val < 96} {~mode = "funnel-down".postln}
        {val >= 96 && val < 112} {~mode = "stairs".postln}
        {val >= 112} {~mode = "random".postln};
    });

    if (num == ~cc3, {
        var mode = case
        {val < 26} {~amp_mode = "static".postln}
        {val >= 26 && val < 51} {~amp_mode = "ascend".postln}
        {val >= 51 && val < 77} {~amp_mode = "descned".postln}
        {val >= 77 && val < 102} {~amp_mode = "drunk".postln}
        {val >= 102} {~amp_mode = "random".postln};
    });

    if (num == ~cc4, {
        var mode = case
        {val < 26} {~pan_mode = "static"}
        {val >= 26 && val < 51} {~pan_mode = "waveLR".postln}
        {val >= 51 && val < 77} {~pan_mode = "waveRL".postln}
        {val >= 77 && val < 102} {~pan_mode = "ping-pong".postln}
        {val >= 102} {~pan_mode = "random".postln};
    });


    if (num == ~cc5, {
        ~density = val.linlin(0, 127, 1, 0)
    });

    if (num == ~cc6, {
        ~chord_chance = val.linlin(0, 127, 0, 1)
    });

    if (num == ~cc7, {
        ~swap_chance = val.linlin(0, 127, 0, 1)
    });

    if (num == ~cc8, {
        ~chaos = val.linlin(0, 127, 0, 1);
    });
});

// Create SynthDef for playing notes
/*SynthDef.new(\tone, {
    arg freqs=#[0, 0, 0, 0, 0], amp=0.3, amps=#[0.1,0,0,0,0], pos=0;
    var sig, sig1, sig2, sig3, sig4, sig5, env;
    sig1 = Pan2.ar(LFTri.ar(freqs[0]), pos, amps[0]);
    sig2 = Pan2.ar(LFTri.ar(freqs[1]), pos, amps[1]);
    sig3 = Pan2.ar(LFTri.ar(freqs[2]), pos, amps[2]);
    sig4 = Pan2.ar(LFTri.ar(freqs[3]), pos, amps[3]);
    sig5 = Pan2.ar(LFTri.ar(freqs[4]), pos, amps[4]);
    env = EnvGen.kr(Env.perc, doneAction:2);
    sig = Mix([sig1, sig2, sig3, sig4, sig5]) * env * amp;
    Out.ar(0, sig);
}).add;
*/
SynthDef.new(\tone, {
	arg freqs=#[0, 0, 0, 0, 0], amp=1, amps=#[0.1,0,0,0,0], pos=0;
	var sig, sig1, sig2, sig3, sig4, sig5, env;
	//env = Env(levels: [0, 1, 0.5, 0], times: [1, 1.5, 0.6], curve: [-6,0, 1]);
	//snd = Resonz.ar(SinOsc.ar(BrownNoise.ar(300, 400))*0.1,freqs[1],[0.001, 0.001]);
	//snd = Latch.ar(snd,Impulse.ar(Rand(8000,16e3)));
	sig1 = Pan2.ar(Resonz.ar(SinOsc.ar(BrownNoise.ar(300, 400))*1,freqs[0],[0.001, 0.001],amps[0]));
	sig2 = Pan2.ar(Resonz.ar(SinOsc.ar(BrownNoise.ar(300, 400))*1,freqs[1],[0.001, 0.001],amps[1]));
    sig3 = Pan2.ar(Resonz.ar(SinOsc.ar(BrownNoise.ar(300, 400))*1,freqs[2],[0.001, 0.001],amps[2]));
    sig4 = Pan2.ar(Resonz.ar(SinOsc.ar(BrownNoise.ar(300, 400))*1,freqs[3],[0.001, 0.001],amps[3]));
    sig5 = Pan2.ar(Resonz.ar(SinOsc.ar(BrownNoise.ar(300, 400))*1,freqs[4],[0.001, 0.001],amps[4]));
    env = EnvGen.kr(Env.perc, doneAction:2);
    sig = Mix([sig1, sig2, sig3, sig4, sig5]) * env * amp;
	sig = DelayC.ar(sig,0.01,{Rand(0,0.01)}! sig.size);
	sig = Splay.ar(sig);
    Out.ar(0, sig);
}).add;

// Scheduler for handling all of the arpeggiation algorithms and sequencing them
~scheduler = Routine.new({
    var octave = 0;
    var curNote = -1;
    var panPos = 0;
    var sweep = 0;
    var amp = 0.1;
    var prev = 0.8;

    // run on a loop to iterate through notes in the active sequence
    loop {
        var octCount = 0;
        var freqArray;
        var ampArray;

        // Create array that will store active notes plus octaves
        ~allNotes = Array.newClear(~active.size * ~octaves);

        // Iterate through and add from active list, jumping octave whenever we reach end of list
        ~allNotes.do({arg item, i;
            ~allNotes.put(i, ~active.wrapAt(i) + (octCount * 12));

            // Check to see if we need to jump an octave
            if (((i + 1) % ~active.size) == 0,
                {octCount = octCount + 1}
            );
        });

        // Remove duplicates
        ~allNotes = ~allNotes.as(Set).as(Array);

        // Sort notes by value depending on mode
        if (~mode == "up", {
            ~pattern = ~allNotes.sort({arg a, b; a < b})
        });

        if (~mode == "down", {
            ~pattern = ~allNotes.sort({arg a, b; a > b})
        });

        if (~mode == "up-down", {
            ~pattern = ~allNotes.sort({arg a, b; a < b}).mirror1
        });

        if (~mode == "down-up", {
            ~pattern = ~allNotes.sort({arg a, b; a > b}).mirror1
        });

        if (~mode == "random", {
            ~pattern = ~allNotes.scramble;
        });

        if (~mode == "funnel-up", {
            var flag = 1;
            var temp = ~allNotes;

            ~pattern = Array.newClear(~allNotes.size);

            (~allNotes.size).do({arg i;
                if (flag == 1, {
                    ~pattern.put(i, temp.minItem);
                    temp.remove(temp.minItem)
                },
                // Else
                {
                    ~pattern.put(i, temp.maxItem);
                    temp.remove(temp.maxItem)
                });

                flag = flag * -1;
            });
        });

        if (~mode == "funnel-down", {
            var flag = 1;
            var temp = ~allNotes;

            ~pattern = Array.newClear(~allNotes.size);

            (~allNotes.size).do({arg i;
                if (flag == 1, {
                    ~pattern.put(i, temp.maxItem);
                    temp.remove(temp.maxItem)
                },
                // Else
                {
                    ~pattern.put(i, temp.minItem);
                    temp.remove(temp.minItem)
                });

                flag = flag * -1;
            });
        });

        if (~mode == "stairs", {
            var sorted = ~allNotes.sort({arg a, b; a < b});

            if (~allNotes.size > 2, {
                ~pattern = Array.newClear((~allNotes.size - 2) * 3);

                (~allNotes.size - 2).do({arg i;
                    3.do({arg j;
                        ~pattern.put((i * 3) + j, sorted[i + j]);
                    });
                })
            },
            //Else
            {~pattern = sorted}
            );
        });

        // Set panning mode
        if (~pan_mode == "static", {
            panPos = 0;
        });

        if (~pan_mode == "waveLR", {
            sweep = ((sweep + 0.1) % 2);
            panPos = sweep - 1;
        });

        if (~pan_mode == "waveRL", {
            sweep = ((sweep + 0.1) % 2);
            panPos = (sweep - 1) * -1;
        });

        if (~pan_mode == "ping-pong", {
            panPos = ((panPos + 1) % 2) - 0.5;
        });

        if (~pan_mode == "random", {
            panPos = 2.0.rand - 1;
        });

        if (~amp_mode == "static", {
            amp = 0.5;
        });

        // Set amplitude mode
        if (~amp_mode == "ascend", {
            var step = 0.8 / ~pattern.size;
            amp = ((amp + step) % (step * ~pattern.size)).min(1);
        });

        if (~amp_mode == "descend", {
            var step = 0.8 / ~pattern.size;
            prev = ((prev + step) % (step * ~pattern.size)).min(1);
            amp = 0.8 - prev;
        });

        if (~amp_mode == "random", {
            amp = 1.1.rand - 0.1;
        });

        if (~amp_mode == "drunk", {
            if (1.0.rand < 0.25, {
                amp = 1.1.rand - 0.1;
            },
            // Else
            {amp = 0.5}
            );
        });

        // Iterate current note through active array
        curNote = (curNote + 1) % ~pattern.size;

        // Check if there are any active notes
		if (~active.size != 0,

            // Make sure there are note in the pattern, and check for swap chance
            if (~pattern.size != 0, {
                if (1.0.rand < ~swap_chance, {
                    ~pattern.swap((~pattern.size).rand, (~pattern.size).rand);
                    if (1.0.rand < ~swap_chance, {
                        ~pattern.swap((~pattern.size).rand,(~pattern.size).rand);
                        if (1.0.rand < ~swap_chance, {
                            ~pattern.swap((~pattern.size).rand, (~pattern).size.rand);
                        });
                    });
                });
            });

            // Make sure there are note in the pattern, and check for chaos chance
            if (~pattern.size != 0, {
                if (1.0.rand < ~chaos, {
                    ~pattern.put(~pattern.size.rand, ~pattern.minItem.rrand(~pattern.maxItem));
                    if (1.0.rand < ~chaos, {
                        ~pattern.put(~pattern.size.rand, ~pattern.minItem.rrand(~pattern.maxItem));
                        if (1.0.rand < ~chaos, {
                            ~pattern.put(~pattern.size.rand, ~pattern.minItem.rrand(~pattern.maxItem));
                        });
                    });
                });
            });

           ~pattern.postln;

            // Make sure the note for the current iteration exists (to prevent errors)
            if (~pattern[curNote] != nil, {
                freqArray = [~pattern[curNote].midicps];
                ampArray = [1,0,0,0,0];

                // Check for chord chance and construct chord based on notes in the pattern set
                if (1.0.rand < ~chord_chance, {
                    var chord_sel = ~pattern.shift(curNote * -1);
                    chord_sel = chord_sel.as(Set).as(Array);

                    chord_sel.do({arg item, i;
                        if ((~pattern[curNote] - item).abs > 12, {
                            chord_sel.removeAt(i)
                        })
                    });

                    chord_sel.do({arg item, i;
                        chord_sel[i] = item.midicps;
                    });

                    freqArray = freqArray.add(chord_sel).flat;
                    ampArray = [0.4, 0.4, 0.4, 0.4, 0.4];
                });
            });

            // Instantiate Synth and set it's values to the parameters we just calculated
            {Synth.new (
                \tone,
                [
                    \freqs, freqArray,
                    \amp, [0, amp].wchoose([1 - ~density, ~density]),
                    \amps, ampArray,
                    \pos, panPos
                ]
            )},
            // Else yield routine and clear pattern if there were not active notes
            {
                ~scheduler.yield;
                ~pattern = [];
                curNote = -1;
                octave = 0;
            };
        );

        // Wait for duration set by tempoClock before playing next note
        ~arp_rate.wait;
    };
    });
)

1.rand;

s.makeGui;