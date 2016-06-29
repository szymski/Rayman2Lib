module utils;

import std.conv, std.stdio;

class MemoryReader {
	ubyte[] data;
	uint position;

	this(ubyte[] data) {
		this.data = data;
		this.position = 0;
	}

	T read(T)() {
		T value = *(cast(T*)data[position .. position + T.sizeof].ptr);
		position += T.sizeof;
		return value;
	}

	bool isEof() {
		return position >= data.length;
	}
}

unittest {
	MemoryReader r = MemoryReader([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

	assert(r.read!ubyte == 0);
	assert(r.read!ubyte == 1);
	assert(r.read!ushort == 0x0302);
}

void printMemory(void* pointer, size_t size, ubyte inOneLine = 16) {
	while(size > 0) {
		string charStr = ""; // String on the right, bytes translated into chars

		write(pointer, ":\t"); // On the left, memory address

		int times = (size < inOneLine ? size : inOneLine);
		for(int i = 0; i < times; i++) {
			string hexStr = (*(cast(ubyte*)pointer)).to!string(16);

			if(hexStr.length == 1) // Add zero on the left, if necessary
				hexStr = "0" ~ hexStr;

			write(hexStr, " ");

			char c = cast(char)*(cast(ubyte*)pointer);
			if(c < 32) // Remove special characters
				c = '.';
			charStr ~= c;

			pointer++;
			size--;
		}

		writeln("\t", charStr);
	}
}

T readType(T)(File f) {
	T[1] array;
	f.rawRead(array);
	return array[0];
}

void printStruct(T)(T obj) {
	foreach(member; __traits(allMembers, T))
		mixin("writeln(\"" ~ member ~ "\", \":\", obj." ~ member ~ ");");
}