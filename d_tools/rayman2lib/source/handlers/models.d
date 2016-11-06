module handlers.models;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, global, utils, structures.sector;

mixin registerHandlers;

void exportModel(void* address) {
	import structures.model;

	writeln("Exporting model");
	
	Model_0_0* model_0_0 = cast(Model_0_0*)address;
	Model_0_1* model_0_1 = model_0_0.model_0_1;
	
	//	write("Vertices?"); printAddressInformation(model.gap0);
	//	write("*Vertices?"); printAddressInformation(*(cast(uint**)model.gap0));
	//	write("Indices"); printAddressInformation(model.indicesPointer);
	//	write("Collision indices?"); printAddressInformation(model.unknownPointer1);
	//	printAddressInformation(model.unknownPointer2);
	//	printAddressInformation(model.unknownPointer3);
	
	printAddressInformation(model_0_0.model_0_1);
	write("  "); printAddressInformation(model_0_1.model_1_2);
	if(!model_0_1.model_1_2) {
		writeln("Invalid model");
		return;
	}

	write("\t"); printAddressInformation(model_0_1.model_1_2.model_0_3);
	write("\t"); write("\t"); printAddressInformation(model_0_1.model_1_2.model_0_3.vertices);
	write("\t"); write("\t"); printAddressInformation(model_0_1.model_1_2.model_0_3.unknownPointer2);
	write("\t"); write("\t"); printAddressInformation(model_0_1.model_1_2.model_0_3.unknownPointer3);
	//write("\t"); write("\t"); write("\t"); printAddressInformation(*model_0_0.model_0_1.model_0_2.unknownPointer3);
	//write("\t"); write("\t"); write("\t"); printAddressInformation(*(model_0_0.model_0_1.model_0_2.unknownPointer3 + 4));
	write("\t"); write("\t"); printAddressInformation(model_0_1.model_1_2.model_0_3.unknownPointer4);
	write("\t"); write("\t"); printAddressInformation(model_0_1.model_1_2.model_0_3.model_0_4);
	write("\t"); write("\t"); write("\t"); printAddressInformation(model_0_1.model_1_2.model_0_3.model_0_4.model_0_5);
	write("\t"); write("\t"); write("\t"); write("\t"); printAddressInformation(model_0_1.model_1_2.model_0_3.model_0_4.model_0_5.textureInfo_0);
	write("\t"); write("\t"); write("\t"); writeln("\t\tFace count: ", model_0_1.model_1_2.model_0_3.model_0_4.model_0_5.faceCount);
	write("\t"); write("\t"); write("\t"); write("\t"); printAddressInformation(model_0_1.model_1_2.model_0_3.model_0_4.model_0_5.indices);
	write("\t"); write("\t"); write("\t"); write("\t"); printAddressInformation(model_0_1.model_1_2.model_0_3.model_0_4.model_0_5.uvIndices);
	write("\t"); write("\t"); write("\t"); write("\t"); printAddressInformation(model_0_1.model_1_2.model_0_3.model_0_4.model_0_5.normals);
	write("\t"); write("\t"); write("\t"); write("\t"); printAddressInformation(model_0_1.model_1_2.model_0_3.model_0_4.model_0_5.uvs);
	
	// Obj model creation
	
	Model_0_5* model_0_5 = model_0_1.model_1_2.model_0_3.model_0_4.model_0_5;
	Model_0_3* model_0_3 = model_0_1.model_1_2.model_0_3;

	auto snaLocation = pointerToSNALocation(address);

	string fileBaseName = snaLocation.name ~ "_0x" ~ address.to!string;

	File f = File("models/" ~ fileBaseName  ~ ".obj", "w");
	
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

	// Vertices
	foreach(i; 0 .. maxVertexIndex) {
		Vertex vertex = model_0_3.vertices[i];
		f.writeln("v ", vertex.x, " ", vertex.y, " ", vertex.z);
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

	f.close();
	
	writeln("Done saving model");
	
	//printAddressInformation(model_0_0.unknownPointer2);
}

void exportModel_NEW(void* address) {
	import structures.model;
	
	writeln("Exporting model");
	
	Model_0_0* model_0_0 = cast(Model_0_0*)address;
	Model_0_1* model_0_1 = model_0_0.model_0_1;

	// Obj model creation

	if(model_0_1 is null || model_0_1.model_1_2 is null)
		return;

	Model_0_3* model_0_3 = model_0_1.model_1_2.model_0_3;

	auto snaLocation = pointerToSNALocation(address);

	foreach(j, model_0_5; model_0_3.submodels) {

		if(!model_0_5.textureInfo_0 || !model_0_5.textureInfo_0.textureInfo_1 || !model_0_5.textureInfo_0.textureInfo_1.textureInfo_2 || !model_0_5.indices) {
			writeln("Shitty submodel");
			continue;
		}

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

		File f = File("models/" ~ fileBaseName  ~ ".obj", "w");
		File fMtl = File("models/" ~ fileBaseName  ~ ".mtl", "w");

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
		fMtl.writeln("illum 1");
//		fMtl.writeln("map_Ka textures\\", model_0_5.textureInfo_0.textureInfo_1.textureInfo_2.textureFilename.ptr.fromStringz.replace(".tga", ".gf.png"));
		fMtl.writeln("map_Kd textures\\", model_0_5.textureInfo_0.textureInfo_1.textureInfo_2.textureFilename.to!string.replace(".tga", ".gf.png"));

		f.close();
		fMtl.close();
	}
	

	
	writeln("Done saving model");
	
	//printAddressInformation(model_0_0.unknownPointer2);
}

void printGroupedModelInfo(void* address) {
	import structures.model;
	
	GroupedModel_0* groupedModel_0 = cast(GroupedModel_0*)address;
	
	printAddressInformation(groupedModel_0);
	write("\t"); printAddressInformation(groupedModel_0.groupedModel_1);
	write("\t"); printAddressInformation(groupedModel_0.groupedModel_1_1);
	write("\t\t"); printAddressInformation(groupedModel_0.groupedModel_1_1.unknownPointer1);
	write("\t\t"); printAddressInformation(groupedModel_0.groupedModel_1_1.unknownPointer2);
	write("\t\t"); printAddressInformation(groupedModel_0.groupedModel_1_1.name);
}
