module global;

import formats.sna;

SNAFormat[] loadedSnas;

struct PointerRelocationHeader { ubyte partId, block; uint index; uint size; }
struct PointerRelocationInfo { uint dword0; ubyte byte4, byte5, byte6, byte7; }

uint[1024] gptPointerRelocation;
uint pointerRelocationInfoIndex = 0;
PointerRelocationHeader[] relocationHeaders; 
PointerRelocationInfo[30240] relocationKeyValues; 

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