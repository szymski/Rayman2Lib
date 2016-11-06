module formats.gpt;

import formats.pointertable, structures.sector;
import std.stdio;

private abstract class GPTFormat {
	PointerTableFormat pt;

	this(string filename) {
		pt = new PointerTableFormat(filename);
		parse();
	}

	this(ubyte[] data) {
		pt = new PointerTableFormat(data);
		parse();
	}

	abstract void parse();
}

/**
	Represents fix GPT file.
*/
class FixGPT : GPTFormat {
	float* POS_g_p_stIdentityMatrix;
	
	float* HIE_g_lNbMatrixInStack;
	ubyte* dword_50036C;
	ubyte* dword_501404;
	ubyte*[] dword_5002C0;
	ubyte* dword_50A980;
	ubyte*[] IPT_g_hInputStructure;
	ubyte* dword_50A564;
	ubyte*[] dword_500260;
	ubyte*[] tdstStacks;
	ubyte* p_stA3dGENERAL;
	ubyte* p_a3_xVectors;
	ubyte* p_a4_xQuaternions;
	ubyte* p_stHierarchies;
	ubyte* p_stNTT0;
	ubyte* p_stOnlyFrames;
	ubyte* p_stChannels;
	ubyte* p_stFrames;
	ubyte* p_stFramesKF;
	ubyte* p_stKeyFrames;
	ubyte* dword_500298;
	ubyte* p_stMorphData;
	ubyte* dword_4B72F0;

	this(string filename) {
		super(filename);
	}

	this(ubyte[] data) {
		super(data);
	}

	override void parse() {
		POS_g_p_stIdentityMatrix = pt.readPointer!(float*);
		
		foreach(i; 0 .. 50)
			pt.readPointer();
		
		HIE_g_lNbMatrixInStack = pt.readPointer!(float*);
		dword_50036C = pt.readPointer!(ubyte*);
		dword_501404 = pt.readPointer!(ubyte*);
		dword_5002C0 = pt.readPointerBlock(0xAC);
		dword_50A980 = pt.readPointer!(ubyte*);
		IPT_g_hInputStructure = pt.readPointerBlock(0xB20);
		dword_50A564 = pt.readPointer!(ubyte*);
		dword_500260 = pt.readPointerBlock(0x14);
		tdstStacks = pt.readPointerBlock(12 * 16);
		p_stA3dGENERAL = pt.readPointer!(ubyte*);
		p_a3_xVectors = pt.readPointer!(ubyte*);
		p_a4_xQuaternions = pt.readPointer!(ubyte*);
		p_stHierarchies = pt.readPointer!(ubyte*);
		p_stNTT0 = pt.readPointer!(ubyte*);
		p_stOnlyFrames = pt.readPointer!(ubyte*);
		p_stChannels = pt.readPointer!(ubyte*);
		p_stFrames = pt.readPointer!(ubyte*);
		p_stFramesKF = pt.readPointer!(ubyte*);
		p_stKeyFrames = pt.readPointer!(ubyte*);
		dword_500298 = pt.readPointer!(ubyte*);
		p_stMorphData = pt.readPointer!(ubyte*);
		dword_4B72F0 = pt.readPointer!(ubyte*);
	}
}

/**
	Represents level GPT file.
*/
class LevelGPT : GPTFormat {
	Sector* gp_stActualWorld;
	Sector* gp_stDynamicWorld;
	Sector* gp_stInactiveDynamicWorld;
	Sector* SECT_hFatherSector;
	ubyte* gs_hFirstSubMapPosition;
	ubyte*[] g_stAlways;
	ubyte* dword_4A6B1C;
	ubyte* dword_4A6B20;
	ubyte* v28;
	ubyte* v31;
	ubyte* v32;
	ubyte* v33;
	ubyte*[]  dword_5013E0;
	ubyte*[] g_stEngineStructure;
	ubyte* gp_stLight;
	ubyte* dword_500578;
	ubyte* g_hCharacterLauchingSoundEvents;
	ubyte* g_hShadowPolygonVisualMaterial;
	ubyte* g_hShadowPolygonGameMaterialInit;
	ubyte* g_hShadowPolygonGameMaterial;
	ubyte* g_p_stTextureOfTextureShadow;
	ubyte* COL_g_d_lTaggedFacesTable;

	uint[] tdstStacks;

	uint[] p_stA3dGENERAL;
	uint[] p_a3_xVectors;
	uint[] p_a4_xQuaternions;
	uint[] p_stHierarchies;
	uint[] p_stNTT0;
	uint[] p_stOnlyFrames;
	uint[] p_stChannels;
	uint[] p_stFrames;
	uint[] p_stFramesKF;
	uint[] p_stKeyFrames;
	uint[] p_stEvents;
	uint[] p_stMorphData;
	
