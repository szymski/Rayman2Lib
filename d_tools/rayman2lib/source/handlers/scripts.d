module handlers.scripts;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, formats.gpt, structures.model, structures.gamestruct, global, utils, structures.superobject, handlers.models;

mixin registerHandlers;

/// The path to the Levels directory of Rayman 2, for development. With '\' included at the end.
enum levelsDir = "D:\\GOG Games\\Rayman 2\\Rayman 2 Modded\\Data\\World\\Levels\\";

@handler
void scripts(string[] args) {
	relocationLogging = false;
	
	// Prepare files for PC version
	
	SNAFormat sna = new SNAFormat(levelsDir ~ "Fix.sna");
	sna.relocatePointersUsingFile(levelsDir ~ "Fix.rtb");
	
	readRelocationTableFromFile(levelsDir ~ "Fix.rtp");
	FixGPT fixGpt = new FixGPT(levelsDir ~ "Fix.gpt");
	
	enum levelName = "Learn_30";
	
	SNAFormat levelSna = new SNAFormat(levelsDir ~ levelName ~ "\\" ~ levelName ~ ".sna");
	levelSna.relocatePointersUsingBigFileAuto(levelsDir ~ "LEVELS0.DAT");
	readRelocationTableFromBigFileAuto(levelsDir ~ "LEVELS0.DAT", levelName, RelocationTableType.gpt);
	LevelGPT levelGpt = new LevelGPT(levelsDir ~ levelName ~ "\\" ~ levelName ~ ".gpt");

	// Process SuperObject tree

	void process(SuperObject* superObject, int depth = 0) {
		string tabStr = "";
		foreach(i; 0 .. depth)
			tabStr ~= "    ";
		
		//writeln("Type: ", superObject.type);
		if(superObject.type == 2) {
			SOStandardGameStruct* gameStruct = superObject.engineObject.standardGameStruct;

			if(gameStruct.strName.canFind("JCP_SDZ_EtatAOJ")) {
				writeln(gameStruct.strName);
				printAddressInformation(superObject);
			}
			
//			printAddressInformation(superObject.engineObject.aiStruct.intelligence);
		}
		
		if(superObject.type == 4) {
			for(SuperObject** childSuperObject = superObject.engineObject.firstSuperObject; childSuperObject; childSuperObject = cast(SuperObject**)*(cast(int*)childSuperObject + 1)) {
				//write(tabStr); printAddressInformation(childSuperObject);
				
				SuperObject* actualObject = *childSuperObject;
				
				SOStandardGameStruct* gameStruct = actualObject.engineObject.standardGameStruct;
				//write(tabStr); writeln((&gameStruct.name).fromStringz);
				
				process(actualObject, depth++);
			}
		}
		
		foreach(child; superObject.getChildren())
			process(child);
		
		if(superObject.nextTwin)
			process(superObject.nextTwin);
	}
	
	//process(levelGpt.SECT_hFatherSector);

	auto superObject = cast(SuperObject*)(levelSna.data.ptr + 0xC0000);
	writeln(superObject.engineObject.standardGameStruct.strName);

	// Comport* ai = *superObject.engineObject.comport;
	// write("AiStruct: "); printAddressInformation(ai);
	// Intelligence* intelligence = ai.intelligence;
	// write("Intelligence: ");printAddressInformation(intelligence);

	// assert(intelligence, "Null intelligence");

	// // fn_bIntelligenceRulesEngine

	// int count = intelligence.field_8.byte_8;
	// ubyte num = intelligence.field_10.field_4;

	// for(ubyte i = 0; i < count; i++) {
	// 	ubyte result = fn_ucIsRuleInActionTable(intelligence, cast(ubyte)(i + 1));

	// 	tdstNodeInterpret* node;

	// 	if(result >= num) {
	// 		node = *(intelligence.field_8.firstNode + 4 * i);
	// 		write("Node: "); printAddressInformation(node);
	// 	}
	// 	else {
	// 		node = fn_p_stGetTableAction(intelligence, result);
	// 		write("Node: "); printAddressInformation(node);
	// 	}

	// 	fn_p_stIntelligenceEvalTreeEngine(superObject, node);
	// }
}

ubyte fn_ucIsRuleInActionTable(Intelligence* intelligence, ubyte a2) {
	IntelligenceField10* field_10 = intelligence.field_10;
	ubyte v3 = field_10.field_4;
	ubyte* ptr = field_10.field_0;

	ubyte result = 0;

	if(field_10.field_5 && v3) {
		ubyte* v6 = (ptr + 101);

		while(!*(v6 - 1) || *v6 != a2) {
			result++;
			v6 += 104;
			if(result >= v3)
				return v3;
		}
	}
	else
		return v3;

	return result;
}

tdstNodeInterpret* fn_p_stGetTableAction(Intelligence* intelligence, ubyte a2) {
	int v2 = 104 * a2;
	return *cast(tdstNodeInterpret**)(intelligence.field_10.field_0 + v2 + 96);
}

