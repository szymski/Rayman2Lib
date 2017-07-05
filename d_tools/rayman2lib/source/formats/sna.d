module formats.sna;

import std.stdio, std.conv, std.algorithm, core.memory, consoled, std.array;
import std.file : read;
import std.path : baseName;
import decoder, utils, global, formats.relocationtable, formats.pointertable;

struct SNAPart {
	ubyte id;
	ubyte block;
	uint size;
	uint position;
	uint dataPosition;
	ubyte* dataPointer;
}

class SNAFormat
{
	string name = "Unknown";
	ubyte[] data;
	MemoryReader reader;
	SNAPart[] parts;

	this(string filename)
	{
		name = baseName(filename).replace(".sna", "");
		this(cast(ubyte[])read(filename));
	}

	this(ubyte[] data)
	{
		if(logging)
			writecln(Fg.lightMagenta, "Parsing SNA");
		this.data = decodeData(data);
		loadedSnas ~= this;
		parse();
	}

	private void parse() {
		reader = new MemoryReader(data);

		reader.read!uint; // Skip first 4 bytes

		do {
			SNAPart part;

			part.position = reader.position;

			part.id  = reader.read!ubyte;
			part.block = reader.read!ubyte;
			auto v32 = reader.read!ubyte;
			auto somethingRelatedToRelocation = reader.read!int;

			if(somethingRelatedToRelocation != -1) {
				auto v42 = reader.read!uint;
				auto v27 = reader.read!uint;
				auto v33 = reader.read!uint;
				part.size = reader.read!uint;

				part.dataPosition = reader.position;
				part.dataPointer = data.ptr + reader.position;

				//writecln(Fg.lightGreen, "SNA Part ID: ", Fg.white, part.id, Fg.lightYellow, "\tLocation: ", Fg.white, "0x", reader.position.to!string(16));

				uint relocationValue = cast(uint)part.dataPointer - somethingRelatedToRelocation;

				if(part.size != 0) {
					if(logging)
						writecln(Fg.lightYellow, "Relocation id - ", Fg.white, "0x", (10 * part.id + part.block).to!string(16), ": 0x", relocationValue.to!string(16), Fg.lightYellow, "\t\tSub: ", Fg.white, "0x", somethingRelatedToRelocation.to!string(16));
					gptPointerRelocation[10 * part.id + part.block] = relocationValue;
				}

				//writecln(Fg.lightGreen, "SNA Relocation ID: ", Fg.white, "0x", (10 * part.id + memorySomething).to!string(16), Fg.lightGreen, "\t\tPoints at ", Fg.white, "0x", reader.position.to!string(16));
				//writeln("Part data pointer: 0x", part.dataPointer);
				//writeln("somethingRelatedToRelocation: 0x", somethingRelatedToRelocation.to!string(16));
				//writeln([v42, v27, v33].map!"a.to!string(16)");

				parts ~= part;

				reader.position += part.size;
			}
			else {
				parts ~= part;
				writeln("Empty SNA block");
			}
		}
		while(!reader.eof);
	}

	void relocatePointersUsingFile(string filename) {
		writecln(Fg.lightMagenta, "Relocating SNA pointers using RTB");
		readRelocationTableFromFile(filename);

		relocate();
	}

	void relocatePointersUsingBigFile(string filename, uint offset, uint magic) {
		writecln(Fg.lightMagenta, "Relocating SNA pointers using big file");
		readRelocationTableFromBigFile(filename, offset, magic);

		relocate();
	}

	void relocatePointersUsingBigFileAuto(string filename) {
		writecln(Fg.lightMagenta, "Relocating SNA pointers using big file");
		readRelocationTableFromBigFileAuto(filename, name, RelocationTableType.rtb);
		
		relocate();
	}

	private void relocate() {
		// TODO: Debug file, remove later
//		import std.stdio;
//		auto file = File("dump_" ~ name ~ ".csv", "w");
//		file.writeln("sep=;\nRaw address location;Raw address;File;After relocation");
		
		foreach(part; parts) {
			if(part.size <= 0)
				continue;
			
			PointerRelocationHeader header;
			
			foreach(relocHeader; relocationHeaders) {
				if(relocHeader.partId == part.id && relocHeader.block == part.block) {
					header = relocHeader;
					break;
				}
			}
			
			foreach(i; header.index .. header.index + header.size) {
				PointerRelocationInfo relocValue = relocationKeyValues[i];
				
				uint* rawAddress = cast(uint*)(relocValue.dword0 + gptPointerRelocation[10 * part.id + part.block]);
				uint before = cast(uint)*rawAddress;
				*rawAddress += gptPointerRelocation[10 * relocValue.byte4 + relocValue.byte5];
				
				// TODO: Debug info, remove later
				import core.sys.windows.windows;
				
				auto snaLocation = pointerToSNALocation(cast(void*)*rawAddress);
				
//				file.write("0x", (cast(uint)rawAddress - cast(uint)data.ptr).to!string(16), ";");
//				file.write("0x", before.to!string(16), ";");
//				if(snaLocation.valid) {
//					file.write(snaLocation.name, ";0x", snaLocation.address.to!string(16));
//				}
//				file.writeln();
				
				//				writec(Fg.lightGreen, "SNA Relocation: ", Fg.lightYellow, "Raw", Fg.white, " = 0x", before.to!string(16), Fg.lightYellow, "\t\tRelocated", Fg.white, " = 0x", cast(void*)*rawAddress);
				//				if(!IsBadReadPtr(cast(void*)*rawAddress, 1))
				//					writec(Fg.lightBlue, "\tValue pointing at ", Fg.white, "0x", (*(cast(ubyte*)*rawAddress)).to!string(16));
				//				if(snaLocation.valid)
				//					writec(Fg.cyan, "\t", snaLocation.name, ": ", Fg.white, "0x", snaLocation.address.to!string(16));
				//				writeln();
			}
		}

//		file.close();
	}

	auto getRelocationDataUsingFile(string filename) {
		readRelocationTableFromFile(filename);
		
		return getRelocationData();
	}
	
	auto getRelocationDataUsingBigFile(string filename, uint offset, uint magic) {
		readRelocationTableFromBigFile(filename, offset, magic);
		
		return getRelocationData();
	}

	auto getRelocationDataUsingBigFileAuto(string filename) {
		readRelocationTableFromBigFileAuto(filename, name, RelocationTableType.rtb);
		
		return getRelocationData();
	}

	private auto getRelocationData() {
		struct Pointer {
			int address;
			int value;
		}

		Pointer[] pointers;

		foreach(part; parts) {
			if(part.size <= 0)
				continue;
			
			PointerRelocationHeader header;
			
			foreach(relocHeader; relocationHeaders) {
				if(relocHeader.partId == part.id && relocHeader.block == part.block) {
					header = relocHeader;
					break;
				}
			}
			
			foreach(i; header.index .. header.index + header.size) {
				PointerRelocationInfo relocValue = relocationKeyValues[i];
				
				uint* rawAddress = cast(uint*)(relocValue.dword0 + gptPointerRelocation[10 * part.id + part.block]);
				uint before = cast(uint)*rawAddress;
				
				auto snaLocation = pointerToSNALocation(cast(void*)(*rawAddress + gptPointerRelocation[10 * relocValue.byte4 + relocValue.byte5]));

				if(snaLocation.valid)
					pointers ~= Pointer(cast(uint)rawAddress - cast(uint)data.ptr, snaLocation.address);
			}
		}

		return pointers;
	}

	void printInfo() {
		foreach(part; parts) {
			writeln("Part id: ", part.id, "\n\tSize: ", part.size);
		}
	}
} 