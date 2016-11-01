module handlers.sectors;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, formats.gpt, structures.model, global, utils, structures.sector;

mixin registerHandlers;

/*
	Tests sectors.
*/

@handler
void sectors(string[]) {
	relocationLogging = false;

	SNAFormat sna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.sna");
	sna.relocatePointersUsingFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.rtb");
	readRelocationTableFromFile(r"D:\GOG Games\Rayman 2\Data\World\Levels\Fix.rtp");

	FixGPT fixGpt = new FixGPT(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.gpt");

	SNAFormat levelSna = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.sna");
	levelSna.relocatePointersUsingBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", 79187968, 0x762D814D);
	readRelocationTableFromBigFile(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT", 67540992, 0x207CDEEF);

	LevelGPT levelGpt = new LevelGPT(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.gpt");

	printSectorInfo(levelGpt.SECT_hFatherSector);

	writeln("\nModel info");

	import handlers.models;

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

	Sector* sector = cast(Sector*)(levelSna.data.ptr + 0x37458);

	printAddressInformation(sector.info0.firstModel);

	writeln(sector.info0.firstModel.model_0_1.model_1_2.model_0_3.model_0_4.model_0_5.textureInfo_0.textureInfo_1.textureInfo_2.textureFilename);
}

void printSectorInfo(Sector* sector) {
	writecln(Fg.lightMagenta, "Testing sectors");
	
	printAddressInformation(sector);
	sector.printChildrenInfo();
}