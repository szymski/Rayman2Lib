module handlers.models;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, global, utils, structures.superobject;

mixin registerHandlers;

/**
	Exports a model to the specified directory.
*/
void exportModel(void* address, string path = "models") {
	import structures.model;
	
	writeln("Exporting model");
	
	Model_0_0* model_0_0 = cast(Model_0_0*)address;
	Model_0_1* model_0_1 = model_0_0.model_0_1;

	// Obj model creation

	if(model_0_1 is null ||
		model_0_1.model_1_2 is null || !isValidSnaAddress(model_0_1.model_1_2) ||
		model_0_1.model_1_2.model_0_3 is null || !isValidSnaAddress(model_0_1.model_1_2) || !isValidSnaAddress(model_0_1.model_1_2.model_0_3) ||
		model_0_1.model_1_2.model_0_3.model_0_4 is null)
		return;

	Model_0_3* model_0_3 = model_0_1.model_1_2.model_0_3;

	auto snaLocation = pointerToSnaLocation(address);

	foreach(j, model_0_5; model_0_3.submodels) {

		if(!model_0_5.textureInfo_0 || !model_0_5.textureInfo_0.textureInfo_1 || !model_0_5.textureInfo_0.textureInfo_1.textureInfo_2 || !model_0_5.indices)
			continue;

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

		string fileBaseName = snaLocation.name ~ "_0x" ~ address.to!string ~ "_" ~ j.to!string;

		mkdirRecurse(path);

		File f = File(path ~ "/" ~ fileBaseName  ~ ".obj", "w");
		File fMtl = File(path ~ "/" ~ fileBaseName  ~ ".mtl", "w");

		// Materials
		f.writeln("mtllib ", fileBaseName, ".mtl");
		f.writeln("usemtl default");

		f.writeln("g ", fileBaseName);

		// Vertices
		foreach(i; 0 .. maxVertexIndex) {
			Vertex vertex = model_0_3.vertices[i];
			f.writeln("v ", -vertex.x, " ", vertex.z, " ", vertex.y);
		}
		
		// UVs
		foreach(i; 0 .. maxUVIndex) {
			UV uv = model_0_5.uvs[i];
			f.writeln("vt ", uv.u, " ", uv.v);
		}
		
		// Faces
		foreach(i; 0 .. model_0_5.faceCount) {
			VertexFace vertexFace = model_0_5.indices[i];
			UVFace uvFace = model_0_5.uvIndices[i];

			f.writeln("f ",
				vertexFace.xIndex + 1, "/", uvFace.xIndex + 1, " ",
				vertexFace.yIndex + 1, "/", uvFace.yIndex + 1,  " ",
				vertexFace.zIndex + 1, "/", uvFace.zIndex + 1);
		}

		// Material file
		fMtl.writeln("newmtl default");
		fMtl.writeln("illum 2");
		fMtl.writeln("Ka 1.000 1.000 1.000");
		fMtl.writeln("Kd 1.000 1.000 1.000");
		fMtl.writeln("Ks 0.000000 0.000000 0.000000");
		fMtl.writeln("Ke 0.000000 0.000000 0.000000");
		fMtl.writeln("d 1");
//		fMtl.writeln("map_Ka textures\\", model_0_5.textureInfo_0.textureInfo_1.textureInfo_2.textureFilename.ptr.fromStringz.replace(".tga", ".gf.png"));
//		fMtl.writeln("map_Ka ..\\textures\\", model_0_5.textureInfo_0.textureInfo_1.textureInfo_2.textureFilename.to!string.replace(".tga", ".gf.png"));
		fMtl.writeln("map_Kd ..\\textures\\", model_0_5.textureInfo_0.textureInfo_1.textureInfo_2.textureFilename.ptr.fromStringz.replace(".tga", ".gf.png"));

		f.close();
		fMtl.close();
	}

	writeln("Done saving model");
}