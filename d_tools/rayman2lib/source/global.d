module global;

import std.stdio, std.conv;
import formats.sna, consoled;

bool logging = true;

/*
	SNA related stuff
*/

SNAFormat[] loadedSnas;

/*
	Relocation related stuff
*/

bool relocationLogging = true;

struct PointerRelocationHeader { ubyte partId, block; uint index; uint size; }
struct PointerRelocationInfo { uint dword0; ubyte byte4, byte5, byte6, byte7; }

uint[11024] gptPointerRelocation;
uint pointerRelocationInfoIndex = 0;
PointerRelocationHeader[] relocationHeaders; 
PointerRelocationInfo[130240] relocationKeyValues; 

/**
	Translates a memory pointer into SNA file relative pointer.
*/
auto pointerToSNALocation(T)(T* pointer) {
	struct toReturn_t {
		bool valid;
		string name;
		uint address;
	}

	toReturn_t toReturn;

	foreach(sna; loadedSnas) {
		if(pointer >= sna.data.ptr && pointer < sna.data.ptr + sna.data.length) {
			toReturn.valid = true;
			toReturn.name = sna.name;
			toReturn.address = pointer - sna.data.ptr;
			break;
		}
	}

	return toReturn;
}

/**
	Print address information
*/
auto printAddressInformation(void* address) {
	auto snaLocation = pointerToSNALocation(address);

	if(snaLocation.valid)
		writecln(Fg.cyan, "\t", snaLocation.name, ": ", Fg.white, "0x", snaLocation.address.to!string(16));
	else
		writecln("Not a valid SNA address");
}

/**
	Index of the level in this table is the index of relocation table used by the level.
*/
string[] levelList = [
	"Menu", "Jail_10", "Jail_20", "Mapmonde", "Learn_10", "Learn_30", "Bonux", "Learn_31",
	"Bast_20", "Bast_22", "Learn_60", "Ski_10", "Vulca_10", "Vulca_20", "Ski_60",
	"Batam_10", "Chase_10", "Ly_10", "Chase_22", "Rodeo_10", "Rodeo_40", "Rodeo_60",
	"nego_10", "Water_10", "Water_20", "GLob_30", "GLob_10", "GLob_20", "Whale_00",
	"Whale_05", "Whale_10", "Plum_00", "Plum_10", "Bast_09", "Bast_10", "Cask_10",
	"Cask_30", "Batam_20", "Nave_10", "Nave_15", "Nave_20", "Seat_10", "Seat_11",
	"Earth_10", "Earth_20", "Ly_20", "Earth_30", "Helic_10", "Helic_20", "Helic_30",
	"Plum_20", "Morb_00", "Morb_10", "Morb_20", "Learn_40", "Ball", "ile_10", "Mine_10",
	"Boat01", "Boat02", "Astro_00", "Astro_10", "Rhop_10", "end_10", "staff_10",
	"poloc_10", "poloc_20", "poloc_30", "poloc_40", "Raycap",
];