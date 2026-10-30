/*
Per-machine overrides for boot/superdirt_startup.scd.

Copy this file to boot/superdirt_local.scd (git-ignored) and uncomment what differs on this machine.
Each line sets one key in ~dirtLocal; anything left commented keeps the default in superdirt_startup.scd.
The startup file loads this one before booting the server, so it may hold values that need a reboot
(device, channel counts) as well as ones that do not (latency, extra samples).
*/

~dirtLocal = ~dirtLocal ? ();

// ~dirtLocal[\device] = "MacBook Pro Speakers"; // audio device name; list them with ServerOptions.devices
// ~dirtLocal[\numOutputBusChannels] = 2; // hardware output channel count
// ~dirtLocal[\numInputBusChannels] = 2; // hardware input channel count
// ~dirtLocal[\numChannels] = 2; // SuperDirt output channels (pan width)
// ~dirtLocal[\numOrbits] = 12; // d1..d12 map to orbits 0..11
// ~dirtLocal[\latency] = 0.3; // s.latency; raise it on "late" messages
// ~dirtLocal[\samplePaths] = ["~/Music/samples/*"]; // extra sample folders, one wildcard per entry, loaded after Dirt-Samples
// ~dirtLocal[\onStart] = { |dirt| }; // runs after ~dirt.start, e.g. MIDI setup or extra SynthDefs
