module formats.dsb;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats, std.math;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, global, utils, structures.sector;

class DSBScript {
	ubyte[] data;
	MemoryReader r;

	this(ubyte[] data) {
		this.data = decodeData(data);
		r = new MemoryReader(this.data);
		r.position = 4;
	}

	void parse() {
		uint sectionId;

		while((sectionId = r.read!uint) != 0xFFFF) {
			writeln(sectionId);

			switch(sectionId) {
				case 0x00:
					parse_1();
					break;
				case 0x1E:
					parse_2();
					break;
				case 0x28:
					parse_3();
					break;
				default:
					break;
			}
		}
	}

	// Only memory allocations
	private void parse_1() {
		uint id;

		while((id = r.read!uint) != 0xFFFF) {
			switch(id) {
				case 0x10:
					r.read!uint;
					goto default;
				default:
					r.read!uint;
				break;
			}
		}
	}

	// Levels
	private void parse_2() {
		uint id;
		
		while((id = r.read!uint) != 0xFFFF) {
			switch(id) {
				case 0x1F:
					writeln(r.read!string);
					break;
				default:
					break;
			}
		}
	}

	// Levels
	private void parse_3() {
		uint id;
		
		while((id = r.read!uint) != 0xFFFF) {
			switch(id) {
				case 0x1F:
					writeln(r.read!string);
					break;
				default:
					break;
			}
		}
	}

}

private string readString(MemoryReader r, size_t length) {
	return "";
}