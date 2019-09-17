BPM tempo;

SinOsc sin => Gain master => ADSR adsr => dac;
SinOsc fth => master;
SinOsc sub => master;

[45, 45, 48, 48] @=> int notes[];

.4 => master.gain;

function void runBass() {
    while(true) {
        for (0 => int step; step < notes.cap(); step++) {
            adsr.set(tempo.quarterNote * .1, tempo.quarterNote * .2, .7, tempo.quarterNote * .1);
            
            Std.mtof(notes[step]) => float baseFreq;

            baseFreq => sin.freq;
            baseFreq * 1.5 => fth.freq;
            baseFreq * .5 => sub.freq;
                        
            if (step == 0) {
                adsr.set(tempo.quarterNote * .07, tempo.quarterNote * .1, .8, tempo.quarterNote * .05);

                for (0 => int rep; rep < 3; rep++) {
                    adsr.keyOn();
                    tempo.eighthNote / 3 => now;           
                    adsr.keyOff();
                    tempo.eighthNote / 3 => now;
                }
            }
            else if (step == notes.cap() - 1) {
                for (0 => int rep; rep < 2; rep++) {
                    if (rep == 1) {                        
                        Std.mtof(Std.ftom(sin.freq()) + 2) => sin.freq;
                        sin.freq() * 1.5 => fth.freq;
                        sin.freq() * .5 => sub.freq;
                    }

                    adsr.keyOn();
                    tempo.eighthNote / 2 => now;           
                    adsr.keyOff();
                    tempo.eighthNote / 2 => now;
                }
            }
            else {
                adsr.keyOn();
                tempo.eighthNote => now;           
                adsr.keyOff();
                tempo.eighthNote => now;                
            }
        }
    }
}

tempo.note * 4 => now;

spork ~ runBass() @=> Shred bassShred;
tempo.note * 60 => now;

Machine.remove(bassShred.id());