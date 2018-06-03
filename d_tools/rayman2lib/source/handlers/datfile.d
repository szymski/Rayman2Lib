module handlers.datfile;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats, std.math;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, formats.datfile, global, utils, structures.superobject, formats.datfile;

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

	File fout2 = File("output/out.bin", "wb");

	foreach(k; 0 .. 16)
	foreach(j; 0 .. 16)
	foreach(i; 0 .. 16) {
		SplitInt id;
		id = cast(ubyte)i; // Level id
		id.byte1 = cast(ubyte)j; // Relocation table type
		id.byte2 = cast(ubyte)k;
		id.byte3 = cast(ubyte)k;

		uint magic = getMagicForTable(id);
		uint offset = getOffsetInBigFile(f, id);
		writeln(offset);

//		File fout = File("output/%s.bin".format(i), "wb");

		f.seek(offset);
		ubyte[] data = f.readEncoded!(ubyte[10240])(magic);
		fout2.rawWrite(data);
//		fout.rawWrite(data);

//		fout.close();
	}

	fout2.close();
}