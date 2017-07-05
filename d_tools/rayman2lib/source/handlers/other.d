module handlers.other;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, global, utils, structures.sector, structures.model;

mixin registerHandlers;

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
	PointerTableFormat ptx = new PointerTableFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.ptx");
	
	printMemory(relocationKeyValues.ptr, 512, 8);
	
	ptx.read!uint;
	uint count = ptx.read!uint / 4;
	
	foreach(i; 0 .. count) {
		ptx.readPointer();
	}
}

/*
	Handler supposed to resize textures of SNA file, so
	enlarged textures don't get downscaled.
	Doesn't work for some reason.
*/

@handler
void resizetextures(string[] args) {
	SNAFormat levelSna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.sna");
	readRelocationTableFromBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", 97017856, 0x41212953);
	PointerTableFormat ptx = new PointerTableFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.ptx");
	
	ptx.read!uint;
	uint count = ptx.read!uint / 4;
	
	foreach(i; 0 .. count) {
		auto texture = ptx.readPointer!(TextureInfo_2*);
		
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

@handler
void snarelocation(string[] args) {
	debug {
		args ~= r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.sna";
		args ~= r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT";
		args ~= "79187968";
		args ~= "1982693709";
	}

	logging = false;

	if(args.length < 2) {
		writeln("Usage: snarelocation snafile relocationfile");
		writeln("Usage: snarelocation snafile bigfile bigfileoffset bigfilemagic");
		return;
	}

	string snaFile = args[0];

	if(args.length < 3 || !args[2].isNumeric) {
		string relocationFile = args[1];
		
		SNAFormat sna = new SNAFormat(snaFile);
		auto pointers = sna.getRelocationDataUsingFile(relocationFile);

		foreach(ptr; pointers)
			writeln(ptr.address, " ", ptr.value);
	}
	else {
		string bigfile = args[1];
		
		SNAFormat sna = new SNAFormat(snaFile);
		auto pointers = sna.getRelocationDataUsingBigFileAuto(bigfile);

		foreach(ptr; pointers)
			writeln(ptr.address, " ", ptr.value);
	}
}

@handler
void decodeall(string[] args) {
	debug {
		args ~= r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\";
	}

	if(args.length == 0) {
		writeln("Usage: decodeall path [wildcardfilename] [-allbytes]");
		writeln("-allbytes - doesn't skip first 4 bytes");
		return;
	}

	string path = args[0];
	string wildcard = args.length >= 2 ? args[1] : "*.sna";
	bool skipFirstBytes = !args.canFind("-allbytes");

	foreach(entry; dirEntries(path, wildcard, SpanMode.depth)) {
		string afterDecodeName = entry.name.dirName ~ "/" ~ entry.name.baseName ~ ".decoded";

		writecln(Fg.lightGreen, "Decoding ", Fg.white, entry.name.baseName, Fg.lightGreen, " to ", Fg.white, afterDecodeName.baseName);

		auto file = File(entry.name);

		ubyte[] data = new ubyte[cast(uint)file.size];

		file.rawRead(data);
		file.close();

		data = decodeData(data, firstMagicNumber, skipFirstBytes);

		std.file.write(afterDecodeName, data);
	}
}