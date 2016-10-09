module handlers.other;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, global, utils, structures.sector;

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

struct GliTexture
{
	ubyte[8] something1_2;
	uint something3;
	ubyte[8] something4_5;
	uint something6;
	ushort h;
	ushort w;
	ushort h2;
	ushort w2;
	ubyte[12] gap20;
	uint dword2C; 
	ubyte[21] gap30;
	ubyte byte45;
	char[130] textureFilename;
};

@handler
void resizetextures(string[] args) {
	SNAFormat levelSna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.sna");
	readRelocationTableFromBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", 97017856, 0x41212953);
	PointerTableFormat ptx = new PointerTableFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.ptx");
	
	ptx.read!uint;
	uint count = ptx.read!uint / 4;
	
	foreach(i; 0 .. count) {
		auto texture = ptx.readPointer!(GliTexture*);
		
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

void printSectorInfo(Sector* sector) {
	writecln(Fg.lightMagenta, "Testing sectors");
	
	printAddressInformation(sector);
	sector.printChildrenInfo();
}