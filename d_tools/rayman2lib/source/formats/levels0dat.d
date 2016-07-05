﻿module formats.levels0dat;

import decoder, utils, global, consoled;
import std.file : read;
import std.stdio, std.conv;

private uint magic = 0;

void readRelocationTableFromBigFile(string filename, uint position, uint magic) {
	writeln("Reading relocation table from LEVELS0.DAT");
	File f = File(filename, "r");
	initBigFile(f, position, magic);
	parseBigFile(f);

	pointerRelocationInfoIndex = 0;
}

void readRelocationTableFromRTPFile(string filename) {
	writeln("Reading relocation table from RTP file");
	File f = File(filename, "r");
	parseRTPFile(f);

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
	
	foreach(i; 0 .. count) {
		ubyte moduleId = f.readEncoded!ubyte;
		ubyte blockId = f.readEncoded!ubyte;
		uint size = f.readEncoded!uint;
		
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

private void parseRTPFile(File f) {
	ubyte count = f.readType!ubyte;
	
	f.readType!uint;
	
	int lRelocationKeyValuesIndex = 0;
	
	foreach(i; 0 .. count) {
		ubyte moduleId = f.readType!ubyte;
		ubyte blockId = f.readType!ubyte;
		uint size = f.readType!uint;
		
		foreach(j; 0 .. size) {
			auto value = f.readType!PointerRelocationInfo;
			
			relocationKeyValues[lRelocationKeyValuesIndex] = value;
			lRelocationKeyValuesIndex++;
			
			//printStruct(value);
		}
		
		//writeln("Module: ", moduleId, " Block: ", blockId, " Size: ", size);
	}
}