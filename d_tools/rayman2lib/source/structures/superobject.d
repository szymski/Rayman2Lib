module structures.superobject;

import structures.model, structures.gamestruct;
import global;
import consoled;
import gfm.math.matrix;
import gfm.math.vector;

struct Matrix {
	float[16] fields;
	mat4f toMat4f() {
		return mat4f.fromRows([
				vec4f(fields[4], fields[7], fields[10], fields[1]),
				vec4f(fields[5], fields[8], fields[11], fields[2]),
				vec4f(fields[6], fields[9], fields[12], fields[3]),
				vec4f(0, 0, 0, 1),
			]);
	}
}

struct SuperObject {
	uint type;
	union {
		SectorInfo* info;
		Model_0_0* firstModel; // For type 8
	}
	SuperObject* firstChild;
	ubyte[8] unknown2;
	SuperObject* nextTwin;
	SuperObject* previousTwin;
	SuperObject* parent;
	int unknown3;
	Matrix* matrix;
	ubyte[8] unknown4;
	void* someShit;

	/**
		Includes self.
	*/
	SuperObject*[] getTwins() {
		SuperObject*[] twins;

		SuperObject* twin = &this;
		
		while(twin != null) {
			twins ~= twin;
			twin = twin.nextTwin;
		}
		
		return twins;
	}

	SuperObject*[] getChildren() {
		SuperObject*[] children;

		SuperObject* child = firstChild;

		while(child != null) {
			children ~= child;
			child = child.nextTwin;
		}

		return children;
	}
}

struct SectorInfo {
	union {
		Model_0_0* firstModel; // For type 32
		SuperObject** firstSuperObject;  // For type 4
		RenderInfo* renderInfo; // For type 2
	}
	union {
		void* radiosity; // For type 32
		SOStandardGameStruct* standardGameStruct;
	}
	void* lightType;
	ubyte[84] unknown1;
	ubyte* minPointInBorder;
	ubyte[8] unknown2;
	ubyte* maxPointInBorder;
}

struct RenderInfo {
	SuperObject* someSuperObject;
	void* animState;
	void* anotherState;
	void* field_C;
	void* dword10;
}

struct struct_v13 {
	void* dword0;
	Model_0_0* renderInfo;
}