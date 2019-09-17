BPM tempo;

Gain master;
ADSR adsr;

SinOsc voice1 => master => adsr => Echo echo => Pan2 stereo => dac;
SinOsc voice2 => master;
SinOsc voice3 => master;
SinOsc voice4 => master;

echo => Gain feedback => echo;

[0, 5, -2, 3] @=> int rootNotes[];
57 => int baseKey;

tempo.thirtiethNote => dur duration;

.0 => float echoMix;
-1 => float stereoPan;

///

adsr.set(duration * .2, duration * .3, .7, duration * .25);

duration * 5 => echo.delay; 

.2 => feedback.gain;
.15 => master.gain;

function void swipeEchoMix(Echo delay, dur t, float min, float max, float step) {       
    step => float crement;
    max - min => float range;
    (range / step) * 2 => float stepNumber;        

    min => echoMix;

    while(true) {
        echoMix => echo.mix;

        echoMix + crement => echoMix;

        if (echoMix >= max) {
            -.1 => crement;
        }
        else if (echoMix <= min) {
            .1 => crement;
        }        

        t / stepNumber => now;
    }
}
function void panStereo(Pan2 pan, dur t, float min, float max, float step) {    
    step => float crement;
    max - min => float range;
    (range / step) * 2 => float stepNumber;    

    min => stereoPan;

    while(true) {
        stereoPan => pan.pan;

        stereoPan + crement => stereoPan;

        if (stereoPan >= max) {
            -.1 => crement;
        }
        else if (stereoPan <= min) {
            .1 => crement;
        }

        t / stepNumber => now;
    }
}

function void runArp() {
    while(true) {
        for (0 => int beat; beat < 4; beat++) {
            for (0 => int step; step < rootNotes.cap(); step++) {
                float baseFreq;

                if (beat != 3) {
                    Std.mtof(baseKey + rootNotes[step]) => baseFreq;
                }
                else {
                    Std.mtof(baseKey + rootNotes[step]) * 1.2 => baseFreq;
                }

                baseFreq => voice1.freq;
                baseFreq * 1.5 => voice2.freq;
                baseFreq * 2 => voice3.freq;
                baseFreq * .5 => voice4.freq;
                
                adsr.keyOn();             
                duration => now;
                adsr.keyOff();
                duration => now;
            }
        }
    }
}

spork ~ swipeEchoMix(echo, tempo.note, .1, .5, .05);
spork ~ panStereo(stereo, tempo.note, -.5, .5, .1);


tempo.note * 12 => now;
spork ~ runArp();
tempo.note * 16 => now;

while(true)
    1 :: second => now;