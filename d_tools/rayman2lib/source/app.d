import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string;
import decoder, formats.gpt, formats.levels0dat, formats.sna, formats.cnt, formats.gf, global, utils;
import consoled, imageformats;

void main(string[] args)
{
	debug {
		args ~= "dumpgpt";
	}

	if(args.length <= 1) {
		writeln("Usage: ", args[0], " option");

		writeln("Available options:");
		foreach(key, value; handlers)
			writeln("\t", key);

		return;
	}

	if(auto handleFunc = args[1] in handlers)
		(*handleFunc)(args[2 .. $]);
	else
		writeln("No such option");
}

/*
	Handler registering.
*/

void function(string[])[string] handlers;

static this() {
	mixin("import thisModule = " ~ __MODULE__ ~ ";");

	foreach(member; __traits(allMembers, thisModule))
		static if(isSomeFunction!(mixin(member)) && hasUDA!(mixin(member), handler))
			mixin("handlers[member] = &" ~ member ~ ";");
}

struct handler;

/*
	Tests GPT relocation.
*/

@handler
void gpt(string[]) {
	SNAFormat sna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.sna");
	sna.relocatePointersUsingFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.rtb");
	readRelocationTableFromFile(r"D:\GOG Games\Rayman 2\Data\World\Levels\Fix.rtp");

	//readFixGpt();

	readLearn_30Gpt(sna);
}

// Finished
void readFixGpt() {
	GPTFormat gpt = new GPTFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.gpt");

	auto POS_g_p_stIdentityMatrix = gpt.readPointer!(float*);
	
	foreach(i; 0 .. 50)
		gpt.readPointer();
	
	auto HIE_g_lNbMatrixInStack = gpt.readPointer!(float*);
	auto dword_50036C = gpt.readPointer!(ubyte*);
	auto dword_501404 = gpt.readPointer!(ubyte*);
	auto dword_5002C0 = gpt.readPointerBlock(0xAC);
	auto dword_50A980 = gpt.readPointer!(ubyte*);
	auto IPT_g_hInputStructure = gpt.readPointerBlock(0xB20);
	auto dword_50A564 = gpt.readPointer!(ubyte*);
	auto dword_500260 = gpt.readPointerBlock(0x14);
	auto tdstStacks = gpt.readPointerBlock(12 * 16);
	auto p_stA3dGENERAL = gpt.readPointer!(ubyte*);
	auto p_a3_xVectors = gpt.readPointer!(ubyte*);
	auto p_a4_xQuaternions = gpt.readPointer!(ubyte*);
	auto p_stHierarchies = gpt.readPointer!(ubyte*);
	auto p_stNTT0 = gpt.readPointer!(ubyte*);
	auto p_stOnlyFrames = gpt.readPointer!(ubyte*);
	auto p_stChannels = gpt.readPointer!(ubyte*);
	auto p_stFrames = gpt.readPointer!(ubyte*);
	auto p_stFramesKF = gpt.readPointer!(ubyte*);
	auto p_stKeyFrames = gpt.readPointer!(ubyte*);
	auto dword_500298 = gpt.readPointer!(ubyte*);
	auto p_stMorphData = gpt.readPointer!(ubyte*);
	auto dword_4B72F0 = gpt.readPointer!(ubyte*);
}

