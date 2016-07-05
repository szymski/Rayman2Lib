import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string;
import decoder, formats.gpt, formats.levels0dat, formats.sna, formats.cnt, formats.gf, global, utils;
import consoled, imageformats;

void main(string[] args)
{
	debug {
		args ~= "unpackcnt";
	}

	if(args.length <= 1) {
		writeln("Usage: ", args[0], " option");

		writeln("Available options:");
		foreach(key, value; handlers)
			writeln("\t", key);

		return;
	}

	if(auto handleFunc = args[1] in handlers)
		(*handleFunc)(args[2 .. $]);
	else
		writeln("No such option");
}

/*
	Handler registering.
*/

void function(string[])[string] handlers;

static this() {
	mixin("import thisModule = " ~ __MODULE__ ~ ";");

	foreach(member; __traits(allMembers, thisModule))
		static if(isSomeFunction!(mixin(member)) && hasUDA!(mixin(member), handler))
			mixin("handlers[member] = &" ~ member ~ ";");
}

struct handler;

/*
	Tests GPT relocation.
*/

@handler
void gpt(string[]) {
	readRelocationTableFromRTPFile(r"D:\GOG Games\Rayman 2\Data\World\Levels\Fix.rtp");
	SNAFormat sna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.sna");

	//readFixGpt();

	readLearn_30Gpt();
}

// Finished
void readFixGpt() {
	GPTFormat gpt = new GPTFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.gpt");

	auto POS_g_p_stIdentityMatrix = gpt.readPointer!(float*);
	
	foreach(i; 0 .. 50)
		gpt.readPointer();
	
	auto HIE_g_lNbMatrixInStack = gpt.readPointer!(float*);
	auto dword_50036C = gpt.readPointer!(ubyte*);
	auto dword_501404 = gpt.readPointer!(ubyte*);
	auto dword_5002C0 = gpt.readPointerBlock(0xAC);
	auto dword_50A980 = gpt.readPointer!(ubyte*);
	auto IPT_g_hInputStructure = gpt.readPointerBlock(0xB20);
	auto dword_50A564 = gpt.readPointer!(ubyte*);
	auto dword_500260 = gpt.readPointerBlock(0x14);
	auto tdstStacks = gpt.readPointerBlock(12 * 16);
	auto p_stA3dGENERAL = gpt.readPointer!(ubyte*);
	auto p_a3_xVectors = gpt.readPointer!(ubyte*);
	auto p_a4_xQuaternions = gpt.readPointer!(ubyte*);
	auto p_stHierarchies = gpt.readPointer!(ubyte*);
	auto p_stNTT0 = gpt.readPointer!(ubyte*);
	auto p_stOnlyFrames = gpt.readPointer!(ubyte*);
	auto p_stChannels = gpt.readPointer!(ubyte*);
	auto p_stFrames = gpt.readPointer!(ubyte*);
	auto p_stFramesKF = gpt.readPointer!(ubyte*);
	auto p_stKeyFrames = gpt.readPointer!(ubyte*);
	auto dword_500298 = gpt.readPointer!(ubyte*);
	auto p_stMorphData = gpt.readPointer!(ubyte*);
	auto dword_4B72F0 = gpt.readPointer!(ubyte*);
}