void fn_p_stIntelligenceEvalTreeEngine(SuperObject* superObject, tdstNodeInterpret* node) {
	ubyte v3 = node.param;
	tdstGetSetParam ret;
	fn_p_stEvalTree(superObject, node, &ret);
}

void fn_p_stEvalTree(SuperObject* superObject, tdstNodeInterpret* node, tdstGetSetParam* param) {
	a_stTypeTable[node.functionType](superObject, node, param);
}

alias funcPtr = void* function(SuperObject*, tdstNodeInterpret* node, tdstGetSetParam* param);

funcPtr[] a_stTypeTable = [
	null,
	null,
	&getOperator,
	&getFunction,
];

alias fn_p_stScalarOperator = nullFunc!"fn_p_stScalarOperator";
alias _fn_p_stAffectOperator = nullFunc!"_fn_p_stAffectOperator";
alias _fn_p_stDotOperator = nullFunc!"_fn_p_stDotOperator";

void* nullFunc(string name)(SuperObject* superObject, tdstNodeInterpret* node, tdstGetSetParam* param) {
	writeln("Not implemented:", name);
	return null;
}

funcPtr[] a_stOperatorTable = [
	&fn_p_stScalarOperator,
	&fn_p_stScalarOperator,
	&fn_p_stScalarOperator,
	&fn_p_stScalarOperator,
	&fn_p_stScalarOperator,
	&_fn_p_stAffectOperator,
	&_fn_p_stAffectOperator,
	&_fn_p_stAffectOperator,
	&_fn_p_stAffectOperator,
	&_fn_p_stAffectOperator,
	&_fn_p_stAffectOperator,
	&_fn_p_stAffectOperator,
	&_fn_p_stDotOperator,
];

void* getOperator(SuperObject* superObject, tdstNodeInterpret* node, tdstGetSetParam* param) {
	writeln("getOperator: ", node.tableIndex);
	funcPtr func = a_stOperatorTable[node.tableIndex];
	return func(superObject, node.nextNode, param);
}

void* getFunction(SuperObject* superObject, tdstNodeInterpret* node, tdstGetSetParam* param) {
	writeln("getFunction");
	return null;
}

/*************************************************
	DSB Scripts
**************************************************/

// Script sections

struct Section {
	int id;
	string name;
	void function(MemoryReader) callback;
}

Section[int] sections;

void registerSection(int id, string name, void function(MemoryReader) callback) {
	sections[id] = Section(id, name, callback);
}

shared static this() {
	registerSection(0, "NewBinaryMemoryDescription", &parse_NewBinaryMemoryDescription);
	registerSection(40, "DirectoriesDescription", &parse_DirectoriesDescription);
	registerSection(64, "BigFiles", &parse_BigFiles);
	registerSection(70, "Vignette", &parse_Vignette);
	registerSection(110, "InitInputDeviceManager", &parse_InitInputDeviceManager);
	registerSection(120, "ActivateDevices", &parse_ActivateDevices);
	registerSection(32, "RandomDescription", &parse_RandomDescription);
	registerSection(100, "GameOptionsFile", &parse_GameOptionsFile);
	registerSection(30, "FirstLevelDescription", &parse_FirstLevelDescription);
}

void parse_NewBinaryMemoryDescription(MemoryReader r) {
	uint id;
	while((id = r.read!uint) != 0xFFFF) {
		if(id == 1) {
			writeln("GameFixMemorySize");
			int value = r.read!uint;
		}
		else if(id == 11) {
			writeln("GameLevelMemorySize");
			int value = r.read!uint;
		}
		else if(id == 8) {
			writeln("FontMemorySize");
			int value = r.read!uint;
		}
		else if(id == 7) {
			writeln("SAIFixMemorySize");
			int value = r.read!uint;
		}
		else if(id == 14) {
			writeln("SAIMemorySize");
			int value = r.read!uint;
		}
		else if(id == 5) {
			writeln("TMPFixMemory");
			int value = r.read!uint;
		}
		else if(id == 4) {
			writeln("AIFixMemory");
			int value = r.read!uint;
		}
		else if(id == 12) {
			writeln("AIMemory");
			int value = r.read!uint;
		}
		else if(id == 3) {
			writeln("ACPTextMemory");
			int value = r.read!uint;
		}
		else if(id == 2) {
			writeln("ACPFixMemory");
			int value = r.read!uint;
		}
		else if(id == 13) {
			writeln("ACPMemory");
			int value = r.read!uint;
		}
		else if(id == 9) {
			writeln("PositionMemorySize");
			int value = r.read!uint;
		}
		else if(id == 16) {
			writeln("ScriptMemorySize");
			int value1 = r.read!uint;
			int value2 = r.read!uint;
		}
		else if(id == 6) {
			writeln("IPTMemorySize");
			int value = r.read!uint;
		}
		else
			writeln("Invalid id %s".format(id));
	}
}

