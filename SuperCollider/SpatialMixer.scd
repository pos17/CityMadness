if(s.hasBooted != true,{
	s.boot;
	"STARTING THE SERVER...".postln;
});
"STARTING THE SYSTEM...".postln;
s.freeAll;
s.doWhenBooted(
	{

		//VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		"SYSTEM STARTED...".postln;
});




Platform.userExtensionDir

Quarks.install("https://github.com/supercollider-quarks/FileLog");
Quarks.install("https://github.com/ambisonictoolkit/atk-sc3.git");
ATK Kernel Installation
(
// Create ATK support directory
// Place unzipped kernels in the directory opened

Atk.createUserSupportDir;
Atk.openUserSupportDir;
)

Soundfile examples
(
// Place unzipped kernels in the directory opened
// Presume Atk.userSupportDir has already been created
Atk.openUserSupportDir;
)

Atk.downloadKernels;
Atk.downloadMatrices;
Atk.downloadSounds;
Atk.openUserSupportDir