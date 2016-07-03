module utils;

import std.conv, std.stdio, std.traits;

class MemoryReader {
	ubyte[] data;
	uint position;

	this(ubyte[] data) {
		this.data = data;
		this.position = 0;
	}

	T read(T)() {
		static if(isArray!T) {
			T t;
			(cast(ubyte*)t.ptr)[0 .. t.sizeof] = data[position .. position + t.sizeof];
			position += t.sizeof;
			return t;
		}
		else {
			T value = *(cast(T*)data[position .. position + T.sizeof].ptr);
			position += T.sizeof;
			return value;
		}
	}

	bool isEof() {
		return position >= data.length;
	}
}

unittest {
	MemoryReader r = new MemoryReader([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

	assert(r.read!ubyte == 0);
	assert(r.read!ubyte == 1);
	assert(r.read!ushort == 0x0302);
	assert(r.read!(ushort[2]) == [0x0504, 0x0706]);
	assert(r.read!ubyte == 0x08);
}

class MemoryWriter {
	ubyte[] data;
	uint position;

	this(size_t initialSize = 0) {
		data.reserve(initialSize);
		this.position = 0;
	}

	this(ubyte[] data) {
		this.data = data;
		this.position = 0;
	}
	
	void write(T)(T value) {
		static if(isArray!T) {
			if(position + value.sizeof > data.length)
				data.length += value.length * value[0].sizeof;

			data[position .. position + value.length * value[0].sizeof] = (cast(ubyte*)value.ptr)[0 .. value.length * value[0].sizeof];
			position += value.length * value[0].sizeof;
		}
		else {
			if(position + T.sizeof > data.length)
				data.length += T.sizeof;

			data[position .. position + T.sizeof] = (cast(ubyte*)&value)[0 .. T.sizeof];
			position += T.sizeof;
		}
	}
	
	bool isEof() {
		return position >= data.length;
	}
}

unittest {
	MemoryWriter w = new MemoryWriter();
	
	w.write!ushort(0xADDE);
	w.write!ubyte(0xBE);
	w.write([0x030201EF]);
	w.write(0x11223344);
	w.write("abcd");

	assert(w.data == [0xDE, 0xAD, 0xBE, 0xEF, 0x01, 0x02, 0x03, 0x44, 0x33, 0x22, 0x11, 0x61, 0x62, 0x63, 0x64]);
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
	static if(isArray!T) {
		T t;
		f.rawRead(t);
		return t;
	}
	else {
		T[1] array;
		f.rawRead(array);
		return array[0];
	}
}

void printStruct(T)(T obj) {
	foreach(member; __traits(allMembers, T))
		mixin("writeln(\"" ~ member ~ "\", \":\", obj." ~ member ~ ");");
}