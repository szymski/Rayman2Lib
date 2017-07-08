module handlers.dsb;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, formats.gpt, structures.model, global, utils, structures.superobject, formats.dsb;

mixin registerHandlers;

/*
	Tests sectors.
*/

@handler
void dsb(string[] args) {
	debug {
		args ~= r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\Game.dsb";
	}

	ubyte[] dsbData = cast(ubyte[])std.file.read(args[0]);

	DSBScript dsb = new DSBScript(dsbData);
	dsb.parse();
}