void readLearn_30Gpt(SNAFormat fix) {
	writeln("\nNow Learn_30 level");
	
	SNAFormat levelSna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.sna");
	levelSna.relocatePointersUsingBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", 79187968, 0x762D814D);
	readRelocationTableFromBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", 67540992, 0x207CDEEF);
	GPTFormat levelGpt = new GPTFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.gpt");
	
	// List of Learn_30.gpt pointers
	
	auto pointerCount = levelGpt.readPointer!uint;

	// TODO: Fix table reading and remove skip
	levelGpt.readPointerBlock(600);

//	foreach(i; 0 .. pointerCount) {
//		writeln("Reading table");
//		auto v23 = levelGpt.readPointer!(uint**);
//		//printMemory(&v23[1][3], 512);
//		
//		if(cast(uint)v23 != 0 && v23[1][3]) {
//			auto v24 = levelGpt.readPointer!(ubyte*);
//			
//			levelGpt.readPointerBlock(0x58);
//			levelGpt.readPointer!(ubyte*);
//			levelGpt.readPointerBlock(0x4);
//			levelGpt.readPointer!(ubyte*);
//			levelGpt.readPointer!(ubyte*);
//			levelGpt.readPointer!(ubyte*);
//		}
//		writeln("End reading table");
//	}

	assert(levelGpt.r.position == 604, "Invalid exit position. Table reading inproper.");
	
	writeln("Ended reading table");

	relocationLogging = true; // TODO: Just for testing models, remove later
	
	auto gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	auto gp_stDynamicWorld = levelGpt.readPointer!(ubyte*);
	auto dword_500FC4 = levelGpt.readPointer!(ubyte*);
	writeln("SECT_hFatherSector");
	auto SECT_hFatherSector = levelGpt.readPointer!(ubyte*);
	auto gs_hFirstSubMapPosition = levelGpt.readPointer!(ubyte*);
	auto g_stAlways = levelGpt.readPointerBlock(0x1C);
	auto dword_4A6B1C = levelGpt.readPointer!(ubyte*);
	auto dword_4A6B20 = levelGpt.readPointer!(ubyte*);
	auto v28 = levelGpt.readPointer!(ubyte*);
	auto v31 = levelGpt.readPointer!(ubyte*);
	auto v32 = levelGpt.readPointer!(ubyte*);
	auto v33 = levelGpt.readPointer!(ubyte*);
	auto dword_5013E0 = levelGpt.readPointerBlock(0x24);
	auto g_stEngineStructure = levelGpt.readPointerBlock(0xC30);
	auto gp_stLight = levelGpt.readPointer!(ubyte*);
	auto dword_500578 = levelGpt.readPointer!(ubyte*);
	auto g_hCharacterLauchingSoundEvents = levelGpt.readPointer!(ubyte*);
	auto g_hShadowPolygonVisualMaterial = levelGpt.readPointer!(ubyte*);
	auto g_hShadowPolygonGameMaterialInit = levelGpt.readPointer!(ubyte*);
	auto g_hShadowPolygonGameMaterial = levelGpt.readPointer!(ubyte*);
	auto g_p_stTextureOfTextureShadow = levelGpt.readPointer!(ubyte*);
	auto COL_g_d_lTaggedFacesTable = levelGpt.readPointer!(ubyte*);

	foreach(i; 0 .. 0xA) {
		levelGpt.readPointer!(ubyte*);
		levelGpt.readPointer!(ubyte*);
	}

	levelGpt.readPointer!(ubyte*);
	auto tdstStacks = levelGpt.readBlock!uint(12 * 16);

	relocationLogging = false; // A lot of data is read here, we don't need to log it
	auto p_stA3dGENERAL = levelGpt.readBlock!uint((tdstStacks[1] - tdstStacks[3]) * 56);
	auto p_a3_xVectors = levelGpt.readBlock!uint((tdstStacks[5] - tdstStacks[7]) * 12);
	auto p_a4_xQuaternions = levelGpt.readBlock!uint((tdstStacks[9] - tdstStacks[11]) * 8);
	auto p_stHierarchies = levelGpt.readBlock!uint((tdstStacks[13] - tdstStacks[15]) * 4);
	auto p_stNTT0 = levelGpt.readBlock!uint((tdstStacks[17] - tdstStacks[19]) * 6);
	auto p_stOnlyFrames = levelGpt.readBlock!uint((tdstStacks[21] - tdstStacks[23]) * 10);
	auto p_stChannels = levelGpt.readBlock!uint((tdstStacks[25] - tdstStacks[27]) * 16);
	auto p_stFrames = levelGpt.readBlock!uint((tdstStacks[29] - tdstStacks[31]) * 2);
	auto p_stFramesKF = levelGpt.readBlock!uint((tdstStacks[33] - tdstStacks[35]) * 4);
	auto p_stKeyFrames = levelGpt.readBlock!uint((tdstStacks[37] - tdstStacks[39]) * 36);
	auto p_stEvents = levelGpt.readBlock!uint((tdstStacks[41] - tdstStacks[43]) * 0xC);
	auto p_stMorphData = levelGpt.readBlock!uint((tdstStacks[45] - tdstStacks[47]) * 8);
	relocationLogging = true;

	auto g_AlphabetCharacterPointer = levelGpt.readPointer!(ubyte*);
	auto g_AlphabetCharacterpointer_new = levelGpt.readPointer!(ubyte**); // TODO: Raw is supposed to be 0x1B500A0, it is not
	auto g_bBeginMapSoundEventFlag = levelGpt.readPointer!(ubyte*);
	auto g_stBeginMapSoundEvent = levelGpt.readPointer!(ubyte*);

	//writeln("GLI_g_hMenuBackgroundObject");
	//Model* GLI_g_hMenuBackgroundObject = cast(Model*)*(g_AlphabetCharacterpointer_new + 20);
	//printAddressInformation(GLI_g_hMenuBackgroundObject);

	//printAddressInformation(GLI_g_hMenuBackgroundObject.indicesPointer);
	//printAddressInformation(GLI_g_hMenuBackgroundObject.unknownPointer1);
	//printAddressInformation(GLI_g_hMenuBackgroundObject.unknownPointer2);
	//printAddressInformation(GLI_g_hMenuBackgroundObject.unknownPointer3);

//	exportModel(fix.data.ptr + 0x61D723);
//	exportModel(fix.data.ptr + 0x6219EB);
//	exportModel(fix.data.ptr + 0x620E4B);
//	exportModel(fix.data.ptr + 0x621A23);
//	exportModel(fix.data.ptr + 0x6231DB);
//	exportModel(fix.data.ptr + 0x627C8B);
//	exportModel(fix.data.ptr + 0x6293AB);

	printGroupedModelInfo(fix.data.ptr + 0x18C);
}

