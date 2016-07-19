module formats.sna;

import std.stdio, std.conv, std.algorithm, core.memory, consoled;
import std.file : read;
import std.path : baseName;
import decoder, utils, global, formats.levels0dat, formats.gpt;

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
		name = baseName(filename);
		this(cast(ubyte[])read(filename));
	}

	this(ubyte[] data)
	{
		writecln(Fg.lightMagenta, "Parsing SNA");
		this.data = decodeData(data);
		loadedSnas ~= this;
		parse();

		//writecln(Fg.lightMagenta, "SNA Relocation table: ");
		//foreach(i, v; gptPointerRelocation)
		//	if(v != 0)
		//		writecln(Fg.white, "\t0x", i.to!string(16), ": 0x", v.to!string(16));
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
		while(!reader.isEof);
	}

	void relocatePointersUsingFile(string filename) {
		writecln(Fg.lightMagenta, "Relocating SNA pointers");
		readRelocationTableFromFile(filename);

		MemoryWriter writer = new MemoryWriter(data);

		foreach(part; parts) {
			if(part.size == 0)
				continue;

			PointerRelocationHeader currentHeader;

			pointerRelocationInfoIndex = 0;

			foreach(header; relocationHeaders) {
				if(header.partId == part.id && header.block == part.block) {
					currentHeader = header;
					pointerRelocationInfoIndex = header.index;
					//writeln("found");
					//writeln(relocationKeyValues[pointerRelocationInfoIndex].dword0.to!string(16));
					break;
				}
			}

			uint lastPosition = part.dataPosition;

			foreach(i; 0 .. currentHeader.size) {
				reader.position = lastPosition;
				writer.position = lastPosition;

				auto value = relocationKeyValues[pointerRelocationInfoIndex];

				bool done;

				foreach(j; (lastPosition - part.dataPosition) .. part.size / 4 - (part.size % 4)) {
					auto ptr = reader.read!uint;

					if(value.dword0 == ptr) {
						auto before = ptr;
											ptr += gptPointerRelocation[value.byte5 + 10 * value.byte4];
						
											auto snaLocation = pointerToSNALocation(cast(void*)ptr);
						
											import core.sys.windows.windows;
						
											writec(Fg.lightGreen, "SNA Relocation: ", Fg.lightYellow, "Raw", Fg.white, " = 0x", before.to!string(16), Fg.lightYellow, "\t\tRelocated", Fg.white, " = 0x", cast(void*)ptr);
											if(!IsBadReadPtr(cast(void*)ptr, 1))
												writec(Fg.lightBlue, "\tValue pointing at ", Fg.white, "0x", (*(cast(ubyte*)ptr)).to!string(16));
											if(snaLocation.valid)
												writec(Fg.cyan, "\t", snaLocation.name, ": ", Fg.white, "0x", snaLocation.address.to!string(16));
											writeln();

						done = true;
						lastPosition = reader.position;

						break;
					}
				}

				if(!done) {
					reader.position = part.dataPosition;
					writer.position = part.dataPosition;

					foreach(j; 0 .. part.size / 4 - (part.size % 4)) {
						auto ptr = reader.read!uint;
						
						if(value.dword0 == ptr) {
							auto before = ptr;
							ptr += gptPointerRelocation[value.byte5 + 10 * value.byte4];
							
							auto snaLocation = pointerToSNALocation(cast(void*)ptr);
							
							import core.sys.windows.windows;
							
							writec(Fg.lightGreen, "SNA Relocation: ", Fg.lightYellow, "Raw", Fg.white, " = 0x", before.to!string(16), Fg.lightYellow, "\t\tRelocated", Fg.white, " = 0x", cast(void*)ptr);
							if(!IsBadReadPtr(cast(void*)ptr, 1))
								writec(Fg.lightBlue, "\tValue pointing at ", Fg.white, "0x", (*(cast(ubyte*)ptr)).to!string(16));
							if(snaLocation.valid)
								writec(Fg.cyan, "\t", snaLocation.name, ": ", Fg.white, "0x", snaLocation.address.to!string(16));
							writeln();
							
							done = true;
							lastPosition = reader.position;
							
							break;
						}
					}
				}

				pointerRelocationInfoIndex++;
			}

//			foreach(i; 0 .. part.size - (part.size % 4)) {
//				auto ptr = reader.read!uint;
//
//				auto value = relocationKeyValues[pointerRelocationInfoIndex];
//
//				if(value.dword0 == ptr) {
//					pointerRelocationInfoIndex++;
//
//					auto before = ptr;
//					ptr += gptPointerRelocation[value.byte5 + 10 * value.byte4];
//
//					auto snaLocation = pointerToSNALocation(cast(void*)ptr);
//
//					import core.sys.windows.windows;
//
//					writec(Fg.lightGreen, "SNA Relocation: ", Fg.lightYellow, "Raw", Fg.white, " = 0x", before.to!string(16), Fg.lightYellow, "\t\tRelocated", Fg.white, " = 0x", cast(void*)ptr);
//					if(!IsBadReadPtr(cast(void*)ptr, 1))
//						writec(Fg.lightBlue, "\tValue pointing at ", Fg.white, "0x", (*(cast(ubyte*)ptr)).to!string(16));
//					if(snaLocation.valid)
//						writec(Fg.cyan, "\t", snaLocation.name, ": ", Fg.white, "0x", snaLocation.address.to!string(16));
//					writeln();
//				}
//			}
		}
	}

	void relocatePointersUsingBigFile() {
		
	}

	void printInfo() {
		foreach(part; parts) {
			writeln("Part id: ", part.id, "\n\tSize: ", part.size);
		}
	}
}