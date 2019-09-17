BPM tempo;

tempo.setBPM(85.0);
//tempo.setBPM(60.0);

.6 => dac.gain;

Machine.add(me.dir() + "drums/drum_machine.ck") => int drums;
Machine.add(me.dir() + "units/arp.ck") => int arp;
Machine.add(me.dir() + "units/lead.ck") => int lead;
Machine.add(me.dir() + "units/bass.ck") => int bass;