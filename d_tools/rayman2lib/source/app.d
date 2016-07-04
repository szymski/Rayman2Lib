import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv;
import decoder, formats.gpt, formats.levels0dat, formats.sna, formats.cnt, formats.gf, global, utils;
import consoled, imageformats;

void main(string[] args)
{
	debug {
		args ~= "resizetextures";
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

void function(string[])[string] handlers;

static this() {
	mixin("import thisModule = " ~ __MODULE__ ~ ";");

	foreach(member; __traits(allMembers, thisModule))
		static if(isSomeFunction!(mixin(member)) && hasUDA!(mixin(member), handler))
			mixin("handlers[member] = &" ~ member ~ ";");
}

struct handler;

@handler
void test(string[]) {
	writeln("I'm a test!");
}

@handler
void gpt(string[]) {
	writeln("Testing GPT relocation.");

	readRelocationTableFromRTPFile(r"D:\GOG Games\Rayman 2\Data\World\Levels\Fix.rtp");
	SNAFormat sna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.sna");
	GPTFormat gpt = new GPTFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.gpt");

	// List of Fix.gpt pointers
	auto POS_g_p_stIdentityMatrix = gpt.readPointer!(float*);

	foreach(i; 0 .. (0x00516148 - 0x516080))
		gpt.readPointer();
	// TODO

	writeln("\nNow Learn_30 level");

	readRelocationTableFromBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", 67540992, 0x207CDEEF);
	SNAFormat levelSna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.sna");
	GPTFormat levelGpt = new GPTFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.gpt");

	// List of Learn_30.gpt pointers
	auto pointerCount = levelGpt.readPointer!uint;
	auto v23 = levelGpt.readPointer!(ubyte*);

	/*
	auto pointerCount = levelGpt.readPointer!uint;

	foreach(i; 0 .. pointerCount) {
		writeln("Reading table");
		auto v23 = levelGpt.readPointer!(ubyte*);

		auto v24 = levelGpt.readPointer!(ubyte*);

		levelGpt.readPointerBlock(0x58);
		levelGpt.readPointer!(ubyte*);
		levelGpt.readPointerBlock(0x4);
		levelGpt.readPointer!(ubyte*);
		levelGpt.readPointer!(ubyte*);
		levelGpt.readPointer!(ubyte*);
	}

	writeln("Ended reading table");

	auto gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	gp_stActualWorld = levelGpt.readPointer!(ubyte*);
*/

	//readRelocationTableFromBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT");
}

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

@handler
void unpackcnt(string[] args) {
	debug {
		args ~= r"Textures.cnt";
		args ~= "-png";
	}

	if(args.length == 0) {
		writecln(Fg.white, "Usage: unpackcnt filename [outputfolder] [-png]", Fg.initial);
		return;
	}

	string cntFilename = args[0];
	bool toPng = args.canFind("-png");

	CNTFormat cnt = new CNTFormat(cntFilename);

	string outputDir = (args.length == 2 && !args[1].startsWith("-")) ? args[1] ~ "/" : baseName(cntFilename) ~ ".extracted/";

	foreach(file; cnt.fileList) {
		mkdirRecurse(outputDir ~ file.directory);
		if(!toPng)
			std.file.write(outputDir ~ file.directory ~ "/" ~ file.name, file.data);
		else
			new GFFormat(file.data).saveToPng(outputDir ~ file.directory ~ "/" ~ file.name ~ ".png");
	}
}

@handler
void packcnt(string[] args) {
	debug {
		args ~= r"TexturesHD.cnt.extracted";
	}
	
	if(args.length == 0) {
		writecln(Fg.white, "Usage: packcnt folder [outputname]", Fg.initial);
		return;
	}

	if(!exists(args[0]) || !isDir(args[0])) {
		writecln(Fg.red, "No such directory", Fg.initial);
		return;
	}
	
	string outputName = (args.length == 2) ? args[1] : baseName(args[0]).replace(".extracted", "");

	CNTFile[] cntFileList;

	foreach(name; dirEntries(args[0], SpanMode.depth)) {
		if(!name.isDir && name.extension == ".png") {
			IFImage image = read_png(name, ColFmt.RGBA);

			GFFormat gf = new GFFormat();
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
	cnt.archiveVersion = CNTVersion.rayman2;
	foreach(cntFile; cntFileList)
		cnt.fileList ~= cntFile;
		
	cnt.build();

	std.file.write(outputName, cnt.data);
	writecln(Fg.lightMagenta, "Done!", Fg.initial);
}

/*
	Handler supposed to resize textures of SNA file.
*/

@handler
void resizetextures(string[] args) {
	
}