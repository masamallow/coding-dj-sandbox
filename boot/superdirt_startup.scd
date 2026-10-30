/*
SuperDirt startup for this repository: the SuperCollider side of the Tidal setup.

Adapted from the example that ships with the installed SuperDirt quark,
	~/Library/Application Support/SuperCollider/downloaded-quarks/SuperDirt/superdirt_startup.scd
Lines marked "local:" are this repository's deviations; everything else stays close to that example,
so a SuperDirt upgrade only needs a diff against the new copy of it.

Two ways to run it:
	[GUI] Open this file in the SuperCollider IDE, put the cursor inside the outer parentheses
		  and evaluate the block with Cmd+Return.
	Auto  Make SuperCollider run it on launch by adding one line to the user startup file
		  (File > Open startup file in the IDE):
			  load("/absolute/path/to/coding-dj-sandbox/boot/superdirt_startup.scd");
		  That absolute path lives in the user startup file, never in this repository.

Per-machine values (audio device, channel counts, latency, personal sample folders) go into
	boot/superdirt_local.scd
which is git-ignored; start it from superdirt_local.example.scd next to it. Anything it leaves out
keeps the defaults below.

The post window reports success with a line like:
	SuperDirt: listening on port 57120

SuperDirt.start (one line, no file) starts SuperDirt with close to the same defaults and remains
the quickest check when something is wrong: use it to tell a server problem from a problem in this file.
*/

(
// local: project-relative paths must be captured here, synchronously; the callbacks below run later,
// after thisProcess.nowExecutingPath has been reset (it is nil when evaluated from an unsaved buffer).
~dirtProjectRoot = thisProcess.nowExecutingPath !? { |path| path.dirname.dirname };

// local: per-machine overrides live in the git-ignored boot/superdirt_local.scd (start from
// superdirt_local.example.scd); its statements fill ~dirtLocal, and the defaults below yield to its keys.
~dirtLocal = ();
thisProcess.nowExecutingPath !? { |path|
	var localFile = path.dirname +/+ "superdirt_local.scd";
	if(File.exists(localFile)) { localFile.load };
};

s.reboot { // server options are only updated on reboot
	// configure the sound server: here you could add hardware specific options
	// see http://doc.sccode.org/Classes/ServerOptions.html
	s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
	s.options.memSize = 8192 * 32; // increase this if you get "alloc failed" messages
	s.options.numWireBufs = 2048; // increase this if you get "exceeded number of interconnect buffers" messages
	s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
	s.options.numOutputBusChannels = ~dirtLocal[\numOutputBusChannels] ? 2; // set this to your hardware output channel size, if necessary (local: or in superdirt_local.scd)
	s.options.numInputBusChannels = ~dirtLocal[\numInputBusChannels] ? 2; // set this to your hardware output channel size, if necessary (local: or in superdirt_local.scd)
	~dirtLocal[\device] !? { |name| s.options.device = name }; // local: audio device by name, from superdirt_local.scd (list them with ServerOptions.devices)
	// boot the server and start SuperDirt
	s.waitForBoot {
		~dirt.stop; // stop any old ones, avoid duplicate dirt (if it is nil, this won't do anything)
		~dirt = SuperDirt(~dirtLocal[\numChannels] ? 2, s); // two output channels, increase if you want to pan across more channels (local: or in superdirt_local.scd)
		~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
		// local: project samples would go under <repo>/samples/<name>/*.wav; uncomment to load them as well.
		// ~dirt.loadSoundFiles(~dirtProjectRoot +/+ "samples" +/+ "*");
		(~dirtLocal[\samplePaths] ? []).do { |wildcard| ~dirt.loadSoundFiles(wildcard.standardizePath) }; // local: personal sample folders from superdirt_local.scd
		// s.sync; // optionally: wait for samples to be read
		~dirt.start(57120, 0 ! (~dirtLocal[\numOrbits] ? 12));   // start listening on port 57120, create two busses each sending audio to channel 0 (local: orbit count from superdirt_local.scd)
		SuperDirt.default = ~dirt; // make this instance available in sclang (optional)

		// optional, needed for convenient access from sclang:
		(
			~d1 = ~dirt.orbits[0]; ~d2 = ~dirt.orbits[1]; ~d3 = ~dirt.orbits[2];
			~d4 = ~dirt.orbits[3]; ~d5 = ~dirt.orbits[4]; ~d6 = ~dirt.orbits[5];
			~d7 = ~dirt.orbits[6]; ~d8 = ~dirt.orbits[7]; ~d9 = ~dirt.orbits[8];
			~d10 = ~dirt.orbits[9]; ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];
		);

		~dirtLocal[\onStart].value(~dirt); // local: hook from superdirt_local.scd, e.g. MIDI setup or extra SynthDefs

		// local: sc3-plugins is a per-machine install into SuperCollider's Extensions folder (docs/setup.md),
		// not something this file can load. Without it SuperDirt warns "sc3plugins are necessary and missing"
		// and skips the extra synths and effects that need it; the core sounds still work.
	};

	s.latency = ~dirtLocal[\latency] ? 0.3; // increase this if you get "late" messages (local: or in superdirt_local.scd)
};
);
