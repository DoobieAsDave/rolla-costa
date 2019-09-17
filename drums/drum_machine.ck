BPM tempo;

Gain master;

SndBuf kick => master;
SndBuf snare => NRev snareRev => master;
SndBuf hihat => master;
SndBuf lowhat => master;
SndBuf openhat => master;
SndBuf shaker => master;
SndBuf wood => JCRev woodRev => master;

master => dac;

me.dir(-1) + "audio/kick.wav" => kick.read;
me.dir(-1) + "audio/snare.wav" => snare.read;
me.dir(-1) + "audio/hihat.wav" => hihat.read;
me.dir(-1) + "audio/lowhat.wav" => lowhat.read;
me.dir(-1) + "audio/openhat.wav" => openhat.read;
me.dir(-1) + "audio/shaker.wav" => shaker.read;
me.dir(-1) + "audio/wood.wav" => wood.read;

kick.samples() => kick.pos;
snare.samples() => snare.pos;
hihat.samples() => hihat.pos;
lowhat.samples() => lowhat.pos;
openhat.samples() => openhat.pos;
shaker.samples() => shaker.pos;
wood.samples() => wood.pos;

//.15 => snareRev.mix;
.0 => snareRev.mix;
.05 => woodRev.mix;

.8 => snare.gain;
.5 => kick.gain;
.3 => hihat.gain => shaker.gain;
.2 => openhat.gain;
.1 => lowhat.gain => wood.gain;

.8 => master.gain;

tempo.sixteenthNote => dur duration;

[
    1, 0, 0 ,0, 
    0, 1, 0, 0,
    1, 0, 0, 1,
    0, 1, 0, 0
] @=> int kickPattern[];
[
    0, 0, 1 ,0, 
    0, 0, 1, 0,
    0, 0, 1 ,0,
    0, 0, 1, 0
] @=> int snarePattern[];
[
    1, 1, 1, 1,
    1, 1, 1, 1,
    1, 1, 1, 1,
    1, 1, 1, 1
] @=> int hihatPattern[];
[
    0, 1, 1, 1,
    1, 0, 1, 1,
    1, 1, 0, 1,
    1, 1, 1, 0
] @=> int lowhatPattern[];
[
    0, 0, 1, 0,
    0, 0, 1, 0,
    0, 0, 1, 0,
    0, 0, 1, 0
] @=> int openhatPattern[];

/// Functions

function void runKick() {
    while(true) {
        for (0 => int step; step < kickPattern.cap(); step++) {
            if (kickPattern[step]) { 0 => kick.pos; }

            duration => now;
        }
    }
}
function void runHihat() {
    while(true) {
        for (0 => int step; step < hihatPattern.cap(); step++) {
            if (hihatPattern[step] && step != hihatPattern.cap() - 1) {
                Math.random2(0, hihat.samples() / 4) => hihat.pos;
                duration => now;
            }
            else {            
                if (Math.random2(0, 1)) {
                    hihat.samples() / 4 => hihat.pos;
                    duration / 2 => now;
                    hihat.samples() / 4 => hihat.pos;
                    duration / 2 => now;
                }
                else {
                    hihat.samples() / 4 => hihat.pos;
                    duration / 3 => now;
                    hihat.samples() / 4 => hihat.pos;
                    duration / 3 => now;
                    hihat.samples() / 4 => hihat.pos;
                    duration / 3 => now;
                }
            }
        }
    }
}
function void runSnare() {
    while(true) {
        for (0 => int beat; beat < 4; beat++) {
            for (0 => int step; step < snarePattern.cap(); step++) {                
                .8 => snare.gain;

                if (snarePattern[step]) { 0 => snare.pos; }

                if (beat == 3) {
                    if (step == 13 || step == 15) {
                        Math.random2f(.25, .4) => snare.gain;

                        Math.random2(0, 15) => snare.pos;
                        duration / 2 => now;
                        Math.random2(0, 15) => snare.pos;
                        duration / 2 => now;                       

                        continue;                        
                    }                    
                }

                duration => now;                
            }
        }
    }
}
function void runLowhat() {
    while(true) {
        for (0 => int step; step < lowhatPattern.cap(); step++) {
            if (lowhatPattern[step]) { Math.random2(0, 25) => lowhat.pos; }

            duration => now;
        }
    }
}
function void runOpenhat() {
    while(true) {
        for (0 => int step; step < openhatPattern.cap(); step++) {
            if (openhatPattern[step]) {
                if (step != 14) {
                    1 => openhat.rate;
                }
                else {
                    Math.random2f(.9, 1.1) => openhat.rate;  
                }
                
                0 => openhat.pos;
            }
            
            duration => now;
        }
    }
}
function void runShaker() {
    while(true) {
        for (0 => int step; step < 16; step++) {            
            if (step % 4 != 0) {
                if (step == 7 && Math.random2(0, 1)) {
                    0 => shaker.pos;
                }

                duration => now;
            }
            else {
                Math.random2(50, shaker.samples() / 3) => shaker.pos;
                duration / 2 => now;
                Math.random2(50, shaker.samples() / 3) => shaker.pos;
                duration / 2 => now;                
            }            
        }
    }
}
function void runWood() {
    while(true) {
        for (0 => int beat; beat < 4; beat++) {
            for (0 => int step; step < 16; step++) {            
                if (beat % 2 == 0) {
                    if (step == 7 || step == 9) {                        
                        1.2 => wood.rate;
                        10 => wood.pos;
                    }

                    duration => now;
                }
                else {
                    1 => wood.rate;

                    if (beat != 3) {
                        if (step >= 12) {                            
                            0 => wood.pos;                        
                        }

                        duration => now;
                    }
                    else {
                        if (step >= 12) {
                            0 => wood.pos;
                            duration / 2 => now;
                            0 => wood.pos;
                            duration / 2 => now;
                        }
                        else {                            
                            duration => now;
                        }
                    }                    
                }                
            }
        }
    }
}

spork ~ runKick();
spork ~ runHihat();
tempo.note * 4 => now;
spork ~ runWood();
tempo.note * 8 => now;
spork ~ runSnare();
tempo.note * 8 => now;
spork ~ runShaker();
tempo.note * 4 => now;
spork ~ runLowhat();
tempo.note * 4 => now;
spork ~ runOpenhat();

while(true)
    1 :: second => now;
