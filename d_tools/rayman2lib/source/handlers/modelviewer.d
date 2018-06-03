module handlers.modelviewer;

import app;
import derelict.sdl2.sdl, derelict.opengl3.gl, derelict.devil.il, derelict.imgui.imgui;
import gfm.math.matrix, gfm.math.vector, gfm.math.quaternion;
import consoled;
import core.thread, std.datetime, std.math, std.algorithm;
import global, formats.relocationtable, formats.sna, formats.gpt, structures.model, utils, structures.superobject, structures.gamestruct;
import std.random, std.string;
import handlers.renderingplatform;

mixin registerHandlers;

@handler
void modelviewer(string[] args) {
	relocationLogging = false;
	
	// Prepare files for PC version
	
	version(exe) {
		enum levelsDir = r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\";
		
		SNAFormat sna = new SNAFormat(levelsDir ~ "Fix.sna");
		sna.relocatePointersUsingFile(levelsDir ~ "Fix.rtb");
		
		readRelocationTableFromFile(levelsDir ~ "Fix.rtp");
		FixGPT fixGpt = new FixGPT(levelsDir ~ "Fix.gpt");
		
		enum levelName = "Chase_10";
		
		SNAFormat levelSna = new SNAFormat(levelsDir ~ levelName ~ r"\" ~ levelName ~ ".sna");
		levelSna.relocatePointersUsingBigFileAuto(levelsDir ~ "LEVELS0.DAT");
		readRelocationTableFromBigFileAuto(levelsDir ~ "LEVELS0.DAT", levelName, RelocationTableType.gpt);
		LevelGPT levelGpt = new LevelGPT(levelsDir ~ levelName ~ r"\" ~ levelName ~ ".gpt");
	}
	
	// Create a renderer window
	
	Platform platform = new Platform();

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
			SOStandardGameStruct* gameStruct = superObject.engineObject.standardGameStruct;
			
			RenderInfo* renderInfo = superObject.engineObject.renderInfo;
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
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
//		version(exe)
//			render(levelGpt.SECT_hFatherSector);
//		version(dll)
//			render(*cast(SuperObject**)0x500FD0);

		version(exe) {
			EngineObject* info = cast(EngineObject*)(levelSna.data.ptr + 0x4DC1);
		
			RenderInfo* renderInfo = info.renderInfo;
			
			if(renderInfo.dword10) {
				void* v7 = *cast(void**)(renderInfo.dword10 + 4);
				struct_v13* v13 = cast(struct_v13*)(v7);
				
				if(cast(int)v13 > 1000)
				for(; v13.renderInfo; v13 = cast(struct_v13*)(cast(int)v13 + 20)) {
					// Unfortunately, a lot of validity testing is required
					if(isValidSnaAddress(v13.renderInfo) &&
						isValidSnaAddress(v13.renderInfo.model_0_1) &&
						cast(int)v13.renderInfo > 1000 && cast(int)v13.renderInfo.model_0_1 > 1000)
						drawModel(v13.renderInfo);
				}
			}
		}

	};
	
	platform.updateDelegate = (dt) {
		auto io = igGetIO();
		
		SDL_SetRelativeMouseMode(io.MouseDown[1]);

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
			
			platform.cameraMatrix = mat4f.translation(platform.cameraPosition) * cast(mat4f)platform.cameraRotation;
		}
	};
	
	platform.start();
}