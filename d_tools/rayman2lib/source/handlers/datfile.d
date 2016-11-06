module handlers.datfile;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats, std.math;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, global, utils, structures.sector, formats.datfile;

mixin registerHandlers;

@handler
void readdat(string[] args) {
	debug {
		args ~= r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT";
	}

	if(args.length == 0) {
		writeln("Usage: readdat datfile");
		return;
	}

	File f = File(args[0]);

	uint dataOffset = f.getOffsetInBigFile(0);
	uint magic = getMagicForTable(0);

	f.seek(dataOffset);

	auto data = f.readEncoded!(ubyte[1000])(magic);
	printMemory(data.ptr, 1000);

//	File outF = File("out.bin", "w");
//
//	foreach(i; 0 .. 0xFFFFF) {
//		outF.write("__OFFSET: 0x" ~  ~ "__");
//	}
//
//	outF.close();
}