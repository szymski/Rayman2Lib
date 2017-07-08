module formats.pointertable;

import std.stdio, std.conv, consoled, core.sys.windows.windows;
import std.file;
import decoder, utils, global;

/**
	Represents a pointer table. For example .GPT file.
*/
class PointerTableFormat
{
	ubyte[] data;
	MemoryReader r;
	
	this(string filename)
	{
		this(cast(ubyte[])std.file.read(filename));
	}
	
	this(ubyte[] data)
	{
		writecln(Fg.lightMagenta, "Parsing pointer table");
		this.data = data;
		parse();
	}
	
	private void parse() {
		pointerRelocationInfoIndex = 0;
		r = new MemoryReader(data);
	}

	/**
		Reads a pointer and relocates it. The returned value should be a valid memory pointer.
	*/
	T readPointer(T = ubyte*)() {
		return r.readPointer!T;
	}

	/**
		Reads a pointer and relocates it. The returned value is a struct with additional pointer information.
	*/
	auto readPointerEx(T = ubyte*)() {
		return r.readPointerEx!T;
	}

	/**
		Reads a block of pointers. Size is specified in bytes.
	*/
	T[] readPointerBlock(T = ubyte*)(int size) {
		assert(size % 4 == 0, "Size must be divisible by 4.");

		T[] arr;

		foreach(i; 0 .. size / 4)
			arr ~= readPointer!T;

		return arr;
	}

	T[] readBlock(T = uint)(int size) {
		//assert(size % 4 == 0, "Size must be divisible by 4.");
		
		T[] arr;
		
		foreach(i; 0 .. size / 4)
			arr ~= read!T;
		
		return arr;
	}

	T read(T)() {
		return r.read!T;
	}

	/**
		Returns true, if end of file.
	*/
	@property bool eof() {
		return r.eof;
	}
}

/**
	Reads a pointer and relocates it. The returned value should be a valid memory pointer.
*/
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

		auto snaLocation = pointerToSnaLocation(cast(void*)result);

		if(relocationLogging) {
			writec(Fg.lightGreen, "GPT Relocation: ", Fg.lightYellow, "Raw", Fg.white, " = 0x", before.to!string(16), Fg.lightYellow, "\t\tRelocated", Fg.white, " = 0x", cast(void*)result);
			if(!IsBadReadPtr(cast(void*)result, 1))
				writec(Fg.lightBlue, "\tValue pointing at ", Fg.white, "0x", (*(cast(ubyte*)result)).to!string(16));
			if(snaLocation.valid)
				writec(Fg.cyan, "\t", snaLocation.name, ": ", Fg.white, "0x", snaLocation.address.to!string(16));
			writeln();
		}
	}
	else {
		if(relocationLogging)
			writecln(Fg.lightGreen, "GPT Relocation: ", Fg.lightYellow, "Raw", Fg.white, " = 0x", result.to!string(16), Fg.red, "\t\tRelocation not performed");
	}

	resetColors();
	
	return cast(T)result;
}

/**
	Reads a pointer and relocates it. The returned value is a struct with additional pointer information.
*/
auto readPointerEx(T = ubyte*)(MemoryReader r) {
	struct return_t {
		uint rawValue;
		T value;
		string snaFile;
		uint snaAddress;
	}

	return_t returnResult;

	uint dword0 = relocationKeyValues[pointerRelocationInfoIndex].dword0;
	ubyte byte4 = relocationKeyValues[pointerRelocationInfoIndex].byte4, byte5 = relocationKeyValues[pointerRelocationInfoIndex].byte5;
	
	auto relativeAddress = r.read!uint;
	uint result = relativeAddress;

	returnResult.rawValue = relativeAddress;

	relativeAddress &= ~0xFF;
	relativeAddress |= byte5;
	
	uint v1 = relativeAddress + 10 * byte4;
	v1 &= 0xFF;
	
	if(result == dword0) {
		pointerRelocationInfoIndex++;

		auto before = result;

		//writeln("byte4: ", byte4, "\tbyte5: ", byte5, "\tlocationInOffsetArray: 0x", v1.to!string(16));
		result += cast(uint)gptPointerRelocation[v1];
		returnResult.value = cast(T)result;

		auto snaLocation = pointerToSnaLocation(cast(void*)result);
		
		if(relocationLogging) {
			writec(Fg.lightGreen, "GPT Relocation: ", Fg.lightYellow, "Raw", Fg.white, " = 0x", before.to!string(16), Fg.lightYellow, "\t\tRelocated", Fg.white, " = 0x", cast(void*)result);
			if(!IsBadReadPtr(cast(void*)result, 1))
				writec(Fg.lightBlue, "\tValue pointing at ", Fg.white, "0x", (*(cast(ubyte*)result)).to!string(16));
			if(snaLocation.valid)
				writec(Fg.cyan, "\t", snaLocation.name, ": ", Fg.white, "0x", snaLocation.address.to!string(16));
			writeln();
		}

		if(snaLocation.valid) {
			returnResult.snaFile = snaLocation.name;
			returnResult.snaAddress = snaLocation.address;
		}
	}
	else {
		if(relocationLogging)
			writecln(Fg.lightGreen, "GPT Relocation: ", Fg.lightYellow, "Raw", Fg.white, " = 0x", result.to!string(16), Fg.red, "\t\tRelocation not performed");
	}
	
	resetColors();
	
	return returnResult;
}