void readLearn_30Gpt() {
	writeln("\nNow Learn_30 level");
	
	readRelocationTableFromBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", 67540992, 0x207CDEEF);
	SNAFormat levelSna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.sna");
	GPTFormat levelGpt = new GPTFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.gpt");
	
	// List of Learn_30.gpt pointers
	
	auto pointerCount = levelGpt.readPointer!uint;

	// TODO: Fix table reading and remove skip
	levelGpt.readPointerBlock(600);

//	foreach(i; 0 .. pointerCount) {
//		writeln("Reading table");
//		auto v23 = levelGpt.readPointer!(ubyte*);
//		
//		//if(v23[4]) {
//		auto v24 = levelGpt.readPointer!(ubyte*);
//		
//		levelGpt.readPointerBlock(0x58);
//		levelGpt.readPointer!(ubyte*);
//		levelGpt.readPointerBlock(0x4);
//		levelGpt.readPointer!(ubyte*);
//		levelGpt.readPointer!(ubyte*);
//		levelGpt.readPointer!(ubyte*);
//		//}
//	}
	
	writeln("Ended reading table");
	
	auto gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	auto gp_stDynamicWorld = levelGpt.readPointer!(ubyte*);
	auto dword_500FC4 = levelGpt.readPointer!(ubyte*);
	auto SECT_hFatherSector = levelGpt.readPointer!(ubyte*);
	auto dword_4FF760 = levelGpt.readPointer!(ubyte*);
	auto g_stAlways = levelGpt.readPointerBlock(0x1C);
	auto dword_4A6B1C = levelGpt.readPointer!(ubyte*);
	auto dword_4A6B20 = levelGpt.readPointer!(ubyte*);
	auto v28 = levelGpt.readPointer!(ubyte*);
	auto v31 = levelGpt.readPointer!(ubyte*);
	auto v32 = levelGpt.readPointer!(ubyte*);
	auto v33 = levelGpt.readPointer!(ubyte*);
	auto dword_5013E0 = levelGpt.readPointerBlock(0x24);
	auto g_EngineMode = levelGpt.readPointerBlock(0xC30);
	auto dword_500374 = levelGpt.readPointer!(ubyte*);
	auto dword_500578 = levelGpt.readPointer!(ubyte*);
	auto g_hCharacterLauchingSoundEvents = levelGpt.readPointer!(ubyte*);
	auto dword_5115CC = levelGpt.readPointer!(ubyte*);
	auto dword_5116A0 = levelGpt.readPointer!(ubyte*);
	auto dword_5115D4 = levelGpt.readPointer!(ubyte*);
	auto dword_5116A4 = levelGpt.readPointer!(ubyte*);
	auto dword_4FAABC = levelGpt.readPointer!(ubyte*);

	foreach(i; 0 .. (0x511634 - 0x511620) / 2) {
		levelGpt.readPointer!(ubyte*);
		levelGpt.readPointer!(ubyte*);
	}

	levelGpt.readPointer!(ubyte*);
	auto tdstStacks = levelGpt.readPointerBlock(12 * 16);
	auto p_stA3dGENERAL = levelGpt.readPointer!(ubyte*);
	auto p_a3_xVectors = levelGpt.readPointer!(ubyte*);
	auto p_a4_xQuaternions = levelGpt.readPointer!(ubyte*);
	auto p_stHierarchies = levelGpt.readPointer!(ubyte*);
	auto p_stNTT0 = levelGpt.readPointer!(ubyte*);
	auto p_stOnlyFrames = levelGpt.readPointer!(ubyte*);
	auto p_stChannels = levelGpt.readPointer!(ubyte*);
	auto p_stFrames = levelGpt.readPointer!(ubyte*);
	auto p_stFramesKF = levelGpt.readPointer!(ubyte*);
	auto p_stKeyFrames = levelGpt.readPointer!(ubyte*);
	levelGpt.readPointerBlock(271480 - 270640);
	auto p_stMorphData = levelGpt.readPointer!(ubyte*);
	auto g_AlphabetCharacterPointer = levelGpt.readPointer!(ubyte*);
	auto g_AlphabetCharacterpointer_new = levelGpt.readPointer!(ubyte*);


}

/*
	Tests PTX pointer relocation.
	Should list pointers to all textures SNA file uses.
*/

@handler
void ptx(string[] args) {
	//readRelocationTableFromRTPFile(r"D:\GOG Games\Rayman 2\Data\World\Levels\Fix.rtp");
	SNAFormat sna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.sna");
	SNAFormat levelSna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.sna");
	readRelocationTableFromBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", 97017856, 0x41212953);
	GPTFormat ptx = new GPTFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.ptx");

	printMemory(relocationKeyValues.ptr, 512, 8);

	ptx.read!uint;
	uint count = ptx.read!uint / 4;

	foreach(i; 0 .. count) {
		ptx.readPointer();
	}
}

/*
	Unpacks CNT archive into a folder.
*/

@handler
void unpackcnt(string[] args) {
	debug {
		args ~= r"Textures.cnt";
		args ~= "-png";
		args ~= "-r2";
	}

	if(args.length == 0) {
		writecln(Fg.white, "Usage: unpackcnt filename [outputfolder] [-png] [-r2] [-r3] ", Fg.initial);
		return;
	}

	GFType type = GFType.rayman2;
	if(args.canFind("-r3"))
		type = GFType.rayman3;

	string cntFilename = args[0];
	bool toPng = args.canFind("-png");

	CNTFormat cnt = new CNTFormat(cntFilename);

	string outputDir = (args.length == 2 && !args[1].startsWith("-")) ? args[1] ~ "/" : baseName(cntFilename) ~ ".extracted/";

	foreach(file; cnt.fileList) {
		mkdirRecurse(outputDir ~ file.directory);
		if(!toPng)
			std.file.write(outputDir ~ file.directory ~ "/" ~ file.name, file.data);
		else
			new GFFormat(file.data, type).saveToPng(outputDir ~ file.directory ~ "/" ~ file.name ~ ".png");
	}
}

/*
	Creates CNT archive from a folder.
*/