void exportModel(void* address) {
	import structures.model;

	Model_0_0* model_0_0 = cast(Model_0_0*)address;
	Model_0_1* model_0_1 = model_0_0.model_0_1;

//	write("Vertices?"); printAddressInformation(model.gap0);
//	write("*Vertices?"); printAddressInformation(*(cast(uint**)model.gap0));
//	write("Indices"); printAddressInformation(model.indicesPointer);
//	write("Collision indices?"); printAddressInformation(model.unknownPointer1);
//	printAddressInformation(model.unknownPointer2);
//	printAddressInformation(model.unknownPointer3);

	printAddressInformation(model_0_0.model_0_1);
	write("  "); printAddressInformation(model_0_1.model_0_2);
	write("\t"); printAddressInformation(model_0_1.model_0_2.model_0_3);
	write("\t"); write("\t"); printAddressInformation(model_0_1.model_0_2.model_0_3.vertices);
	write("\t"); write("\t"); printAddressInformation(model_0_1.model_0_2.model_0_3.unknownPointer2);
	write("\t"); write("\t"); printAddressInformation(model_0_1.model_0_2.model_0_3.unknownPointer3);
	//write("\t"); write("\t"); write("\t"); printAddressInformation(*model_0_0.model_0_1.model_0_2.unknownPointer3);
	//write("\t"); write("\t"); write("\t"); printAddressInformation(*(model_0_0.model_0_1.model_0_2.unknownPointer3 + 4));
	write("\t"); write("\t"); printAddressInformation(model_0_1.model_0_2.model_0_3.unknownPointer4);
	write("\t"); write("\t"); printAddressInformation(model_0_1.model_0_2.model_0_3.model_0_4);
	write("\t"); write("\t"); write("\t"); printAddressInformation(model_0_1.model_0_2.model_0_3.model_0_4.model_0_5);
	write("\t"); write("\t"); write("\t"); write("\t"); printAddressInformation(model_0_1.model_0_2.model_0_3.model_0_4.model_0_5.unknownPointer1);
	write("\t"); write("\t"); write("\t"); writeln("\t\tFace count: ", model_0_1.model_0_2.model_0_3.model_0_4.model_0_5.faceCount);
	write("\t"); write("\t"); write("\t"); write("\t"); printAddressInformation(model_0_1.model_0_2.model_0_3.model_0_4.model_0_5.indices);
	write("\t"); write("\t"); write("\t"); write("\t"); printAddressInformation(model_0_1.model_0_2.model_0_3.model_0_4.model_0_5.uvIndices);
	write("\t"); write("\t"); write("\t"); write("\t"); printAddressInformation(model_0_1.model_0_2.model_0_3.model_0_4.model_0_5.vertices);
	write("\t"); write("\t"); write("\t"); write("\t"); printAddressInformation(model_0_1.model_0_2.model_0_3.model_0_4.model_0_5.uvs);
	write("\t"); write("\t"); write("\t"); printAddressInformation(model_0_1.model_0_2.model_0_3.model_0_4.unknownPointer2);

	// Obj model creation

	Model_0_5* model_0_4 = model_0_1.model_0_2.model_0_3.model_0_4.model_0_5;
	Model_0_3* model_0_2 = model_0_1.model_0_2.model_0_3;

	auto snaLocation = pointerToSNALocation(address);

	File f = File("models/" ~ snaLocation.name ~ "_0x" ~ address.to!string ~ ".obj", "w");

	ushort maxVertexIndex = 0;
	foreach(i; 0 .. model_0_4.faceCount) {
		if(model_0_4.indices[i].xIndex > maxVertexIndex)
			maxVertexIndex = model_0_4.indices[i].xIndex;
		if(model_0_4.indices[i].yIndex > maxVertexIndex)
			maxVertexIndex = model_0_4.indices[i].yIndex;
		if(model_0_4.indices[i].zIndex > maxVertexIndex)
			maxVertexIndex = model_0_4.indices[i].zIndex;
	}

	maxVertexIndex++;

	ushort maxUVIndex = 0;
	foreach(i; 0 .. model_0_4.faceCount) {
		if(model_0_4.uvIndices[i].xIndex > maxUVIndex)
			maxUVIndex = model_0_4.uvIndices[i].xIndex;
		if(model_0_4.uvIndices[i].yIndex > maxUVIndex)
			maxUVIndex = model_0_4.uvIndices[i].yIndex;
		if(model_0_4.uvIndices[i].zIndex > maxUVIndex)
			maxUVIndex = model_0_4.uvIndices[i].zIndex;
	}
	
	maxUVIndex++;

	// Vertices
	foreach(i; 0 .. maxVertexIndex) {
		Vertex vertex = model_0_2.vertices[i];
		f.writeln("v ", vertex.x, " ", vertex.y, " ", vertex.z);
	}

	// UVs
	foreach(i; 0 .. maxUVIndex) {
		UV uv = model_0_4.uvs[i];
		f.writeln("vt ", uv.u, " ", uv.v);
	}

	// Faces
	foreach(i; 0 .. model_0_4.faceCount) {
		VertexFace vertexFace = model_0_4.indices[i];
		UVFace uvFace = model_0_4.uvIndices[i];

		f.writeln("f ",
			vertexFace.xIndex + 1, "/", uvFace.xIndex + 1, " ",
			vertexFace.yIndex + 1, "/", uvFace.yIndex + 1,  " ",
			vertexFace.zIndex + 1, "/", uvFace.zIndex + 1);
	}

	f.close();

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

/*
	Dumps pointer table into CSV file.
*/
@handler
void dumpgpt(string[] args) {
	debug {
		//args ~= r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.gpt";
		//args ~= r"D:\GOG Games\Rayman 2\Data\World\Levels\Fix.rtp";
		//args ~= r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.sna";

		args ~= r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.gpt";
		args ~= r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT";
		args ~= "67540992";
		args ~= "545054447";
		args ~= r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.sna";
		args ~= r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.sna";
	}

	if(args.length < 3) {
		writeln("Usage: dumpgpt gptfile relocationfile fixsnafile [additionalsnafile]");
		writeln("Usage: dumpgpt gptfile bigfile bigfileoffset bigfilemagic fixsnafile [additionalsnafile]");
		return;
	}

	string pointerTableFile = args[0];

	if(!args[2].isNumeric) {
		string relocationFile = args[1];
		string fixSnaFile = args[2];
		string additionalSnaFile = args.length >= 3 ? args[3] : "";

		SNAFormat sna = new SNAFormat(fixSnaFile);
		if(additionalSnaFile != "")
			SNAFormat sna2 = new SNAFormat(fixSnaFile);

		GPTFormat gpt = new GPTFormat(pointerTableFile);
		readRelocationTableFromFile(relocationFile);
	}
	else {
		string bigfile = args[1];
		uint offset = args[2].to!uint;
		uint magic = args[3].to!uint;
		string fixSnaFile = args[4];
		string additionalSnaFile = args.length >= 5 ? args[5] : "";
		
		SNAFormat sna = new SNAFormat(fixSnaFile);
		if(additionalSnaFile != "")
			SNAFormat sna2 = new SNAFormat(fixSnaFile);

		readRelocationTableFromBigFile(bigfile, offset, magic);
	}

	GPTFormat gpt = new GPTFormat(pointerTableFile);

	writecln(Fg.lightMagenta, "Dumping pointer table.");

	string outputFilename = "dump_" ~ baseName(pointerTableFile)  ~ ".csv";
	File file = File(outputFilename, "w");

	file.writeln("sep=;\nRaw address;File;After relocation");

	while(!gpt.eof) {
		auto result = gpt.readPointerEx();
		file.write("0x", result.rawValue.to!string(16), ";");
		file.write(result.snaFile, ";");
		file.write("0x", result.snaAddress.to!string(16));
		file.writeln();
	}

	file.close();
	writecln(Fg.lightGreen, "Done! Saved to ", Fg.white, outputFilename);
}

/*
	Tests PTX pointer relocation.
	Should list pointers to all textures SNA file uses.
*/

@handler
void ptx(string[] args) {
	//readRelocationTableFromRTPFile(r"D:\GOG Games\Rayman 2\Data\World\Levels\Fix.rtp");
	SNAFormat sna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.sna");
	SNAFormat levelSna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.sna");
	readRelocationTableFromBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", 97017856, 0x41212953);
	GPTFormat ptx = new GPTFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.ptx");

	printMemory(relocationKeyValues.ptr, 512, 8);

	ptx.read!uint;
	uint count = ptx.read!uint / 4;

	foreach(i; 0 .. count) {
		ptx.readPointer();
	}
}

/*
	Unpacks CNT archive into a folder.
*/

@handler
void unpackcnt(string[] args) {
	debug {
		args ~= r"Textures.cnt";
		args ~= "-png";
		args ~= "-r2";
	}

	if(args.length == 0) {
		writecln(Fg.white, "Usage: unpackcnt filename [outputfolder] [-png] [-r2] [-r3] ", Fg.initial);
		return;
	}

	GFType type = GFType.rayman2;
	if(args.canFind("-r3"))
		type = GFType.rayman3;

	string cntFilename = args[0];
	bool toPng = args.canFind("-png");

	CNTFormat cnt = new CNTFormat(cntFilename);

	string outputDir = (args.length == 2 && !args[1].startsWith("-")) ? args[1] ~ "/" : baseName(cntFilename) ~ ".extracted/";

	foreach(file; cnt.fileList) {
		mkdirRecurse(outputDir ~ file.directory);
		if(!toPng)
			std.file.write(outputDir ~ file.directory ~ "/" ~ file.name, file.data);
		else
			new GFFormat(file.data, type).saveToPng(outputDir ~ file.directory ~ "/" ~ file.name ~ ".png");
	}
}

/*
	Creates CNT archive from a folder.
*/

@handler
void packcnt(string[] args) {
	debug {
		args ~= r"TexturesHD.cnt.extracted";
	}
	
	if(args.length == 0) {
		writecln(Fg.white, "Usage: packcnt folder [outputname] [-r2] [-r2vignette] [-r3] [-r3vignette]", Fg.initial);
		return;
	}

	if(!exists(args[0]) || !isDir(args[0])) {
		writecln(Fg.red, "No such directory", Fg.initial);
		return;
	}

	CNTVersion type = CNTVersion.rayman2;
	if(args.canFind("-r2vignette"))
		type = CNTVersion.rayman2Vignette;
	if(args.canFind("-r3"))
		type = CNTVersion.rayman3;
	if(args.canFind("-r3vignette"))
		type = CNTVersion.rayman3Vignette;

	GFType gfType = GFType.rayman2;
	if(type == CNTVersion.rayman3)
		gfType = GFType.rayman3;

	string outputName = (args.length >= 2 && !args[1].startsWith("-")) ? args[1] : baseName(args[0]).replace(".extracted", "");

	CNTFile[] cntFileList;

	foreach(name; dirEntries(args[0], SpanMode.depth)) {
		if(!name.isDir && name.extension == ".png") { // TODO: Add support for pure GF files
			IFImage image = read_png(name, ColFmt.RGBA);

			GFFormat gf = new GFFormat(gfType);
			gf.width = image.w;
			gf.height = image.h;
			gf.pixels = cast(uint[])image.pixels;
			gf.build();

			CNTFile cntFile = new CNTFile();
			cntFile.directory = relativePath(dirName(absolutePath(name)), absolutePath(args[0]));
			cntFile.name = baseName(name).replace(".png", "");
			cntFile.data = gf.data;

			cntFileList ~= cntFile;
		}
	}

	writecln(Fg.white, "Packing into ", outputName);

	CNTFormat cnt = new CNTFormat();
	cnt.archiveVersion = CNTVersion.rayman3;
	foreach(cntFile; cntFileList)
		cnt.fileList ~= cntFile;
		
	cnt.build();

	std.file.write(outputName, cnt.data);
	writecln(Fg.lightMagenta, "Done!", Fg.initial);
}

/*
	Transforms GF files into png.
*/

@handler
void gftopng(string[] args) {
	debug {
		args ~= r"r2demo_vignette";
		args ~= r"-r2";
	}
	
	if(args.length == 0) {
		writecln(Fg.white, "Usage: gftopng folder [outputfolder] [-r2] [-r2ios] [-r3]", Fg.initial);
		return;
	}
	
	if(!exists(args[0]) || !isDir(args[0])) {
		writecln(Fg.red, "No such directory", Fg.initial);
		return;
	}

	GFType type = GFType.rayman2;
	if(args.canFind("-r2ios"))
		type = GFType.rayman2ios;
	if(args.canFind("-r3"))
		type = GFType.rayman3;

	string outputDir = (args.length >= 2 && !args[1].startsWith("-")) ? args[1] : args[0] ~ ".png";

	mkdirRecurse(outputDir);

	foreach(name; dirEntries(args[0], SpanMode.depth)) {
		if(!name.isDir && name.extension.toLower == ".gf") {
			mkdirRecurse(outputDir ~ "/" ~ dirName(relativePath(absolutePath(name), absolutePath(args[0]))));
			new GFFormat(name, type).saveToPng(outputDir ~ "/" ~ relativePath(absolutePath(name), absolutePath(args[0])) ~ ".png");
		}
	}
}

/*
	Handler supposed to resize textures of SNA file, so
	enlarged textures don't get downscaled.
	Doesn't work for some reason.
*/

struct GliTexture
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

@handler
void resizetextures(string[] args) {
	SNAFormat levelSna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.sna");
	readRelocationTableFromBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", 97017856, 0x41212953);
	GPTFormat ptx = new GPTFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.ptx");

	ptx.read!uint;
	uint count = ptx.read!uint / 4;
	
	foreach(i; 0 .. count) {
		auto texture = ptx.readPointer!(GliTexture*);

		if(texture !is null) {
			printStruct(*texture);
			writeln(texture.textureFilename.ptr.fromStringz);
			//texture.w = 0;
			//texture.h = 0;
			texture.w2 *= 2;
			texture.h2 *= 2;
			texture.gap30[0]++;
		}
	}

	std.file.write(r"D:\GOG Games\Rayman 2\Data\World\Levels\Learn_30\Learn_30.sna", decodeData(levelSna.data));
}