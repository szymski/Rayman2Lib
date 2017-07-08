module handlers.superobjects;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, formats.gpt, structures.model, structures.gamestruct, global, utils, structures.superobject, handlers.models;

mixin registerHandlers;

/// The path to the Levels directory of Rayman 2, for development. With '\' included at the end.
enum levelsDir = r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\";

@handler
void superobjects(string[] args) {
	relocationLogging = false;

	// Prepare files for PC version

	SNAFormat sna = new SNAFormat(levelsDir ~ "Fix.sna");
	sna.relocatePointersUsingFile(levelsDir ~ "Fix.rtb");

	readRelocationTableFromFile(levelsDir ~ "Fix.rtp");
	FixGPT fixGpt = new FixGPT(levelsDir ~ "Fix.gpt");

	enum levelName = "Rhop_10";

	SNAFormat levelSna = new SNAFormat(levelsDir ~ levelName ~ r"\" ~ levelName ~ ".sna");
	levelSna.relocatePointersUsingBigFileAuto(levelsDir ~ "LEVELS0.DAT");
	readRelocationTableFromBigFileAuto(levelsDir ~ "LEVELS0.DAT", levelName, RelocationTableType.gpt);
	LevelGPT levelGpt = new LevelGPT(levelsDir ~ levelName ~ r"\" ~ levelName ~ ".gpt");

	// Process SuperObject tree

	void process(SuperObject* superObject, int depth = 0) {
		string tabStr = "";
		foreach(i; 0 .. depth)
			tabStr ~= "    ";

		writeln("Type: ", superObject.type);
		if(superObject.type == 2) {
			SOStandardGameStruct* gameStruct = superObject.info.standardGameStruct;
			printAddressInformation(gameStruct);

			auto objectName = (&gameStruct.name).fromStringz.idup;
			writeln(objectName);

			RenderInfo* renderInfo = superObject.info.renderInfo;

			if(renderInfo.dword10) {
				void* v7 = *cast(void**)(renderInfo.dword10 + 4);
				struct_v13* v13 = cast(struct_v13*)(v7);
			
				if(cast(int)v13 > 1000)
					for(; v13.renderInfo; v13 = cast(struct_v13*)(cast(int)v13 + 20)) {
						// Unfortunately, a lot of validity testing is required
						if(isValidSnaAddress(v13.renderInfo) &&
						   isValidSnaAddress(v13.renderInfo.model_0_1) &&
						   cast(int)v13.renderInfo > 1000 && cast(int)v13.renderInfo.model_0_1 > 1000)
							exportModel(v13.renderInfo, "models/" ~ objectName);
					}
			}
		}

		if(superObject.type == 4) {
			for(SuperObject** childSuperObject = superObject.info.firstSuperObject; childSuperObject; childSuperObject = cast(SuperObject**)*(cast(int*)childSuperObject + 1)) {
				write(tabStr); printAddressInformation(childSuperObject);

				SuperObject* actualObject = *childSuperObject;

				SOStandardGameStruct* gameStruct = actualObject.info.standardGameStruct;
				write(tabStr); writeln((&gameStruct.name).fromStringz);

				process(actualObject, depth++);
			}
		}

		foreach(child; superObject.getChildren())
			process(child);

		if(superObject.nextTwin)
			process(superObject.nextTwin);
	}

	process(levelGpt.SECT_hFatherSector);

	readln();
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

		exportStaticWorld(levelGpt.SECT_hFatherSector, buildPath(outputDir, levelName));
	}
}

void exportStaticWorld(SuperObject* superObject, string path = "models") {
	foreach(currSuperObject; superObject.getTwins()) {
		if(currSuperObject.info) {
			if(currSuperObject.type == 32 || currSuperObject.type == 8 || currSuperObject.type == 4)
				if(currSuperObject.info.firstModel)
					exportModel(currSuperObject.info.firstModel, path);
		}
		
		if(currSuperObject.firstChild)
			exportStaticWorld(currSuperObject.firstChild, path);
	}
}