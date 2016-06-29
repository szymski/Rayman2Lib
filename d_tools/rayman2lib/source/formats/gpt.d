module formats.gpt;

import std.stdio, std.conv;
import std.file : read;
import decoder, utils, global;

class GPTFormat
{
	ubyte[] data;
	
	this(string filename)
	{
		this(cast(ubyte[])read(filename));
	}
	
	this(ubyte[] data)
	{
		writeln("Parsing GPT");
		this.data = data;
		parse();
	}
	
	private void parse() {
		auto r = new MemoryReader(data);

		// TODO: Debug
		printMemory(relocationKeyValues.ptr, 128, 8);

		auto ptr = r.readPointer();
		writeln(ptr, " - ", *ptr);
		ptr = r.readPointer();
	}
}

T readPointer(T = ubyte*)(MemoryReader r) {
	ubyte byte4 = relocationKeyValues[pointerRelocationInfoIndex].byte4, byte5 = relocationKeyValues[pointerRelocationInfoIndex].byte5;
	pointerRelocationInfoIndex++;
	
	auto relativeAddress = r.read!uint;
	uint result = relativeAddress;
	
	relativeAddress &= ~0xFF;
	relativeAddress |= byte5;
	
	uint v1 = relativeAddress + 10 * byte4;
	v1 &= 0xFF;

	writeln("Before relocation: ", cast(void*)result);
	writeln("byte4: ", byte4, "\tbyte5: ", byte5, "\tlocationInOffsetArray: 0x", v1.to!string(16));
	result += cast(uint)gptPointerRelocation[v1];
	writeln("After relocation: ", cast(void*)result);
	
	return cast(T)result;

//	ubyte byte4 = relocationKeyValues[pointerRelocationInfoIndex].byte4;
//	ubyte byte5 = relocationKeyValues[pointerRelocationInfoIndex].byte5;
//	pointerRelocationInfoIndex++;
//
//	auto relativeAddress = r.read!uint;
//	writeln("Before relocation: 0x", relativeAddress.to!string(16));
//	writeln("byte4: ", byte4, "\tbyte5: ", byte5, "\tlocationInOffsetArray: 0x", (byte5 * 10 * byte4).to!string(16));
//
//	auto result = relativeAddress + gptPointerRelocation[byte5 * 10 * byte4];
//	writeln("After relocation: 0x", result.to!string(16));
//
//	return cast(T)result;
}