module handlers.gpt;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, global, utils, structures.sector;

mixin registerHandlers;

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
	PointerTableFormat gpt = new PointerTableFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.gpt");
	
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
	PointerTableFormat levelGpt = new PointerTableFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.gpt");
	
	// List of Learn_30.gpt pointers
	
	relocationLogging = false; // TODO: Just for testing models, remove later
	
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
	
	auto gp_stActualWorld = levelGpt.readPointer!(ubyte*);
	auto gp_stDynamicWorld = levelGpt.readPointer!(ubyte*);
	auto dword_500FC4 = levelGpt.readPointer!(ubyte*);
	writeln("SECT_hFatherSector");
	auto SECT_hFatherSector = levelGpt.readPointer!(Sector*);
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
	relocationLogging = false;
	
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
	//exportModel(levelSna.data.ptr + 0x9CA68);
	
	//printGroupedModelInfo(fix.data.ptr + 0x18C);
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
			SNAFormat sna2 = new SNAFormat(additionalSnaFile);
		
		PointerTableFormat gpt = new PointerTableFormat(pointerTableFile);
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
			SNAFormat sna2 = new SNAFormat(additionalSnaFile);
		
		readRelocationTableFromBigFile(bigfile, offset, magic);
	}
	
	PointerTableFormat gpt = new PointerTableFormat(pointerTableFile);
	
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