@handler
void packcnt(string[] args) {
	debug {
		args ~= r"TexturesHD.cnt.extracted";
	}
	
	if(args.length == 0) {
		writecln(Fg.white, "Usage: packcnt folder [outputname] [-r2] [-r2vignette] [-r3] [-r3vignette]", Fg.initial);
		return;
	}

	if(!exists(args[0]) || !isDir(args[0])) {
		writecln(Fg.red, "No such directory", Fg.initial);
		return;
	}

	CNTVersion type = CNTVersion.rayman2;
	if(args.canFind("-r2vignette"))
		type = CNTVersion.rayman2Vignette;
	if(args.canFind("-r3"))
		type = CNTVersion.rayman3;
	if(args.canFind("-r3vignette"))
		type = CNTVersion.rayman3Vignette;

	GFType gfType = GFType.rayman2;
	if(type == CNTVersion.rayman3)
		gfType = GFType.rayman3;

	string outputName = (args.length >= 2 && !args[1].startsWith("-")) ? args[1] : baseName(args[0]).replace(".extracted", "");

	CNTFile[] cntFileList;

	foreach(name; dirEntries(args[0], SpanMode.depth)) {
		if(!name.isDir && name.extension == ".png") { // TODO: Add support for pure GF files
			IFImage image = read_png(name, ColFmt.RGBA);

			GFFormat gf = new GFFormat(gfType);
			gf.width = image.w;
			gf.height = image.h;
			gf.pixels = cast(uint[])image.pixels;
			gf.build();

			CNTFile cntFile = new CNTFile();
			cntFile.directory = relativePath(dirName(absolutePath(name)), absolutePath(args[0]));
			cntFile.name = baseName(name).replace(".png", "");
			cntFile.data = gf.data;

			cntFileList ~= cntFile;
		}
	}

	writecln(Fg.white, "Packing into ", outputName);

	CNTFormat cnt = new CNTFormat();
	cnt.archiveVersion = CNTVersion.rayman3;
	foreach(cntFile; cntFileList)
		cnt.fileList ~= cntFile;
		
	cnt.build();

	std.file.write(outputName, cnt.data);
	writecln(Fg.lightMagenta, "Done!", Fg.initial);
}

/*
	Transforms GF files into png.
*/

@handler
void gftopng(string[] args) {
	debug {
		args ~= r"r2demo_vignette";
		args ~= r"-r2";
	}
	
	if(args.length == 0) {
		writecln(Fg.white, "Usage: gftopng folder [outputfolder] [-r2] [-r2ios] [-r3]", Fg.initial);
		return;
	}
	
	if(!exists(args[0]) || !isDir(args[0])) {
		writecln(Fg.red, "No such directory", Fg.initial);
		return;
	}

	GFType type = GFType.rayman2;
	if(args.canFind("-r2ios"))
		type = GFType.rayman2ios;
	if(args.canFind("-r3"))
		type = GFType.rayman3;

	string outputDir = (args.length >= 2 && !args[1].startsWith("-")) ? args[1] : args[0] ~ ".png";

	mkdirRecurse(outputDir);

	foreach(name; dirEntries(args[0], SpanMode.depth)) {
		if(!name.isDir && name.extension.toLower == ".gf") {
			mkdirRecurse(outputDir ~ "/" ~ dirName(relativePath(absolutePath(name), absolutePath(args[0]))));
			new GFFormat(name, type).saveToPng(outputDir ~ "/" ~ relativePath(absolutePath(name), absolutePath(args[0])) ~ ".png");
		}
	}
}

/*
	Handler supposed to resize textures of SNA file, so
	enlarged textures don't get downscaled.
	Doesn't work for some reason.
*/

struct GliTexture
{
	ubyte[8] something1_2;
	uint something3;
	ubyte[8] something4_5;
	uint something6;
	ushort h;
	ushort w;
	ushort h2;
	ushort w2;
	ubyte[12] gap20;
	uint dword2C; 
	ubyte[21] gap30;
	ubyte byte45;
	char[130] textureFilename;
};

@handler
void resizetextures(string[] args) {
	SNAFormat levelSna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.sna");
	readRelocationTableFromBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", 97017856, 0x41212953);
	GPTFormat ptx = new GPTFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.ptx");

	ptx.read!uint;
	uint count = ptx.read!uint / 4;
	
	foreach(i; 0 .. count) {
		auto texture = ptx.readPointer!(GliTexture*);

		if(texture !is null) {
			printStruct(*texture);
			writeln(texture.textureFilename.ptr.fromStringz);
			//texture.w = 0;
			//texture.h = 0;
			texture.w2 *= 2;
			texture.h2 *= 2;
			texture.gap30[0]++;
		}
	}

	std.file.write(r"D:\GOG Games\Rayman 2\Data\World\Levels\Learn_30\Learn_30.sna", decodeData(levelSna.data));
}