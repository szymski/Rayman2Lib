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
		EngineObject* engineObject;
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

struct EngineObject {
	union {
		Model_0_0* firstModel; // For type 32
		SuperObject** firstSuperObject;  // For type 4
		RenderInfo* renderInfo; // For type 2
	}
	union {
		void* radiosity; // For type 32
		SOStandardGameStruct* standardGameStruct; // For type 2
	}
	union {
		void* lightType;
		DNM_stDynamics** dynamics; // For type 4
	}
	Mind* mind;
	int isCamera;
	ubyte[76] unknown1;
	ubyte* minPointInBorder;
	ubyte[8] unknown2;
	ubyte* maxPointInBorder;

	bool hasDynamics() {
		return dynamics != null && *dynamics != null;
	}
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

struct DNM_stDynamics {
	ubyte field_0;
	ubyte field_1;
	ubyte field_2;
	ubyte field_3;
	int idcard;
	int stateOrUsedMechanics;
	int dwordC;
	ubyte gap10[44];
	float float3C;
	float float40;
	float *pfloat44;
	float[3] scale;
	float speedVector;
	float float58;
	float float5C;
	ubyte gap60[12];
	float float6C;
	float float70;
	float float74;
	float[3] *vector_B;
	float[3] position;
}

struct Mind {
	Intelligence* normalIntelligence;
}

struct Intelligence {
	uint field_0;
	void* rules;
	IntelligenceField8* field_8;
	uint field_C;
	IntelligenceField10* field_10;
}

struct IntelligenceField8 {
	tdstNodeInterpret** firstNode;
	uint field_4;
	ubyte byte_8;
}

struct IntelligenceField10 {
	ubyte* field_0;
	ubyte field_4;
	ubyte field_5;
	ubyte field_6;
	ubyte field_7;
}

struct tdstNodeInterpret {
	int tableIndex;
	ubyte field_4;
	ubyte field_5;
	ubyte param;
	ubyte functionType;

	tdstNodeInterpret* prevNode() {
		return &this - 1;
	}

	tdstNodeInterpret* nextNode() {
		return &this + 1;
	}
}

struct tdstGetSetParam {
	int conditionByte;
	int parameter_2;
	int parameter_3;
	int type;
}