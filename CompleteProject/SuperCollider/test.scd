Env.new(levels: [0, 1, 0.8, 0], times: [0.5, 0.5, 0.6], curve: [-6, -1, 1]).plot;

{BPF.ar(SinOsc.ar(BrownNoise.ar(300, 400)) * 0.1,MouseX.kr(80, 800, 1), 0.2);}.play
