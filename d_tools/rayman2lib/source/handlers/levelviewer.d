module handlers.levelviewer;

import app;
import derelict.sdl2.sdl, derelict.opengl3.gl, derelict.devil.il, derelict.imgui.imgui;
import gfm.math.matrix, gfm.math.vector, gfm.math.quaternion;
import consoled;
import core.thread, std.datetime, std.math, std.algorithm;
import global, formats.relocationtable, formats.sna, formats.gpt, structures.model, utils, structures.superobject, structures.gamestruct;
import std.random, std.string, std.conv;
import handlers.renderingplatform;
import core.sys.windows.windows;
import dllmain;

mixin registerHandlers;

int baseAddress;

bool isValidSnaAddress(void* address) {
	//int limit = 0x753b34 / 2;
	//return cast(int)address > baseAddress - limit && cast(int)address < baseAddress + limit;
	return cast(int)address > 100000; 
}

@handler
void levelviewer(string[] args) {
	relocationLogging = false;

	baseAddress = cast(int)*cast(SuperObject**)0x500FD0;

	// Prepare files for PC version

	version(exe) {
		enum levelsDir = r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\\";

		SNAFormat sna = new SNAFormat(levelsDir ~ "Fix.sna");
		sna.relocatePointersUsingFile(levelsDir ~ "Fix.rtb");
		
		readRelocationTableFromFile(levelsDir ~ "Fix.rtp");
		FixGPT fixGpt = new FixGPT(levelsDir ~ "Fix.gpt");
		 
		enum levelName = "Learn_30";
		
		SNAFormat levelSna = new SNAFormat(levelsDir ~ levelName ~ r"\\" ~ levelName ~ ".sna");
		levelSna.relocatePointersUsingBigFileAuto(levelsDir ~ "LEVELS0.DAT");
		readRelocationTableFromBigFileAuto(levelsDir ~ "LEVELS0.DAT", levelName, RelocationTableType.gpt);
		LevelGPT levelGpt = new LevelGPT(levelsDir ~ levelName ~ r"\\" ~ levelName ~ ".gpt");
	}

	// Prepare files for demo version
	
//	version(exe) {
//		enum levelsDir = r"D:\GOG Games\Rayman 2 Early Demo\BinData\World\Levels\";
//		
//		SNAFormat sna = new SNAFormat(levelsDir ~ "Fix.sna");
//		sna.relocatePointersUsingFile(levelsDir ~ "Fix.rtb");
//		
//		readRelocationTableFromFile(levelsDir ~ "Fix.rtp");
//		FixGPT fixGpt = new FixGPT(levelsDir ~ "Fix.gpt");
//		
//		enum levelName = "Bast_22";
//		
//		SNAFormat levelSna = new SNAFormat(levelsDir ~ levelName ~ r"\" ~ levelName ~ ".sna");
//		levelSna.relocatePointersUsingFile(levelsDir ~ levelName ~ r"\" ~ levelName ~ ".rtb");
//		readRelocationTableFromFile(levelsDir ~ levelName ~ r"\" ~ levelName ~ ".rtp");
//		LevelGPT levelGpt = new LevelGPT(levelsDir ~ levelName ~ r"\" ~ levelName ~ ".gpt");
//	}

	// Prepare files for iOS version
	
//	version(exe) {
//		enum levelsDir = r"E:\Desktop\Rayman Stuff\Rayman2.app\DATA\WORLD\LEVELS\";
//		
//		SNAFormat sna = new SNAFormat(levelsDir ~ "Fix.sna");
//		sna.relocatePointersUsingFile(levelsDir ~ "Fix.rtb");
//		
//		readRelocationTableFromFile(levelsDir ~ "Fix.rtp");
//		FixGPT fixGpt = new FixGPT(levelsDir ~ "Fix.gpt");
//		
//		enum levelName = "BALL";
//		
//		SNAFormat levelSna = new SNAFormat(levelsDir ~ levelName ~ r"\" ~ levelName ~ ".sna");
//		levelSna.relocatePointersUsingFile(levelsDir ~ levelName ~ r"\" ~ levelName ~ ".rtb");
//		readRelocationTableFromFile(levelsDir ~ levelName ~ r"\" ~ levelName ~ ".rtp");
//		LevelGPT levelGpt = new LevelGPT(levelsDir ~ levelName ~ r"\" ~ levelName ~ ".gpt");
//	}

	// Create a renderer window

	Platform platform = new Platform();

	bool test(int n) {
		writecln(n);
		return false;
	}

	bool drawObjectNames = true;
	bool drawObjectCubes = true;
	bool drawUnspawnedObjects = false;
	bool useGameCamera = false;

	SuperObject* selectedObject;

	void drawModel(Model_0_0* model) {
		Model_0_1* model_0_1 = model.model_0_1;

		if(!isValidSnaAddress(model) || !isValidSnaAddress(model_0_1) ||
			model_0_1.model_1_2 is null || !isValidSnaAddress(model_0_1.model_1_2) ||
			model_0_1.model_1_2.model_0_3 is null || !isValidSnaAddress(model_0_1.model_1_2) || !isValidSnaAddress(model_0_1.model_1_2.model_0_3) ||
			model_0_1.model_1_2.model_0_3.model_0_4 is null)
			return;

		Model_0_3* model_0_3 = model.model_0_1.model_1_2.model_0_3;

		foreach(model_0_5; model_0_3.submodels) {
			glColor3f(1f, 1f, 1f);

			if(model_0_5.textureInfo_0 && model_0_5.textureInfo_0.textureInfo_1 && model_0_5.textureInfo_0.textureInfo_1.textureInfo_2) {
				glEnable(GL_TEXTURE_2D);
				string filename = model_0_5.textureInfo_0.textureInfo_1.textureInfo_2.textureFilename.ptr.fromStringz.idup;
				glBindTexture(GL_TEXTURE_2D, platform.getTexture(filename));
			}
			else
				glDisable(GL_TEXTURE_2D);

			glBegin(GL_TRIANGLES);
			for(int i = 0; i < model_0_5.faceCount; i++) {
				VertexFace face = model_0_5.indices[i];
				UVFace uvFace = model_0_5.uvIndices[i];
				
				glTexCoord2f(model_0_5.uvs[uvFace.xIndex].u, 1f - model_0_5.uvs[uvFace.xIndex].v);
				glVertex3f(model_0_3.vertices[face.xIndex].x, model_0_3.vertices[face.xIndex].y, model_0_3.vertices[face.xIndex].z);
				glTexCoord2f(model_0_5.uvs[uvFace.yIndex].u, 1f - model_0_5.uvs[uvFace.yIndex].v);
				glVertex3f(model_0_3.vertices[face.yIndex].x, model_0_3.vertices[face.yIndex].y, model_0_3.vertices[face.yIndex].z);
				glTexCoord2f(model_0_5.uvs[uvFace.zIndex].u, 1f - model_0_5.uvs[uvFace.zIndex].v);
				glVertex3f(model_0_3.vertices[face.zIndex].x, model_0_3.vertices[face.zIndex].y, model_0_3.vertices[face.zIndex].z);
				//writecln(model_0_3.vertices[face.zIndex].y);
			}
			glEnd();
		}
	}

	void drawNames(SuperObject* superObject) {
		auto io = igGetIO();
		
		if(superObject.type == 2) {
			SOStandardGameStruct* gameStruct = superObject.engineObject.standardGameStruct;
			
			string name;
			try {
				name = (&gameStruct.name).fromStringz.idup;
			}
			catch(Throwable e) {
				writecln("Error getting standard game struct name");
			}
			
			if(useGameCamera && name == "StdCamer") {
				vec4f objPos = superObject.matrix.toMat4f.column(3);
				platform.cameraPosition = objPos.xyz;
				platform.cameraMatrix = superObject.matrix.toMat4f * mat4f.rotateZ(PI);
			}
			
			try {
				mat4f m = mat4f();
				glGetFloatv(GL_MODELVIEW_MATRIX, m.ptr);
				m = m.transposed;
				
				vec4f objPos = superObject.matrix.toMat4f.column(3);
				
				auto onScreen = ((m * gfm.math.matrix.Matrix!(float, 4, 1).fromColumns([objPos]))
					.column(0) - vec4f(0.5f, 0.5f, 0, 0)) * vec4f(platform.width / 2f, platform.height / 2f, 1, 0);
				
				auto fixedOnScreen = vec2f(platform.width / 2f - onScreen.x / onScreen.z / platform.aspectRatio, platform.height / 2f + onScreen.y / onScreen.z);
				
				if(drawObjectNames) {
					if(onScreen.z < 0) {
						ImVec2 textSize;
						igCalcTextSize(&textSize, name.toStringz);
						ImDrawList_AddText(igGetWindowDrawList(), ImVec2(platform.width / 2f - onScreen.x / onScreen.z / platform.aspectRatio - textSize.x / 2f, platform.height / 2f + onScreen.y / onScreen.z - textSize.y / 2f), 0xFFFFFFFF, name.toStringz);
						
						if(io.MouseClicked[0]) {
							vec2f mousePos = vec2f(io.MousePos.x, io.MousePos.y);
							if((mousePos - fixedOnScreen).length < abs(150f / onScreen.z)) {
								selectedObject = superObject;
							}
						}
						
						if((platform.cameraPosition - objPos.xyz).length < 15f)
							ImDrawList_AddCircle(igGetWindowDrawList(), ImVec2(platform.width / 2f - onScreen.x / onScreen.z / platform.aspectRatio, platform.height / 2f + onScreen.y / onScreen.z), 150f / onScreen.z, 0xffffffff, 16);
					}
				}
			}
			catch(Throwable e) {
				writecln("Exception");
			}
		}

		if(drawUnspawnedObjects) {
			if(superObject.type == 4) {
				for(SuperObject** childSuperObject = superObject.engineObject.firstSuperObject; childSuperObject; childSuperObject = cast(SuperObject**)*(cast(int*)childSuperObject + 1)) {
					
					SuperObject* actualObject = *childSuperObject;
					
					SOStandardGameStruct* gameStruct = actualObject.engineObject.standardGameStruct;
					
					drawNames(actualObject);
				}
			}
		}

		foreach(child; superObject.getChildren()) {
			drawNames(child);
		}
		
		if(superObject.nextTwin)
			drawNames(superObject.nextTwin);
	}

	void render(SuperObject* superObject, int depth = 0) {
		if(superObject.type == 2) {
			SOStandardGameStruct* gameStruct = superObject.engineObject.standardGameStruct;

			RenderInfo* renderInfo = superObject.engineObject.renderInfo;

			if(drawObjectCubes) {
				auto rnd = Random(cast(uint)superObject);
				glColor3f(uniform(0f, 1f, rnd), uniform(0f, 1f, rnd), uniform(0f, 1f, rnd));

				if(selectedObject == superObject)
					glColor3f(0f, 0.2f, 1f);

				glDisable(GL_TEXTURE_2D);
				glPushMatrix();
				glMultMatrixf(superObject.matrix.toMat4f.transposed.ptr);
				drawCube(vec3f(-0.5f, -0.5f, -0.5f), vec3f(0.5f, 0.5f, 0.5f));
				glPopMatrix();
			}
		}

		if(drawUnspawnedObjects) {
			if(superObject.type == 4) {
				for(SuperObject** childSuperObject = superObject.engineObject.firstSuperObject; childSuperObject; childSuperObject = cast(SuperObject**)*(cast(int*)childSuperObject + 1)) {
					
					SuperObject* actualObject = *childSuperObject;
					
					SOStandardGameStruct* gameStruct = actualObject.engineObject.standardGameStruct;
					
					render(actualObject, depth++);
				}
			}
		}

		if(superObject.type == 64 || superObject.type == 32 || superObject.type == 4) {
			if(superObject.engineObject && superObject.engineObject.firstModel &&
				superObject.engineObject.firstModel.model_0_1 && superObject.engineObject.firstModel.model_0_1.model_1_2 &&
				superObject.engineObject.firstModel.model_0_1.model_1_2.model_0_3) {
				try {
					//printAddressInformation(superObject.info.firstModel.model_0_1.model_1_2.model_0_3);
					drawModel(superObject.engineObject.firstModel);
				}
				catch(Throwable e) { }
			}
		}

		if(superObject.type == 8) {
			glPushMatrix();
			try {
				//writecln("Matrix type: ", *cast(int*)&superObject.matrix.fields[0]);
				glMultMatrixf(superObject.matrix.toMat4f.transposed.ptr);
				drawModel(superObject.firstModel);
			}
			catch(Throwable e) { }
			glPopMatrix();
		}

		foreach(child; superObject.getChildren()) {
			if(superObject.type == 8) {
				//SOStandardGameStruct* gameStruct = superObject.info.standardGameStruct;

				//glPushMatrix();
				//glMultMatrixf(superObject.matrix.toMat4f.transposed.ptr);
				//writecln(superObject.matrix.fields[1]);
				//glTranslatef(-superObject.matrix.fields[1], superObject.matrix.fields[3], superObject.matrix.fields[2]);
				//glScalef(superObject.matrix.fields[4], superObject.matrix.fields[12], superObject.matrix.fields[8]);
				render(child, depth++);
				//glPopMatrix();
			}
			else
				render(child, depth++);
		}
		
		if(superObject.nextTwin)
			render(superObject.nextTwin, depth++);
	}

	float roll = 0f, pitch = 0f;

	platform.renderDelegate = () {
		//platform.cameraPosition.xz = vec2f(cos(platform.time), sin(platform.time)) * 120f;
		//platform.cameraRotation = quatf.fromEulerAngles(0, -platform.time + PI_2, 0);
		
//		glColor3f(1f, 1f, 0f);
//		glBegin(GL_TRIANGLES);
//		glVertex3f(0f, 0f, 0f);
//		glVertex3f(0f, 0f, 1f);
//		glVertex3f(0f, 1f, 1f);
//		glEnd();

		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		version(exe)
			render(levelGpt.SECT_hFatherSector);
		version(dll)
			//render(cast(SuperObject*)0x500FC8);
			render(*cast(SuperObject**)0x500FD0);
			//render(cast(SuperObject*)0x2f915a0);
	};

	platform.updateDelegate = (dt) {
		auto io = igGetIO();

		SDL_SetRelativeMouseMode(io.MouseDown[1]);

		igPushStyleColor(ImGuiCol_WindowBg, ImVec4(0, 0, 0, 0));
		igPushStyleColor(ImGuiCol_FrameBg, ImVec4(0, 0, 0, 0));
		igBegin("yolo", null, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoInputs);
		igSetWindowPos(ImVec2(0, 0));
		igSetWindowSize(io.DisplaySize);
		ImDrawList_AddText(igGetWindowDrawList(), ImVec2(0, 0), 0xFFFFFFFF, "Hello world!");
		version(exe)
			drawNames(levelGpt.SECT_hFatherSector);
		version(dll)
			drawNames(*cast(SuperObject**)0x500FD0);
		igEnd();
		igPopStyleColor(2);

		igBegin("Options");
		igCheckbox("Draw object names", &drawObjectNames);
		igCheckbox("Draw object cubes", &drawObjectCubes);
		igCheckbox("Draw unspawned objects", &drawUnspawnedObjects);
		igCheckbox("Use game camera", &useGameCamera);
		version(dll) {
			if(!pauseEngine && igButton("Pause Rayman 2")) {
				pauseEngine = true;
				// TODO: Make this actually pause Rayman
			}
			else if(pauseEngine && igButton("Unpause Rayman 2")) {
				pauseEngine = false;
			}
		}
		igEnd();

		version(dll) {
			igBegin("Levels");
			foreach(name; levelList)
				if(igButton(name.toStringz))
					(cast(void function(const(char)*, bool))0x4054D0)(name.toStringz, false);
			igEnd();
		}

		version(dll) {
			auto fn_vInsertObjectInSectorList = cast(EngineObject* function(SuperObject* sector, SuperObject* object))0x00412740;
			auto fn_vInsertActorInDynamicHierarchy = cast(EngineObject* function(SuperObject* actor, ubyte))0x040B4C0;
			auto HIE_fn_vDestroySuperObject = cast(void function(SuperObject* superObject))0x45BC60;
			auto fn_vDesinitOneObject = cast(void function(SuperObject* superObject))0x405D10;

			static SNAFormat sna = null;
			static SNAFormat levelSna = null;
			static LevelGPT levelGpt = null;

			igBegin("Test");
			if(!sna) {
				if(igButton("Load external SNA")) {
					enum levelsDir = r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\\";
					
					sna = new SNAFormat(levelsDir ~ "Fix.sna");
					sna.relocatePointersUsingFile(levelsDir ~ "Fix.rtb");
					
					readRelocationTableFromFile(levelsDir ~ "Fix.rtp");
					FixGPT fixGpt = new FixGPT(levelsDir ~ "Fix.gpt");

					enum levelName = "Chase_10";
					
					levelSna = new SNAFormat(levelsDir ~ levelName ~ r"\\" ~ levelName ~ ".sna");
					levelSna.relocatePointersUsingBigFileAuto(levelsDir ~ "LEVELS0.DAT");
					readRelocationTableFromBigFileAuto(levelsDir ~ "LEVELS0.DAT", levelName, RelocationTableType.gpt);
					levelGpt = new LevelGPT(levelsDir ~ levelName ~ r"\\" ~ levelName ~ ".gpt");
				}
			}
			else {
				if(igButton("Insert rayman into world")) {
					SuperObject* world = *cast(SuperObject**)0x500FD0;
					SuperObject* externalRayman = cast(SuperObject*)(sna.data.ptr + 0x61D29F);
					fn_vInsertObjectInSectorList(world, externalRayman);
					//fn_vInsertActorInDynamicHierarchy(externalRayman, 0);
				}
				if(igButton("Insert external world into world")) {
					SuperObject* world = *cast(SuperObject**)0x500FD0;
					//SuperObject* externalRayman = cast(SuperObject*)(sna.data.ptr + 0x61D29F);
					fn_vInsertObjectInSectorList(world, levelGpt.SECT_hFatherSector);
					writecln("Inserted world into world");
					//fn_vInsertActorInDynamicHierarchy(externalRayman, 0);
				}
				if(selectedObject && igButton("Insert rayman into selected object")) {
					SuperObject* externalRayman = cast(SuperObject*)(sna.data.ptr + 0x61D29F);
					fn_vInsertObjectInSectorList(selectedObject, externalRayman);
					writecln("Inserted rayman into selected object");
				}
				if(selectedObject && igButton("Insert external world into selected object")) {
					SuperObject* world = *cast(SuperObject**)0x500FD0;
					fn_vInsertObjectInSectorList(selectedObject, levelGpt.SECT_hFatherSector);
					writecln("Inserted world into selected object");
				}
			}

			if(igButton("Activate all inactive actors")) {
				SuperObject* gp_stInactiveDynamicWorld = *cast(SuperObject**)0x500FC4;

				void insertInDynamicWorld(SuperObject* so) {
					foreach(child; so.getChildren) {
						fn_vInsertActorInDynamicHierarchy(child, 0);
						insertInDynamicWorld(child);
					}
				}

				insertInDynamicWorld(gp_stInactiveDynamicWorld);
			}

			igEnd();
		}

		if(selectedObject && selectedObject.type <= 64) {
			igBegin("Selected object");

			if(igCollapsingHeader("Extra data")) {
				igText("SuperObject: 0x%s".format(selectedObject).toStringz);
				igText("SuperObject type: %s".format(selectedObject.type).toStringz);
				if(selectedObject.parent) {
					string parentName;
					if(selectedObject.parent.type == 2)
						parentName = selectedObject.parent.engineObject.standardGameStruct.strName;
					else if(selectedObject.parent == *cast(SuperObject**)0x500FC4)
						parentName = "gp_stInactiveDynamicWorld";
					else if(selectedObject.parent == *cast(SuperObject**)0x500FD0)
						parentName = "gp_stDynamicWorld";
					else
						parentName = "No name - 0x%s - type %s".format(selectedObject.parent, selectedObject.parent.type);
					igText("Parent: %s".format(parentName).toStringz);
				}
				igText("EngineObject: 0x%s".format(selectedObject.engineObject).toStringz);
				igText("Mind: 0x%s".format(selectedObject.engineObject.mind).toStringz);
			}

			SOStandardGameStruct* gameStruct = selectedObject.engineObject.standardGameStruct;

			igText(&gameStruct.name);

			if(selectedObject.engineObject.hasDynamics) {
				auto dynamics = (*selectedObject.engineObject.dynamics);
				igInputFloat3("Position", *cast(float[3]*)&dynamics.position);
				igInputFloat3("Position (matrix)", *cast(float[3]*)&selectedObject.matrix.fields[1]);
				igInputFloat3("Scale", *cast(float[3]*)&dynamics.scale);

				//igInputFloat("Speed", &dynamics.speedVector);
			}
			else
				igInputFloat3("Position", *cast(float[3]*)&selectedObject.matrix.fields[1]);

			igCheckbox("Is camera", (cast(bool*)&selectedObject.engineObject.isCamera + 3));

			if(igButton("Make inactive")) {
				SuperObject* gp_stInactiveDynamicWorld = *cast(SuperObject**)0x500FC4;
				selectedObject.parent = gp_stInactiveDynamicWorld;
			}

			version(dll)
			if(igButton("Destroy")) {
				HIE_fn_vDestroySuperObject(selectedObject);
				selectedObject = null;
			}

			static EngineObject* engineObject;
			static Mind* mindPointer;

			if(igButton("Teleport to camera")) {
				if(selectedObject.engineObject.hasDynamics) {
					auto dynamics = (*selectedObject.engineObject.dynamics);
					auto cam = platform.cameraPosition;
					dynamics.position = [ cam.x, cam.y, cam.z ];
				}
			}

			if(igButton("Copy engine object"))
				engineObject = selectedObject.engineObject;

			if(igButton("Copy mind pointer"))
				mindPointer = selectedObject.engineObject.mind;

			if(engineObject && igButton("Paste engine object"))
				selectedObject.engineObject = engineObject;
			
			if(mindPointer && igButton("Paste mind pointer"))
				selectedObject.engineObject.mind = mindPointer;

			if(igCollapsingHeader("Children")) {
				foreach(child; selectedObject.getChildren()) {
					string buttonName = "Type: " ~ child.type.to!string;

					if(child.type == 2)
						buttonName ~= ", " ~ (&child.engineObject.standardGameStruct.name).fromStringz;

					if(igButton(buttonName.toStringz) &&  child.type == 2) {
						selectedObject = child;
					}
				}
			}

			if(igCollapsingHeader("GameStruct bits")) {
				for(int i = 0; i < 32; i++) {
					bool value = (gameStruct.customBits >> i) & 1;
					if(igCheckbox(("Bit " ~ i.to!string).toStringz, &value)) {
						gameStruct.customBits &= ~(1 << i);
						if(value)
							gameStruct.customBits |= (1 << i);
					}
				}
			}

			version(dll)
			if(igCollapsingHeader("AI")) {
				if(igButton("Disable rules")) {
					selectedObject.engineObject.mind.normalIntelligence.rules = null;
				}

				if(igButton("Disable reflex")) {
					selectedObject.engineObject.mind.normalIntelligence.field_8 = null;
				}

				if(selectedObject in forceTrueConditionSuperObjects && forceTrueConditionSuperObjects[selectedObject]) {
					if(igButton("Disable force true conditions"))
						forceTrueConditionSuperObjects[selectedObject] = false;
				}
				else
					if(igButton("Force true conditions"))
						forceTrueConditionSuperObjects[selectedObject] = true;
			}

			igEnd();
		}

		if(io.MouseDown[1]) {
			auto keyboardState = SDL_GetKeyboardState(null);

			float speed = 50f;

			if(keyboardState[SDL_SCANCODE_LSHIFT])
				speed *= 10f;

			if(keyboardState[SDL_SCANCODE_W]) platform.cameraPosition += (cast(mat4f)platform.cameraRotation * mat4f.translation(vec3f(0, 1f, 0))).column(3).xyz * dt * speed;
			if(keyboardState[SDL_SCANCODE_S]) platform.cameraPosition += (cast(mat4f)platform.cameraRotation * mat4f.translation(vec3f(0, -1f, 0))).column(3).xyz * dt * speed;

			if(keyboardState[SDL_SCANCODE_A]) platform.cameraPosition += (cast(mat4f)platform.cameraRotation * mat4f.translation(vec3f(-1f, 0, 0))).column(3).xyz * dt * speed;
			if(keyboardState[SDL_SCANCODE_D]) platform.cameraPosition += (cast(mat4f)platform.cameraRotation * mat4f.translation(vec3f(1f, 0, 0))).column(3).xyz * dt * speed;

			roll -= platform.mouseDeltaY * dt * 0.2f;
			pitch -= platform.mouseDeltaX * dt * 0.2f;

			roll = clamp(roll, -PI_2, PI_2);

			platform.cameraRotation = quatf.fromEulerAngles(0, 0, pitch) * quatf.fromEulerAngles(roll, 0, 0);

			if(!useGameCamera)
				platform.cameraMatrix = mat4f.translation(platform.cameraPosition) * cast(mat4f)platform.cameraRotation;
		}
	};

	platform.start();
}