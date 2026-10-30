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

The post window reports success with:
	SuperDirt: listening to Tidal on port 57120

SuperDirt.start (one line, no file) starts SuperDirt with close to the same defaults and remains
the quickest check when something is wrong: use it to tell a server problem from a problem in this file.
*/

(
// local: project-relative paths must be captured here, synchronously; the callbacks below run later,
// after thisProcess.nowExecutingPath has been reset (it is nil when evaluated from an unsaved buffer).
~dirtProjectRoot = thisProcess.nowExecutingPath !? { |path| path.dirname.dirname };

s.reboot { // server options are only updated on reboot
	// configure the sound server: here you could add hardware specific options
	// see http://doc.sccode.org/Classes/ServerOptions.html
	s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
	s.options.memSize = 8192 * 32; // increase this if you get "alloc failed" messages
	s.options.numWireBufs = 2048; // increase this if you get "exceeded number of interconnect buffers" messages
	s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
	s.options.numOutputBusChannels = 2; // set this to your hardware output channel size, if necessary
	s.options.numInputBusChannels = 2; // set this to your hardware output channel size, if necessary
	// boot the server and start SuperDirt
	s.waitForBoot {
		~dirt.stop; // stop any old ones, avoid duplicate dirt (if it is nil, this won't do anything)
		~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
		~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
		// local: project samples would go under <repo>/samples/<name>/*.wav; uncomment to load them as well.
		// ~dirt.loadSoundFiles(~dirtProjectRoot +/+ "samples" +/+ "*");
		// s.sync; // optionally: wait for samples to be read
		~dirt.start(57120, 0 ! 12);   // start listening on port 57120, create two busses each sending audio to channel 0
		SuperDirt.default = ~dirt; // make this instance available in sclang (optional)

		// optional, needed for convenient access from sclang:
		(
			~d1 = ~dirt.orbits[0]; ~d2 = ~dirt.orbits[1]; ~d3 = ~dirt.orbits[2];
			~d4 = ~dirt.orbits[3]; ~d5 = ~dirt.orbits[4]; ~d6 = ~dirt.orbits[5];
			~d7 = ~dirt.orbits[6]; ~d8 = ~dirt.orbits[7]; ~d9 = ~dirt.orbits[8];
			~d10 = ~dirt.orbits[9]; ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];
		);

		// local: sc3-plugins is a per-machine install into SuperCollider's Extensions folder (docs/setup.md),
		// not something this file can load. Without it SuperDirt warns "sc3plugins are necessary and missing"
		// and skips the extra synths and effects that need it; the core sounds still work.
	};

	s.latency = 0.3; // increase this if you get "late" messages
};
);
