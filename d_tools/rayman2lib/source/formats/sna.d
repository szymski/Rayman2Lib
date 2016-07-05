module formats.sna;

import std.stdio, std.conv, std.algorithm, core.memory, consoled;
import std.file : read;
import std.path : baseName;
import decoder, utils, global;

struct SNAPart {
	ubyte id;
	uint size;
	uint position;
	ubyte* dataPointer;
}

class SNAFormat
{
	string name = "Unknown";
	ubyte[] data;
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
		auto reader = new MemoryReader(data);

		reader.read!uint; // Skip first 4 bytes

		do {
			SNAPart part;

			part.position = reader.position;

			part.id  = reader.read!ubyte;
			auto memorySomething = reader.read!ubyte;
			auto v32 = reader.read!ubyte;
			auto somethingRelatedToRelocation = reader.read!int;

			if(somethingRelatedToRelocation != -1) {
				auto v42 = reader.read!uint;
				auto v27 = reader.read!uint;
				auto v33 = reader.read!uint;
				part.size = reader.read!uint;

				part.dataPointer = data.ptr + reader.position;
				//writecln(Fg.lightGreen, "SNA Part ID: ", Fg.white, part.id, Fg.lightYellow, "\tLocation: ", Fg.white, "0x", reader.position.to!string(16));

				uint relocationValue = cast(uint)part.dataPointer - somethingRelatedToRelocation;

				// TODO: Make sure this works well
				if(part.size != 0) {
					writecln(Fg.lightYellow, "Relocation id - ", Fg.white, "0x", (10 * part.id + memorySomething).to!string(16), ": 0x", relocationValue.to!string(16), Fg.lightYellow, "\t\tSub: ", Fg.white, "0x", somethingRelatedToRelocation.to!string(16));
					gptPointerRelocation[10 * part.id + memorySomething] = relocationValue;
				}

				//writecln(Fg.lightGreen, "SNA Relocation ID: ", Fg.white, "0x", (10 * part.id + memorySomething).to!string(16), Fg.lightGreen, "\t\tPoints at ", Fg.white, "0x", reader.position.to!string(16));
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