void parse_DirectoriesDescription(MemoryReader r) {
	string ids[int] = [
		41: "DirectoryOfEngineDLL",
		42: "DirectoryOfGameData",
		43: "DirectoryOfTexts",
		44: "DirectoryOfWorld",
		45: "DirectoryOfLevels",
		46: "DirectoryOfFamilies",
		47: "DirectoryOfCharacters",
		48: "DirectoryOfAnimations",
		49: "DirectoryOfGraphicsClasses",
		50: "DirectoryOfGraphicsBanks",
	];

	uint id;
	while((id = r.read!uint) != 0xFFFF) {
		if(string* name = id in ids) {
			string value = r.readScriptString();
			writeln(*name, ": ", value);
		}
		else
			writeln("Invalid id %s".format(id));
	}
}

void parse_BigFiles(MemoryReader r) {
	string ids[int] = [
		65: "Vignettes",
		66: "Textures",
	];
	
	uint id;
	while((id = r.read!uint) != 0xFFFF) {
		if(string* name = id in ids) {
			string value = r.readScriptString();
			writeln(*name, ": ", value);
		}
		else
			writeln("Invalid id %s".format(id));
	}
}

void parse_Vignette(MemoryReader r) {
	uint id;
	while((id = r.read!uint) != 0xFFFF) {
		if(id == 71) {
			write("LoadVignette");
			string value = r.readScriptString();
			writeln(": ", value);
		}
		else if(id == 72) {
			write("LoadLevelVignette");
			string value = r.readScriptString();
			writeln(": ", value);
		}
		else if(id == 73) {
			writeln("InitVignette");
		}
		else if(id == 74) {
			writeln("FreeVignette");
		}
		else if(id == 75) {
			writeln("DisplayVignette");
		}
		else if(id == 76) {
			writeln("InitBarOutlineColor");
			r.read!float;
			r.read!int;
		}
		else
			writeln("Invalid id %s".format(id));
	}
}

void parse_InitInputDeviceManager(MemoryReader r) {
	r.read!uint;
	uint section = r.read!uint;
	if(Section* s = section in sections) {
		writeln(s.name, " {");
		s.callback(r);
		writeln("}");
	}
	else
		writeln("Section type %s not implemented".format(section));
}

void parse_ActivateDevices(MemoryReader r) {
	uint id;
	while((id = r.read!uint) != 0xFFFF) {
		if(id == 121) {
			writeln("Unknown input");
		}
		else if(id == 122) {
			writeln("Joystick");
		}
		else if(id == 123) {
			writeln("Keyboard");
		}
		else if(id == 124) {
			writeln("Mouse");
		}
		else
			writeln("Invalid id %s".format(id));
	}
}

void parse_RandomDescription(MemoryReader r) {
	r.read!uint;

	uint id;
	while((id = r.read!uint) != 0xFFFF) {
		if(id == 33) {
			writeln("ComputeTable");
		}
		else if(id == 34) {
			writeln("ReadTable");
		}
		else
			writeln("Invalid id %s".format(id));
	}
}

void parse_GameOptionsFile(MemoryReader r) {
	uint id;
	while((id = r.read!uint) != 0xFFFF) {
		if(id == 101) {
			write("DefaultFile");
			string value = r.readScriptString();
			writeln(": ", value);
		}
		else if(id == 102) {
			write("CurrentFile");
			string value = r.readScriptString();
			writeln(": ", value);
		}
		else if(id == 103) {
			write("FrameSynchro");
			string value1 = r.readScriptString();
			string value2 = r.readScriptString();
			string value3 = r.readScriptString();
			writeln(": ", [ value1, value2, value3 ]);
		}
		else
			writeln("Invalid id %s".format(id));
	}
}

void parse_FirstLevelDescription(MemoryReader r) {
	r.read!uint;

	uint id;
	while((id = r.read!uint) != 0xFFFF) {
		if(id == 31) {
			write("LevelName");
			string value = r.readScriptString();
			writeln(": ", value);
		}
		else
			writeln("Invalid id %s".format(id));
	}
}

string readScriptString(MemoryReader r) {
	ushort len = r.read!ushort;
	return r.readArray!char(len)[0 .. $ -1].idup;
}

@handler
void scripts2(string[] args) {
	relocationLogging = false;

	ubyte[] encoded = cast(ubyte[])read(r"D:\GOG Games\Rayman 2\Data\Game.dsb");
	ubyte[] decoded = decodeData(encoded);

	MemoryReader r = new MemoryReader(decoded);
	r.read!uint;

	uint section;
	while((section = r.read!uint) != 0xFFFF) {
		if(Section* s = section in sections) {
			writeln(s.name, " {");
			s.callback(r);
			writeln("}");
		}
		else
			writeln("Section type %s not implemented".format(section));
	}
}