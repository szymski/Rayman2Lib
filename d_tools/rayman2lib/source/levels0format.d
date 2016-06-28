module levels0format;

import std.stdio, std.conv;
import std.file : read;
import decoder, utils, global;

uint magic = 0;

void readRelocationTable(string filename) {
	File f = File(filename, "r");
	initBigFile(f);
	parseBigFile(f);
}

void initBigFile(File f) {
	f.seek(149460992, SEEK_SET);
	magic = 0x78A94BED;

	f.readEncoded!uint;
}

void parseBigFile(File f) {
	ubyte count = f.readEncoded!ubyte;
	
	f.readEncoded!uint;
	
	int lRelocationKeyValuesIndex = 0;
	
	foreach(i; 0 .. count) {
		ubyte moduleId = f.readEncoded!ubyte;
		ubyte blockId = f.readEncoded!ubyte;
		uint size = f.readEncoded!uint;
		
		foreach(j; 0 .. size) {
			relocationKeyValues[lRelocationKeyValuesIndex] = f.readEncoded!PointerRelocationInfo;
			lRelocationKeyValuesIndex++;
		}
		
		//writeln("Module: ", moduleId, " Block: ", blockId, " Size: ", size);
	}
}

T readEncoded(T)(File f) {
	ubyte[T.sizeof] bytes;

	foreach(i; 0 .. T.sizeof) {
		bytes[i] = decodeByte(f.readType!ubyte, magic);
		magic = getNextMagic(magic);
	}

	return *(cast(T*)bytes.ptr);
}