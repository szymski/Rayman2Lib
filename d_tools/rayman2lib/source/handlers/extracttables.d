module source.handlers.extracttables;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, formats.gpt, structures.model, global, utils, structures.superobject, formats.dsb, formats.datfile;

mixin registerHandlers;

/*
	Extracts relocation tables from LEVELS0.dat to the level directories.
*/

@handler
void extracttables(string[] args) {
	debug {
		args ~= r"D:\GOG Games\Rayman 2\Data\World\Levels";
	}

    if(args.length < 1) {
        writeln("Usage: extracttables levels directory");
        return;
    }

    string levelsDirectory = args[0];
    string levels0DatPath = buildPath(levelsDirectory, "LEVELS0.DAT");

    if(!exists(levels0DatPath)) {
        writeln("LEVELS0.DAT file does not exist in that folder!");
        return;
    }

    foreach(entry; dirEntries(levelsDirectory, SpanMode.shallow)) {
        if(entry.isDir)
            processLevelDirectory(levelsDirectory, entry.name.baseName);
    }
}

private void processLevelDirectory(string levelsDir, string levelName) {
    string levels0DatPath = buildPath(levelsDir, "LEVELS0.DAT");
    string levelDir = buildPath(levelsDir, levelName);

    writeln("Processing level ", levelName);

    dumpRelocationTableToFile(levels0DatPath, levelName, buildPath(levelDir, levelName ~ ".rtb"), RelocationTableType.rtb);
    dumpRelocationTableToFile(levels0DatPath, levelName, buildPath(levelDir, levelName ~ ".rtp"), RelocationTableType.gpt);
    dumpRelocationTableToFile(levels0DatPath, levelName, buildPath(levelDir, levelName ~ ".rts"), RelocationTableType.rts);
    dumpRelocationTableToFile(levels0DatPath, levelName, buildPath(levelDir, levelName ~ ".rtt"), RelocationTableType.rtt);
}

private void dumpRelocationTableToFile(string levels0DatPath, string levelName, string path, RelocationTableType type) {
    File bigFile = File(levels0DatPath, "rb");

    SplitInt id;

	id = getLevelId(levelName);
	id.byte1 = cast(ubyte)type;

	uint offset = bigFile.getOffsetInBigFile(id.value);
	magic = getMagicForTable(id.value);

	initBigFile(bigFile, offset, magic);
    auto data = bigFile.readEncoded!(ubyte[1024 * 256])(magic);

    std.file.write(path, data);
    writeln("Relocation table dumped to ", path);
}