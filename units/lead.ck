BPM tempo;

ADSR lowADSR, highADSR;

SqrOsc midLead => lowADSR => NRev reverb => Gain master => dac;
SqrOsc subLead => lowADSR;

SawOsc highLead => highADSR => Echo echo => master;
echo => Gain feedback => echo;

[50, 48, 47, 45] @=> int lowNotes[];

tempo.note => dur duration;

///

lowADSR.set(duration / 3, duration / 2, 1, duration / 3);
highADSR.set(tempo.eighthNote / 3, tempo.eighthNote / 2, .8, tempo.eighthNote / 3);

tempo.eighthNote => echo.delay;
.25 => echo.mix;

.1 => reverb.mix;

.7 => subLead.gain;
.2 => feedback.gain;
.05 => master.gain;

///

function void runMidLead() {
    while(true) {
        for (0 => int step; step < lowNotes.cap(); step++) {
            Std.mtof(lowNotes[step]) => midLead.freq;
            midLead.freq() * .5 => subLead.freq;
            
            lowADSR.keyOn();
            duration - (tempo.quarterNote / 3) => now;
            lowADSR.keyOff(); 
            tempo.quarterNote / 3 => now;         
        }
    }
}
function void runHighLead() {
    while(true) {
        for (0 => int beat; beat < 4; beat++) {
            if (beat < 2) {
                Std.mtof(72) => highLead.freq;
            }
            else if (beat == 2) {
                Std.mtof(79) => highLead.freq;                
            }
            else {
                Std.mtof(76) => highLead.freq;
            }

            for (0 => int step; step < 4; step++) {
                if (step != 3) {                
                    tempo.eighthNote => now;
                    
                    highADSR.keyOn();
                    tempo.eighthNote - (tempo.eighthNote / 3) => now;
                    highADSR.keyOff();
                    tempo.eighthNote / 3 => now;                    
                }   
                else {
                    for (0 => int rep; rep < 3; rep++) {
                        tempo.eighthNote / 3 => now;

                        highADSR.keyOn();
                        (tempo.eighthNote - (tempo.eighthNote / 3)) / 3 => now;
                        highADSR.keyOff();
                        (tempo.eighthNote / 3) / 3 => now;
                    }
                }
            }
        }
    }
}

///

tempo.note * 64 => now;

spork ~ runMidLead() @=> Shred midShred;
tempo.note * 8 => now;

spork ~ runHighLead() @=> Shred highShred;
tempo.note * 16 => now;

Machine.remove(midShred.id());
tempo.note * 4 => now;

Machine.remove(highShred.id());