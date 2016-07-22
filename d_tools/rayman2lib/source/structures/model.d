module structures.model;

// Only the part used by GLI Send Triangles func
//struct Model {
//	void* gap0;
//	ushort faceCount;
//	ushort unknown;
//	void* indicesPointer;
//	void* unknownPointer1;
//	void* unknownPointer2;
//	void* unknownPointer3;
//}

// Model_INDEX_LEVEL

struct Model_0_0 {
	uint unknown1; // Always? 0x00000000
	uint unknown2; // Always? 0x01000000 (LE)
	Model_0_1* model_0_1;
	void* unknownPointer2;
}

struct Model_0_1 {
	uint unknown1;
	uint unknown2;
	Model_0_2* model_0_2;
}

struct Model_0_2 {
	Vertex* vertices;
	void* unknownPointer2;
	void** unknownPointer3;
	uint unknown;
	void* unknownPointer4;
	Model_0_3* model_0_3;
}

struct Model_0_3 {
	Model_0_4* model_0_4;
	void* unknownPointer2;
}

struct Model_0_4 {
	void* unknownPointer1;
	ushort faceCount;
	ushort unknown;
	VertexFace* indices;
	UVFace* uvIndices; // float u, float v
	float* vertices; // float 1, float 2, float 3, float 4 - No idea what this is
	UV* uvs;
}

struct VertexIndex {
	ushort xIndex;
	ushort yIndex;
	ushort zIndex;
}

struct Vertex {
	float x, y, z;
}

struct VertexFace {
	ushort xIndex, yIndex, zIndex;
}

struct UV {
	float u, v;
}

struct UVFace {
	ushort xIndex, yIndex, zIndex;
}