	ubyte* g_AlphabetCharacterPointer;
	ubyte** g_AlphabetCharacterpointer_new;
	ubyte* g_bBeginMapSoundEventFlag;
	ubyte* g_stBeginMapSoundEvent;

	this(string filename) {
		super(filename);
	}
	
	this(ubyte[] data) {
		super(data);
	}
	
	override void parse() {
		auto pointerCount = pt.readPointer!uint;
		
		// TODO: Fix table reading and remove skip
		pt.readPointerBlock(600);
		
		//	foreach(i; 0 .. pointerCount) {
		//		writeln("Reading table");
		//		v23 = levelGpt.readPointer!(uint**);
		//		//printMemory(&v23[1][3], 512);
		//		
		//		if(cast(uint)v23 != 0 && v23[1][3]) {
		//			v24 = levelGpt.readPointer!(ubyte*);
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

		assert(pt.r.position == 604, "Invalid exit position. Table reading inproper.");
		
		writeln("Ended reading table");
		
		gp_stActualWorld = pt.readPointer!(Sector*);
		gp_stDynamicWorld = pt.readPointer!(Sector*);
		gp_stInactiveDynamicWorld = pt.readPointer!(Sector*);
		writeln("SECT_hFatherSector");
		SECT_hFatherSector = pt.readPointer!(Sector*);
		gs_hFirstSubMapPosition = pt.readPointer!(ubyte*);
		g_stAlways = pt.readPointerBlock(0x1C);
		dword_4A6B1C = pt.readPointer!(ubyte*);
		dword_4A6B20 = pt.readPointer!(ubyte*);
		v28 = pt.readPointer!(ubyte*);
		v31 = pt.readPointer!(ubyte*);
		v32 = pt.readPointer!(ubyte*);
		v33 = pt.readPointer!(ubyte*);
		dword_5013E0 = pt.readPointerBlock(0x24);
		g_stEngineStructure = pt.readPointerBlock(0xC30);
		gp_stLight = pt.readPointer!(ubyte*);
		dword_500578 = pt.readPointer!(ubyte*);
		g_hCharacterLauchingSoundEvents = pt.readPointer!(ubyte*);
		g_hShadowPolygonVisualMaterial = pt.readPointer!(ubyte*);
		g_hShadowPolygonGameMaterialInit = pt.readPointer!(ubyte*);
		g_hShadowPolygonGameMaterial = pt.readPointer!(ubyte*);
		g_p_stTextureOfTextureShadow = pt.readPointer!(ubyte*);
		COL_g_d_lTaggedFacesTable = pt.readPointer!(ubyte*);
		
		foreach(i; 0 .. 0xA) {
			pt.readPointer!(ubyte*);
			pt.readPointer!(ubyte*);
		}
		
		pt.readPointer!(ubyte*);
		tdstStacks = pt.readBlock!uint(12 * 16);
		
		p_stA3dGENERAL = pt.readBlock!uint((tdstStacks[1] - tdstStacks[3]) * 56);
		p_a3_xVectors = pt.readBlock!uint((tdstStacks[5] - tdstStacks[7]) * 12);
		p_a4_xQuaternions = pt.readBlock!uint((tdstStacks[9] - tdstStacks[11]) * 8);
		p_stHierarchies = pt.readBlock!uint((tdstStacks[13] - tdstStacks[15]) * 4);
		p_stNTT0 = pt.readBlock!uint((tdstStacks[17] - tdstStacks[19]) * 6);
		p_stOnlyFrames = pt.readBlock!uint((tdstStacks[21] - tdstStacks[23]) * 10);
		p_stChannels = pt.readBlock!uint((tdstStacks[25] - tdstStacks[27]) * 16);
		p_stFrames = pt.readBlock!uint((tdstStacks[29] - tdstStacks[31]) * 2);
		p_stFramesKF = pt.readBlock!uint((tdstStacks[33] - tdstStacks[35]) * 4);
		p_stKeyFrames = pt.readBlock!uint((tdstStacks[37] - tdstStacks[39]) * 36);
		p_stEvents = pt.readBlock!uint((tdstStacks[41] - tdstStacks[43]) * 0xC);
		p_stMorphData = pt.readBlock!uint((tdstStacks[45] - tdstStacks[47]) * 8);
		
		g_AlphabetCharacterPointer = pt.readPointer!(ubyte*);
		g_AlphabetCharacterpointer_new = pt.readPointer!(ubyte**); // TODO: Raw is supposed to be 0x1B500A0, it is not
		g_bBeginMapSoundEventFlag = pt.readPointer!(ubyte*);
		g_stBeginMapSoundEvent = pt.readPointer!(ubyte*);
	}
}