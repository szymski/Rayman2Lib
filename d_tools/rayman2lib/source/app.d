import std.stdio, std.file, std.traits;
import decoder, formats.gpt, formats.levels0dat, formats.sna, global, utils;

void main(string[] args)
{
	debug {
		args ~= "relocation";
	}

	if(args.length <= 1) {
		writeln("Usage: ", args[0], " option");
		return;
	}

	if(auto handleFunc = args[1] in handlers)
		(*handleFunc)();
	else
		writeln("No such option");
}

void function()[string] handlers;

static this() {
	mixin("import thisModule = " ~ __MODULE__ ~ ";");

	foreach(member; __traits(allMembers, thisModule))
		static if(isSomeFunction!(mixin(member)) && hasUDA!(mixin(member), handler))
			mixin("handlers[member] = &" ~ member ~ ";");
}

struct handler;

@handler
void test() {
	writeln("I'm a test!");
}

@handler
void relocation() {
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

	readRelocationTableFromBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT");
	SNAFormat levelSna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.sna");
	GPTFormat levelGpt = new GPTFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.gpt");

	// List of Learn_30.gpt pointers
	auto pointerCount = levelGpt.readPointer!uint;

	foreach(i; 0 .. pointerCount) {
		auto v23 = levelGpt.readPointer!(ubyte*);

		auto v24 = levelGpt.readPointer!(ubyte*);

		levelGpt.readPointer!(ubyte*);
		levelGpt.readPointer!(ubyte*);
		levelGpt.readPointer!(ubyte*);
		levelGpt.readPointer!(ubyte*);
	}

	//readRelocationTableFromBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT");
}