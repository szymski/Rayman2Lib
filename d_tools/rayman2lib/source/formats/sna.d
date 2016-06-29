module formats.sna;

import std.stdio, std.conv, std.algorithm, core.memory;
import std.file : read;
import decoder, utils, global;

struct SNAPart {
	ubyte id;
	uint size;
	uint position;
	ubyte* dataPointer;
}

class SNAFormat
{
	ubyte[] data;
	SNAPart[] parts;

	this(string filename)
	{
		this(cast(ubyte[])read(filename));
	}

	this(ubyte[] data)
	{
		writeln("Parsing SNA");
		this.data = decodeData(data);
		loadedSnas ~= this;
		parse();
	}

	private void parse() {
		auto reader = new MemoryReader(data);

		reader.read!uint; // Skip first 4 bytes

		do {
			SNAPart part;

			part.position = reader.position;

			part.id  = reader.read!ubyte;
			auto memorySomething = reader.read!ubyte;
			auto v32 = reader.read!ubyte;
			auto somethingRelatedToRelocation = reader.read!uint;

			if(somethingRelatedToRelocation != -1) {
				auto v42 = reader.read!uint;
				auto v27 = reader.read!uint;
				auto v33 = reader.read!uint;
				part.size = reader.read!uint;

				part.dataPointer = data.ptr + reader.position;
				gptPointerRelocation[10 * part.id + memorySomething] = cast(uint)part.dataPointer - somethingRelatedToRelocation;
				writeln("SNA Relocation ID: 0x", (10 * part.id + memorySomething).to!string(16));
				//writeln("Part data pointer: 0x", part.dataPointer);
				//writeln("somethingRelatedToRelocation: 0x", somethingRelatedToRelocation.to!string(16));
				//writeln([v42, v27, v33].map!"a.to!string(16)");

				parts ~= part;

				reader.position += part.size;
			}
			else {
				writeln("Empty SNA block");
			}
		}
		while(!reader.isEof);
	}

	void printInfo() {
		foreach(part; parts) {
			writeln("Part id: ", part.id, "\n\tSize: ", part.size);
		}
	}
}

