module api;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, global, utils, structures.sector, formats.gpt, structures.model;
import core.sys.windows.windows, core.sys.windows.wtypes;
import core.stdc.stdlib : free;
import core.memory : GC;

version(dll):

__gshared {
	string levels0datPath;
	string fixSnaPath;
	FixGPT fixGpt;
}

extern(C):

export void setLevels0datPath(char* path) {
	levels0datPath = path.fromStringz.idup;
	//MessageBoxA(null, toStringz("Path has been set to " ~ path.fromStringz), "rayman2lib", MB_OK);
}

export void setFixSnaPath(char* path) {
	fixSnaPath = path.fromStringz.idup;
	//MessageBoxA(null, toStringz("Path has been set to " ~ path.fromStringz), "rayman2lib", MB_OK);
}

export bool loadFiles() {
	string fixBasePath = dirName(fixSnaPath);

	try {
		SNAFormat sna = new SNAFormat(fixBasePath ~ "/Fix.sna");
		sna.relocatePointersUsingFile(fixBasePath ~ "/Fix.rtb");	
		readRelocationTableFromFile(fixBasePath ~ "/Fix.rtp");
		fixGpt = new FixGPT(fixBasePath ~ "/Fix.gpt");
	}
	catch(Exception e) {
		debug MessageBoxA(null, e.toString.toStringz, "rayman2lib", MB_OK);
		return false;
	}

	return true;
}

struct Api_MeshExportInfo {
	uint numMeshes;
	Api_MeshExport* meshes;
}

struct Api_MeshExport {
	uint numSubMeshes;
	Api_SubMesh* subMeshes;
}

struct Api_SubMesh {
	uint numVertices;
	Vertex* vertices;
	uint numUVs;
	UV* uvs;
	uint numFaces;
	VertexFace* vertexFaces;
	UVFace* uvFaces;
	BSTR texture;

//	this() {
//	
//	}
}

export Api_MeshExportInfo* getLevelMesh(char* filename, ref BSTR obj) {
	try {
		string strFilename = filename.fromStringz.idup;
		string levelName = baseName(strFilename).replace(".sna", "");
		string path = dirName(strFilename);

		SNAFormat levelSna = new SNAFormat(path ~ r"\" ~ levelName ~ ".sna");
		levelSna.relocatePointersUsingBigFileAuto(levels0datPath);
		readRelocationTableFromBigFileAuto(levels0datPath, levelName, RelocationTableType.gpt);
		LevelGPT levelGpt = new LevelGPT(path ~ r"\" ~ levelName ~ ".gpt");

		Api_MeshExportInfo* meshExportInfo = exportMesh(levelGpt.SECT_hFatherSector);
	}
	catch(Exception e) {
		debug MessageBoxA(null, e.toString.toStringz, "rayman2lib", MB_OK);
		return null;
	}

	return null;
}

Api_MeshExportInfo* exportMesh(Sector* sector) {
	Api_MeshExport[] meshes;

	void exportModel(Model_0_0* model_0_0) {
		Model_0_1* model_0_1 = model_0_0.model_0_1;

		if(model_0_1 is null || model_0_1.model_1_2 is null)
			return;
		
		Model_0_3* model_0_3 = model_0_1.model_1_2.model_0_3;

		Api_MeshExport meshExport = Api_MeshExport();
		meshes ~= meshExport;

		Api_SubMesh[] subMeshes;

		foreach(j, model_0_5; model_0_3.submodels) {
			if(!model_0_5.textureInfo_0 || !model_0_5.textureInfo_0.textureInfo_1 || !model_0_5.textureInfo_0.textureInfo_1.textureInfo_2 || !model_0_5.indices)
				continue;

			Api_SubMesh subMesh = Api_SubMesh();
			subMeshes ~= subMesh;

			ushort maxVertexIndex = 0;
			foreach(i; 0 .. model_0_5.faceCount) {
				if(model_0_5.indices[i].xIndex > maxVertexIndex)
					maxVertexIndex = model_0_5.indices[i].xIndex;
				if(model_0_5.indices[i].yIndex > maxVertexIndex)
					maxVertexIndex = model_0_5.indices[i].yIndex;
				if(model_0_5.indices[i].zIndex > maxVertexIndex)
					maxVertexIndex = model_0_5.indices[i].zIndex;
			}
			maxVertexIndex++;

			subMesh.numVertices = maxVertexIndex;
			subMesh.vertices = new Vertex[maxVertexIndex].ptr;
			GC.removeRange(subMesh.vertices);
			subMesh.vertices[0 .. maxVertexIndex] = model_0_3.vertices[0 .. maxVertexIndex];
			
			ushort maxUVIndex = 0;
			foreach(i; 0 .. model_0_5.faceCount) {
				if(model_0_5.uvIndices[i].xIndex > maxUVIndex)
					maxUVIndex = model_0_5.uvIndices[i].xIndex;
				if(model_0_5.uvIndices[i].yIndex > maxUVIndex)
					maxUVIndex = model_0_5.uvIndices[i].yIndex;
				if(model_0_5.uvIndices[i].zIndex > maxUVIndex)
					maxUVIndex = model_0_5.uvIndices[i].zIndex;
			}	
			maxUVIndex++;

			subMesh.numUVs = maxUVIndex;
			subMesh.uvs = new UV[maxUVIndex].ptr;
			GC.removeRange(subMesh.uvs);
			subMesh.uvs[0 .. maxUVIndex] = model_0_5.uvs[0 .. maxUVIndex];

			subMesh.numFaces = model_0_5.faceCount;
		
			subMesh.vertexFaces = new VertexFace[model_0_5.faceCount].ptr;
			GC.removeRange(subMesh.vertexFaces);
			subMesh.vertexFaces[0 .. model_0_5.faceCount] = model_0_5.indices[0 ..model_0_5.faceCount];
			subMesh.uvFaces = new UVFace[model_0_5.faceCount].ptr;
			GC.removeRange(subMesh.uvFaces);
			subMesh.uvFaces[0 .. model_0_5.faceCount] = model_0_5.uvIndices[0 ..model_0_5.faceCount];
		}

		meshExport.numSubMeshes = subMeshes.length;
		GC.removeRange(subMeshes.ptr);
		meshExport.subMeshes = subMeshes.ptr;
	}

	void exportAllModels(Sector* sector) {
		foreach(currSector; sector.getTwins()) {
			if(currSector.info0) {
				if(currSector.type == 32 || currSector.type == 8 || currSector.type == 4) {
					if(currSector.info0.firstModel)
						exportModel(currSector.info0.firstModel);
				}
			}
			
			if(currSector.firstChild)
				exportAllModels(currSector.firstChild);
		}
	}

	Api_MeshExportInfo* exportInfo = new Api_MeshExportInfo();
	GC.removeRange(exportInfo);

	GC.removeRange(meshes.ptr);
	exportInfo.numMeshes = meshes.count;
	exportInfo.meshes = meshes.ptr;

	return exportInfo;
}

export void deleteMeshExportInfo(Api_MeshExportInfo* ptr) {
	
}

export void free(void* ptr) {
	try
		core.stdc.stdlib.free(ptr);
	catch(Exception e)
		debug MessageBoxA(null, e.toString.toStringz, "rayman2lib", MB_OK);
}