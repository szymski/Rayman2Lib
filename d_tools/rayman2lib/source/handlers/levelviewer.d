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
		enum levelsDir = r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\";

		SNAFormat sna = new SNAFormat(levelsDir ~ "Fix.sna");
		sna.relocatePointersUsingFile(levelsDir ~ "Fix.rtb");
		
		readRelocationTableFromFile(levelsDir ~ "Fix.rtp");
		FixGPT fixGpt = new FixGPT(levelsDir ~ "Fix.gpt");
		 
		enum levelName = "Learn_30";
		
		SNAFormat levelSna = new SNAFormat(levelsDir ~ levelName ~ r"\" ~ levelName ~ ".sna");
		levelSna.relocatePointersUsingBigFileAuto(levelsDir ~ "LEVELS0.DAT");
		readRelocationTableFromBigFileAuto(levelsDir ~ "LEVELS0.DAT", levelName, RelocationTableType.gpt);
		LevelGPT levelGpt = new LevelGPT(levelsDir ~ levelName ~ r"\" ~ levelName ~ ".gpt");
	}

	// Create a renderer window

	Platform platform = new Platform();

	bool test(int n) {
		writecln(n);
		return false;
	}

	bool drawObjectNames = true;
	bool drawObjectCubes = true;
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

	void render(SuperObject* superObject, int depth = 0) {
		if(superObject.type == 2) {
			SOStandardGameStruct* gameStruct = superObject.info.standardGameStruct;

			RenderInfo* renderInfo = superObject.info.renderInfo;

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

//		if(superObject.type == 4) {
//			for(SuperObject** childSuperObject = superObject.info.firstSuperObject; childSuperObject; childSuperObject = cast(SuperObject**)*(cast(int*)childSuperObject + 1)) {
//				
//				SuperObject* actualObject = *childSuperObject;
//				
//				SOStandardGameStruct* gameStruct = actualObject.info.standardGameStruct;
//				
//				render(actualObject, depth++);
//			}
//		}

		if(superObject.type == 64 || superObject.type == 32 || superObject.type == 4) {
			if(superObject.info && superObject.info.firstModel &&
				superObject.info.firstModel.model_0_1 && superObject.info.firstModel.model_0_1.model_1_2 &&
				superObject.info.firstModel.model_0_1.model_1_2.model_0_3) {
				try {
					//printAddressInformation(superObject.info.firstModel.model_0_1.model_1_2.model_0_3);
					drawModel(superObject.info.firstModel);
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

	void drawNames(SuperObject* superObject) {
		auto io = igGetIO();

		if(superObject.type == 2) {
			SOStandardGameStruct* gameStruct = superObject.info.standardGameStruct;

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
		foreach(child; superObject.getChildren()) {
			drawNames(child);
		}
		
		if(superObject.nextTwin)
			drawNames(superObject.nextTwin);
	}

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
		igCheckbox("Use game camera", &useGameCamera);
		version(dll) {
			static bool paused = false;
			if(!paused && igButton("Pause Rayman 2")) {
				paused = true;
				// TODO: Make this actually pause Rayman
			}
			else if(paused && igButton("Unpause Rayman 2")) {
				paused = false;
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
			auto fn_vInsertObjectInSectorList = cast(SectorInfo* function(SuperObject* sector, SuperObject* object))0x00412740;
			auto fn_vInsertActorInDynamicHierarchy = cast(SectorInfo* function(SuperObject* actor, ubyte))0x040B4C0;

			static SNAFormat sna = null;
			static SNAFormat levelSna = null;
			static LevelGPT levelGpt = null;

			igBegin("Test");
			if(!sna) {
				if(igButton("Load external SNA")) {
					enum levelsDir = r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\";
					
					sna = new SNAFormat(levelsDir ~ "Fix.sna");
					sna.relocatePointersUsingFile(levelsDir ~ "Fix.rtb");
					
					readRelocationTableFromFile(levelsDir ~ "Fix.rtp");
					FixGPT fixGpt = new FixGPT(levelsDir ~ "Fix.gpt");

					enum levelName = "Chase_10";
					
					levelSna = new SNAFormat(levelsDir ~ levelName ~ r"\" ~ levelName ~ ".sna");
					levelSna.relocatePointersUsingBigFileAuto(levelsDir ~ "LEVELS0.DAT");
					readRelocationTableFromBigFileAuto(levelsDir ~ "LEVELS0.DAT", levelName, RelocationTableType.gpt);
					levelGpt = new LevelGPT(levelsDir ~ levelName ~ r"\" ~ levelName ~ ".gpt");
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
			igEnd();
		}

		if(selectedObject && selectedObject.type <= 64) {
			igBegin("Selected object");

			SOStandardGameStruct* gameStruct = selectedObject.info.standardGameStruct;

			igText(&gameStruct.name);

			if(selectedObject.info.hasDynamics) {
				auto dynamics = (*selectedObject.info.dynamics);
				igInputFloat3("Position", *cast(float[3]*)&dynamics.position);
				igInputFloat3("Position (matrix)", *cast(float[3]*)&selectedObject.matrix.fields[1]);
				igInputFloat3("Scale", *cast(float[3]*)&dynamics.scale);

				//igInputFloat("Speed", &dynamics.speedVector);
			}
			else
				igInputFloat3("Position", *cast(float[3]*)&selectedObject.matrix.fields[1]);

			igCheckbox("Is camera", (cast(bool*)&selectedObject.info.isCamera + 3));

			static SectorInfo* engineObject;
			static void* aiPointer;

			if(igButton("Copy engine object"))
				engineObject = selectedObject.info;

			if(igButton("Copy ai pointer"))
				aiPointer = selectedObject.info.aiPointer;

			if(engineObject && igButton("Paste engine object"))
				selectedObject.info = engineObject;
			
			if(aiPointer && igButton("Paste ai pointer"))
				selectedObject.info.aiPointer = aiPointer;

			if(igCollapsingHeader("Children")) {
				foreach(child; selectedObject.getChildren()) {
					string buttonName = "Type: " ~ child.type.to!string;

					if(child.type == 2)
						buttonName ~= ", " ~ (&child.info.standardGameStruct.name).fromStringz;

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