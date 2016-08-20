module structures.sector;

import global;
import consoled;

struct Sector {
	uint type;
	SectorInfo_0* info0;
	Sector* firstChild;
	ubyte[8] unknown2;
	Sector* nextTwin;

	Sector*[] getChildren() {
		Sector*[] children;

		Sector* child = firstChild;

		while(child != null) {
			children ~= child;
			child = child.nextTwin;
		}

		return children;
	}

	void printChildrenInfo(int level = 0) {
		foreach(child; getChildren) {
			foreach(i; 0 .. level)
				writec("\t");

			writec(Fg.white, "Child - ");
			printAddressInformation(child);

			writec("Some addr: ");
			printAddressInformation(child.info0.modelAddress);

			child.printChildrenInfo(level + 1);
		}
	}
}

struct SectorInfo_0 {
	ubyte* modelAddress;
	ubyte[92] unknown;
	ubyte* minPointInBorder;
	ubyte[8] unknown2;
	ubyte* maxPointInBorder;
}