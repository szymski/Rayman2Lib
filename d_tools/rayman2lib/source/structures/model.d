module structures.model;

/*
	Single model elements
*/

// Model_INDEX_LEVEL

struct Model_0_0 {
	Model_0_1* model_0_1;
	Model_0_0* nextTwin;
}

struct Model_0_1 {
	uint unknown1; // Always? 0x00000000
	Model_0_2* model_0_2; // Always? 0x01000000 (LE)
	Model_1_2* model_1_2;
	void* gliData;
}

struct Model_0_2 {
	uint unknown1;
	ObjectData_0_1* objectData; // Object address
}

struct ObjectData_0_1 {
	ubyte[36] unknown;
	uint flags;
}

struct Model_1_2 {
	uint unknown1;
	uint unknown2;
	Model_0_3* model_0_3;
}

struct Model_0_3 {
	Vertex* vertices;
	void* unknownPointer2;
	void** unknownPointer3;
	uint unknown;
	void* unknownPointer4;
	Model_0_4* model_0_4;
}

struct Model_0_4 {
	Model_0_5* model_0_5;
	void* unknownPointer2;
}

struct Model_0_5 {
	TextureInfo_0* textureInfo_0;
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

/*
	Texture info
*/

struct TextureInfo_0 {
	TextureInfo_1* textureInfo_1;
}

struct TextureInfo_1 {
	ubyte[72] unknown;
	TextureInfo_2* textureInfo_2;
}

struct TextureInfo_2
{
	ubyte[8] something1_2;
	uint something3;
	ubyte[8] something4_5;
	uint something6;
	ushort h;
	ushort w;
	ushort h2;
	ushort w2;
	ubyte[12] gap20;
	uint dword2C; 
	ubyte[21] gap30;
	ubyte byte45;
	char[130] textureFilename;
};

/*
	Grouped models
*/

struct GroupedModel_0 {
	GroupedModel_1* groupedModel_1;
	GroupedModel_1_1* groupedModel_1_1;
}

struct GroupedModel_1 {
	void* unknownPointer1;
	void* unknownPointer2;
	void* unknownPointer3;
	void* unknownPointer4;
}

struct GroupedModel_1_1 {
	uint unknown1;
	uint unknown2;
	uint unknown3;
	void* unknownPointer1;
	ubyte[0x28] gap1;
	void* unknownPointer2;
	uint unknown4;
	uint unknown5;
	char* name;
}