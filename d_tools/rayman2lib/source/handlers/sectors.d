module handlers.sectors;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, formats.gpt, structures.model, structures.entity, global, utils, structures.sector, handlers.models;

mixin registerHandlers;

/*
	Tests sectors.
*/

@handler
void sectors(string[] args) {
	relocationLogging = false;




	SNAFormat sna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.sna");
	sna.relocatePointersUsingFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.rtb");

	readRelocationTableFromFile(r"D:\GOG Games\Rayman 2\Data\World\Levels\Fix.rtp");
	FixGPT fixGpt = new FixGPT(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.gpt");

	string levelName = "Learn_30";

	SNAFormat levelSna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\" ~ levelName ~ r"\" ~ levelName ~ ".sna");
	levelSna.relocatePointersUsingBigFileAuto(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT");
	readRelocationTableFromBigFileAuto(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", levelName, RelocationTableType.gpt);
	LevelGPT levelGpt = new LevelGPT(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\" ~ levelName ~ r"\" ~ levelName ~ ".gpt");


	//exportModel_NEW(levelSna.data.ptr + 0xB02DC);




	
//	SNAFormat levelSna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Ly_10\Ly_10.sna");
//	levelSna.relocatePointersUsingBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", 0x74B5000, 0x435FA90A);
//
//	readRelocationTableFromBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", 0x1475000, 0x431E020A);
//	LevelGPT levelGpt = new LevelGPT(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Ly_10\Ly_10.gpt");
//

	//printSectorInfo(levelGpt.SECT_hFatherSector);

	void process(Sector* sector, int depth = 0) {
		string tabStr = "";
		foreach(i; 0 .. depth)
			tabStr ~= "    ";

		writeln("Type: ", sector.type);
		//printAddressInformation(sector);
		if(sector.type == 2) {
			SOStandardGameStruct* gameStruct = sector.info.standardGameStruct;
			printAddressInformation(gameStruct);
			writeln((&gameStruct.name).fromStringz);

			//if((&gameStruct.name).fromStringz == "JCP_YAM_PastilleVersLaMapMonde_I1") {
				RenderInfo* renderInfo = sector.info.renderInfo;

				if(renderInfo.dword10) {
					void* v7 = *cast(void**)(renderInfo.dword10 + 4);
					struct_v13* v13 = cast(struct_v13*)(v7);
				
					if(cast(int)v13 > 1000 && v13.engineObject)
						exportModel_NEW(v13.engineObject.firstModel);
				}
			//}

			//if(gameStruct.modelInfo) {
			//    foreach(mdl; gameStruct.modelInfo.getModelInfos1()) {
			//        writeln("Found object model");
			//        exportModel_NEW(mdl.model_0_0);
			//    }
			//}

			//if(gameStruct.field_84) {
			//    writeln("asd");
			//    process(cast(Sector*)gameStruct.field_84, depth++);
			//}
		}

		if(sector.type == 4) {
			//writeln("First super object: "); printAddressInformation(sector.info.firstSuperObject);

			

			for(Sector** superObject = sector.info.firstSuperObject; superObject; superObject = cast(Sector**)*(cast(int*)superObject + 1)) {
				write(tabStr); printAddressInformation(superObject);

				Sector* actualObject = *superObject;

				SOStandardGameStruct* gameStruct = actualObject.info.standardGameStruct;
				write(tabStr); writeln((&gameStruct.name).fromStringz);

				process(actualObject, depth++);
			}
		}

		//if(sector.type == 1) {
		//    if(sector.info.firstModel)
		//        exportModel_NEW(sector.info.firstModel);
		//}

		//if(sector.type == 2) {
		//    if(sector.info) {
		//        RenderInfo* renderInfo = sector.info.renderInfo;
		//        if(renderInfo.dword10) {
		//            void* v7 = *cast(void**)(renderInfo.dword10 + 4);
		//            if(cast(int)v7 > 1000) {
		//                struct_v13* v13 = *cast(struct_v13**)(v7);
		//                if(v13)
		//                    exportModel_NEW(v13.engineObject.firstModel);
		//            }
		//        }
		//    }
		//}

		foreach(child; sector.getChildren())
			process(child);

		if(sector.nextTwin)
			process(sector.nextTwin);
	}

	process(levelGpt.SECT_hFatherSector);

	readln();

//	exportModel_NEW(cast(Model_0_0*)(levelSna.data.ptr + 0xA7DF4));


//	Model_0_0* model = cast(Model_0_0*)(levelSna.data.ptr + 0xAB25C);
//
//	do {
//		printAddressInformation(model);
//
//		writeln(model.model_0_1.model_0_2);
//		printAddressInformation(model.model_0_1.model_0_2.objectData);
//
//		if(model.model_0_1.model_0_2.objectData.flags & 2) {
//			writeln("DAMN!");
//		}
//
//		//if(model.model_0_1)
//		//	exportModel(model);
//
//		model = model.nextTwin;
//	} while(model);

//	Sector* sector = cast(Sector*)(levelSna.data.ptr + 0x37458);
//
//	printAddressInformation(sector.info0.firstModel);
//
//	writeln(sector.info0.firstModel.model_0_1.model_1_2.model_0_3.model_0_4.model_0_5.textureInfo_0.textureInfo_1.textureInfo_2.textureFilename);

//	Model_0_0* mdl = cast(Model_0_0*)(levelSna.data.ptr + 0x5d7b4);
	//Model_0_0* mdl = cast(Model_0_0*)(levelSna.data.ptr + 0xB02DC);

	//foreach(subMdl; mdl.model_0_1.model_1_2.model_0_3.submodels) {
	//	printAddressInformation(subMdl);
	//}

	//printAddressInformation(mdl.model_0_1.model_1_2.model_0_3);


//	void printInfo(Sector* sector) {
//		auto currSector = sector;
//
//		do {
//			printAddressInformation(currSector.info0);
//		} while((currSector = currSector.nextTwin) !is null);
//
//		foreach(child; sector.getChildren)
//			printInfo(child);
//	}
//
//	printInfo(levelGpt.SECT_hFatherSector);
//
//
//	exportAllModels(levelGpt.SECT_hFatherSector);
//	exportAllModels(levelGpt.gp_stDynamicWorld);




//	void printEntityInfo(Sector* sector, int depth = 0) {
//		string tabStr = "";
//		foreach(i; 0 .. depth)
//			tabStr ~= "    ";
//
//		foreach(currSector; sector.getTwins()) {
//			writeln(tabStr, "---------");
//			write(tabStr); printAddressInformation(currSector);
//			write(tabStr); writeln("Type: ", currSector.type);
//			if(currSector.info0) {
//				write(tabStr); write("Entity: "); printAddressInformation(currSector.info0.firstEntity);
//			}
//			writeln(tabStr, "---------");
//
//			if(currSector.firstChild)
//				printEntityInfo(currSector.firstChild, depth + 1);
//		}
//	}



//	void printEntityInfo(Sector* sector, int depth = 0) {
////		string tabStr = "";
////		foreach(i; 0 .. depth)
////			tabStr ~= "    ";
////		
////
////		writeln(tabStr, "---------");
////		write(tabStr); printAddressInformation(sector);
////		write(tabStr); writeln("Type: ", sector.type);
////		if(sector.info0) {
////			write(tabStr); write("Entity: "); printAddressInformation(sector.info0.firstEntity);
////			write(tabStr); write("Radiosity: "); printAddressInformation(sector.info0.radiosity);
////		}
////		writeln(tabStr, "---------");
//
//
//
//		foreach(child; sector.getChildren())
//			printEntityInfo(child, depth + 1);
//	}
//	
//	printEntityInfo(levelGpt.gp_stDynamicWorld);


//    import structures.entity;
//
//    void exportEntity(Entity1* entity) {
//        write("Entity: "); printAddressInformation(entity);
//        write("Model info 0: "); printAddressInformation(entity.modelInfo);
//
//        foreach(mdl; entity.modelInfo.getModelInfos1())
//            if(mdl.model_0_0 != null && mdl.type != 5)
//                exportModel_NEW(mdl.model_0_0, "entity_models");
//    }
//
//    //exportEntity(cast(Entity1*)(levelSna.data.ptr + 0x40DD));
////	exportEntity(cast(Entity1*)(sna.data.ptr + 0x1C8));
//    exportEntity(cast(Entity1*)(levelSna.data.ptr + 0x14E3D));



//	exportModel_NEW(mdl);

	//printAddressInformation(mdl.model_0_1.model_1_2.model_0_3.vertices);
	//printAddressInformation(mdl.model_0_1.model_1_2.model_0_3.submodels[0]);
}

void exportAllModels(Sector* sector, string path = "models") {
	foreach(currSector; sector.getTwins()) {
		printAddressInformation(currSector);
		writeln("Type: ", currSector.type);
		if(currSector.info) {
			//write("Entity: "); printAddressInformation(currSector.info.firstEntity);
			
			if(currSector.type == 32 || currSector.type == 8 || currSector.type == 4) {
				if(currSector.info.firstModel)
					exportModel_NEW(currSector.info.firstModel, path);
			}
		}
		
		if(currSector.firstChild)
			exportAllModels(currSector.firstChild, path);
	}
}

@handler
void exportallmaps(string[] args) {
	relocationLogging = false;

	debug {
		args ~= r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels";
		args ~= r"TEST_EXPORTED_MAPS";
	}

	if(args.length < 2) {
		writeln("Usage: exportallmaps levelsdir outputdir");
		return;
	}

	string levelsDir = args[0];
	string outputDir = args[1];

	SNAFormat sna = new SNAFormat(buildPath(levelsDir, "Fix.sna"));
	sna.relocatePointersUsingFile(buildPath(levelsDir, "Fix.rtb"));
	
	readRelocationTableFromFile(buildPath(levelsDir, "Fix.rtp"));
	FixGPT fixGpt = new FixGPT(buildPath(levelsDir, "Fix.gpt"));

	mkdirRecurse(outputDir);

	foreach(levelName; levelList) {
		SNAFormat levelSna = new SNAFormat(buildPath(levelsDir, levelName ~ r"\" ~ levelName ~ ".sna"));
		levelSna.relocatePointersUsingBigFileAuto(buildPath(levelsDir, "LEVELS0.DAT"));
		readRelocationTableFromBigFileAuto(buildPath(levelsDir, "LEVELS0.DAT"), levelName, RelocationTableType.gpt);
		LevelGPT levelGpt = new LevelGPT(buildPath(levelsDir, levelName ~ r"\" ~ levelName ~ ".gpt"));
	
		mkdirRecurse(buildPath(outputDir, levelName));

		exportAllModels(levelGpt.SECT_hFatherSector, buildPath(outputDir, levelName));
	}
}