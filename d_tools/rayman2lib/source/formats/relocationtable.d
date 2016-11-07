module formats.relocationtable;

import decoder, utils, global, consoled, formats.datfile;
import std.file : read;
import std.stdio, std.conv;
import std.algorithm : countUntil;
import std.string : toLower;

private uint magic = 0;

/**
	Reads relocation table from specific position from big file LEVELS0.DAT.
*/
void readRelocationTableFromBigFile(string filename, uint position, uint magic) {
	if(logging)
		writeln("Reading relocation table from LEVELS0.DAT");

	File f = File(filename, "r");
	initBigFile(f, position, magic);
	parseBigFile(f);

	pointerRelocationInfoIndex = 0;
}

enum RelocationTableType {
	rtb = 0,
	gpt = 1,
	rts = 2, // NOT SURE
}

/**
	Automatically loads relocation table based on level name and table type.
*/
void readRelocationTableFromBigFileAuto(string filename, string levelname, RelocationTableType type) {
	File f = File(filename, "r");

	SplitInt id;
	id = getLevelId(levelname);
	id.byte1 = cast(ubyte)type;

	uint offset = f.getOffsetInBigFile(id.value);
	uint magic = getMagicForTable(id.value);

	initBigFile(f, offset , magic);
	parseBigFile(f);

	f.close();

	pointerRelocationInfoIndex = 0;
}

/**
	Gets level id based on name. The id is a relocation table id.
*/
private uint getLevelId(string filename) {
	filename = filename.toLower;
	return levelList.countUntil!(l => l.toLower == filename);
}

/**
	Reads relocation table from specific file, for example FIX.RTB.
*/
void readRelocationTableFromFile(string filename) {
	if(logging)
		writeln("Reading relocation table from file");

	File f = File(filename, "r");
	parseFile(f);

	pointerRelocationInfoIndex = 0;
}

private void initBigFile(File f, uint position, uint initialMagic) {
	f.seek(position, SEEK_SET);
	magic = initialMagic;

	f.readEncoded!uint;
}

private void parseBigFile(File f) {
	ubyte count = f.readEncoded!ubyte;
	
	f.readEncoded!uint;
	
	int lRelocationKeyValuesIndex = 0;

	relocationHeaders.length = 0;
	
	foreach(i; 0 .. count) {
		ubyte moduleId = f.readEncoded!ubyte;
		ubyte blockId = f.readEncoded!ubyte;
		uint size = f.readEncoded!uint;

		relocationHeaders ~= PointerRelocationHeader(moduleId, blockId, lRelocationKeyValuesIndex, size);

		foreach(j; 0 .. size) {
			auto value = f.readEncoded!PointerRelocationInfo;

			relocationKeyValues[lRelocationKeyValuesIndex] = value;
			lRelocationKeyValuesIndex++;

			//printStruct(value);
		}
		
		//writeln("Module: ", moduleId, " Block: ", blockId, " Size: ", size);
	}
}

private T readEncoded(T)(File f) {
	ubyte[T.sizeof] bytes;

	foreach(i; 0 .. T.sizeof) {
		bytes[i] = decodeByte(f.readType!ubyte, magic);
		magic = getNextMagic(magic);
	}

	return *(cast(T*)bytes.ptr);
}

private void parseFile(File f) {
	ubyte count = f.readType!ubyte;
	
	f.readType!uint;
	
	int lRelocationKeyValuesIndex = 0;

	relocationHeaders.length = 0;
	
	foreach(i; 0 .. count) {
		ubyte moduleId = f.readType!ubyte;
		ubyte blockId = f.readType!ubyte;
		uint size = f.readType!uint;

		relocationHeaders ~= PointerRelocationHeader(moduleId, blockId, lRelocationKeyValuesIndex, size);
		
		foreach(j; 0 .. size) {
			auto value = f.readType!PointerRelocationInfo;
			
			relocationKeyValues[lRelocationKeyValuesIndex] = value;
			lRelocationKeyValuesIndex++;
			
			//printStruct(value);
		}
		
		//writeln("Module: ", moduleId, " Block: ", blockId, " Size: ", size);
	}
}