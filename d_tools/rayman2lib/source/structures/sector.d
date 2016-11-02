module structures.sector;

import structures.model;
import global;
import consoled;

struct Sector {
	uint type;
	SectorInfo_0* info0;
	Sector* firstChild;
	ubyte[8] unknown2;
	Sector* nextTwin;
	ubyte[20] unknown3;
	void* someShit;

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
			printAddressInformation(child.info0.firstModel);
				
			child.printChildrenInfo(level + 1);
		}
	}
}

struct SectorInfo_0 {
	Model_0_0* firstModel; // sectorInfo?
	void* radiosity;
	void* lightType;
	ubyte[84] unknown1;
	ubyte* minPointInBorder;
	ubyte[8] unknown2;
	ubyte* maxPointInBorder;
}