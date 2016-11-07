module handlers.sectors;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, formats.gpt, structures.model, global, utils, structures.sector;

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

	string levelName = "Whale_00";

	SNAFormat levelSna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\" ~ levelName ~ r"\" ~ levelName ~ ".sna");
	levelSna.relocatePointersUsingBigFileAuto(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT");
	readRelocationTableFromBigFileAuto(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", levelName, RelocationTableType.gpt);
	LevelGPT levelGpt = new LevelGPT(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\" ~ levelName ~ r"\" ~ levelName ~ ".gpt");






	
//	SNAFormat levelSna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Ly_10\Ly_10.sna");
//	levelSna.relocatePointersUsingBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", 0x74B5000, 0x435FA90A);
//
//	readRelocationTableFromBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", 0x1475000, 0x431E020A);
//	LevelGPT levelGpt = new LevelGPT(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Ly_10\Ly_10.gpt");
//

	printAddressInformation(levelGpt.gp_stDynamicWorld);

	//printSectorInfo(levelGpt.SECT_hFatherSector);

	writeln("\nModel info");

	import handlers.models;


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

//
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



	void exportAllModels(Sector* sector) {
		foreach(currSector; sector.getTwins()) {
			printAddressInformation(currSector);
			writeln("Type: ", currSector.type);
			if(currSector.info0) {
				write("Entity: "); printAddressInformation(currSector.info0.firstEntity);
			
				if(currSector.type == 32 || currSector.type == 8 || currSector.type == 4) {
					if(currSector.info0.firstModel)
						exportModel_NEW(currSector.info0.firstModel);
				}
			}

			if(currSector.firstChild)
				exportAllModels(currSector.firstChild);
		}
	}

	exportAllModels(levelGpt.SECT_hFatherSector);
	//exportAllModels(levelGpt.gp_stDynamicWorld);




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
//		string tabStr = "";
//		foreach(i; 0 .. depth)
//			tabStr ~= "    ";
//		
//
//		writeln(tabStr, "---------");
//		write(tabStr); printAddressInformation(sector);
//		write(tabStr); writeln("Type: ", sector.type);
//		if(sector.info0) {
//			write(tabStr); write("Entity: "); printAddressInformation(sector.info0.firstEntity);
//			write(tabStr); write("Radiosity: "); printAddressInformation(sector.info0.radiosity);
//		}
//		writeln(tabStr, "---------");
//
//
//		foreach(child; sector.getChildren())
//			printEntityInfo(child, depth + 1);
//	}
//	
//	printEntityInfo(levelGpt.gp_stDynamicWorld);





//	exportModel_NEW(mdl);

	//printAddressInformation(mdl.model_0_1.model_1_2.model_0_3.vertices);
	//printAddressInformation(mdl.model_0_1.model_1_2.model_0_3.submodels[0]);
}

void printSectorInfo(Sector* sector) {
	writecln(Fg.lightMagenta, "Testing sectors");
	
	printAddressInformation(sector);
	sector.printChildrenInfo();
}