module formats.gpt;

import std.stdio, std.conv, consoled, core.sys.windows.windows;
import std.file : read;
import decoder, utils, global;

class GPTFormat
{
	ubyte[] data;
	MemoryReader r;
	
	this(string filename)
	{
		this(cast(ubyte[])std.file.read(filename));
	}
	
	this(ubyte[] data)
	{
		writecln(Fg.lightMagenta, "Parsing GPT");
		this.data = data;
		parse();
	}
	
	private void parse() {
		r = new MemoryReader(data);
	}

	T readPointer(T = ubyte*)() {
		return r.readPointer!T;
	}

	T[] readPointerBlock(T = ubyte*)(int size) {
		assert(size % 4 == 0, "Size must be divisible by 4.");

		T[] arr;

		foreach(i; 0 .. size / 4)
			arr ~= readPointer!T;

		return arr;
	}

	T read(T)() {
		return r.read!T;
	}
}

T readPointer(T = ubyte*)(MemoryReader r) {
	uint dword0 = relocationKeyValues[pointerRelocationInfoIndex].dword0;
	ubyte byte4 = relocationKeyValues[pointerRelocationInfoIndex].byte4, byte5 = relocationKeyValues[pointerRelocationInfoIndex].byte5;
	
	auto relativeAddress = r.read!uint;
	uint result = relativeAddress;
	
	relativeAddress &= ~0xFF;
	relativeAddress |= byte5;
	
	uint v1 = relativeAddress + 10 * byte4;
	v1 &= 0xFF;

	if(result == dword0) {
		pointerRelocationInfoIndex++;
		//writeln("byte4: ", byte4, "\tbyte5: ", byte5, "\tlocationInOffsetArray: 0x", v1.to!string(16));
		auto before = result;
		result += cast(uint)gptPointerRelocation[v1];

		auto snaLocation = pointerToSNALocation(cast(void*)result);

		writec(Fg.lightGreen, "GPT Relocation: ", Fg.lightYellow, "Raw", Fg.white, " = 0x", before.to!string(16), Fg.lightYellow, "\t\tRelocated", Fg.white, " = 0x", cast(void*)result);
		if(!IsBadReadPtr(cast(void*)result, 1))
			writec(Fg.lightBlue, "\tValue pointing at ", Fg.white, "0x", (*(cast(ubyte*)result)).to!string(16));
		if(snaLocation.valid)
			writec(Fg.cyan, "\t", snaLocation.name, ": ", Fg.white, "0x", snaLocation.address.to!string(16));
		writeln();
	}
	else
		writecln(Fg.lightGreen, "GPT Relocation: ", Fg.lightYellow, "Raw", Fg.white, " = 0x", result.to!string(16), Fg.red, "\t\tRelocation not performed");

	resetColors();
	
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