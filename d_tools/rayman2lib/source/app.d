import std.stdio, std.file, std.traits;
import decoder, formats.gpt, formats.levels0dat, formats.sna, global;

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
	//readRelocationTableFromBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT");
	SNAFormat snaFormat = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.sna");
	GPTFormat gptFormat = new GPTFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.gpt");
}