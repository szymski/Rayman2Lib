module snaformat;

import std.stdio;
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
		this.data = decodeData(data);
		loadedSnas ~= this;
		parse();
	}

	private void parse() {
		auto r = new MemoryReader(data);

		r.read!uint; // Skip first 4 bytes

		do {
			SNAPart part;

			part.position = r.position;

			part.id  = r.read!ubyte;
			auto memorySomething = r.read!ubyte;
			auto v32 = r.read!ubyte;
			auto somethingRelatedToRelocation = r.read!uint;

			auto v42 = r.read!uint;
			auto v27 = r.read!uint;
			auto v33 = r.read!uint;
			part.size = r.read!uint;

			part.dataPointer = data.ptr + r.position;
			gptPointerRelocation[10 * part.id + memorySomething] = cast(uint)(part.dataPointer);

			parts ~= part;

			r.position += part.size;
		}
		while(!r.isEof);
	}

	void printInfo() {
		foreach(part; parts) {
			writeln("Part id: ", part.id, "\n\tSize: ", part.size);
		}
	}
}

