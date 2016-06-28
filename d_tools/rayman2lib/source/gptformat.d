module gptformat;

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
		this.data = data;
		parse();
	}
	
	private void parse() {
		auto r = new MemoryReader(data);

		// TODO: Debug
		printMemory(relocationKeyValues.ptr, 128);

		//r.readPointer();
		auto ptr = r.readPointer();
		//printMemory(ptr, 1024);

		//writeln(*r.readPointer()); // This is supposed to be 0A
		//writeln(*cast(uint*)r.readPointer()); // This is supposed to be 9C 58 5A 02
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
	writeln("v1: ", v1.to!string(16));
	result += cast(uint)gptPointerRelocation[v1];
	writeln("After relocation: ", cast(void*)result);

	return cast(T)result;
}