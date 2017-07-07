module structures.sector;

import structures.model, structures.entity;
import global;
import consoled;

struct Matrix {
	float[16] fields;
}

struct Sector {
	uint type;
	SectorInfo* info;
	Sector* firstChild;
	ubyte[8] unknown2;
	Sector* nextTwin;
	Sector* previousTwin;
	Sector* parent;
	int unknown3;
	Matrix* matrix;
	ubyte[8] unknown4;
	void* someShit;

	/**
		Includes self.
	*/
	Sector*[] getTwins() {
		Sector*[] twins;

		Sector* twin = &this;
		
		while(twin != null) {
			twins ~= twin;
			twin = twin.nextTwin;
		}
		
		return twins;
	}

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
			printAddressInformation(child.info.firstModel);
				
			child.printChildrenInfo(level + 1);
		}
	}
}

struct SectorInfo {
	union {
		Model_0_0* firstModel; // For type 32
		//Entity1* firstEntity;
		Sector** firstSuperObject;  // For type 4
		RenderInfo* renderInfo; // For type 2
	}
	union {
		void* radiosity;
		SOStandardGameStruct* standardGameStruct;
	}
	void* lightType;
	ubyte[84] unknown1;
	ubyte* minPointInBorder;
	ubyte[8] unknown2;
	ubyte* maxPointInBorder;
}

struct RenderInfo {
	Sector* someSuperObject;
	void* animState;
	void* anotherState;
	void* field_C;
	void* dword10;
}

struct struct_v13 {
	void* dword0;
	Model_0_0* renderInfo;
}