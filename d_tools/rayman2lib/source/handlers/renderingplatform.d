module handlers.renderingplatform;

import app;
import derelict.sdl2.sdl, derelict.opengl3.gl, derelict.devil.il, derelict.imgui.imgui;
import gfm.math.matrix, gfm.math.vector, gfm.math.quaternion;
import consoled;
import core.thread, std.datetime, std.math, std.algorithm;
import global, formats.relocationtable, formats.sna, formats.gpt, structures.model, utils, structures.superobject, structures.gamestruct;
import std.random, std.string;
import dllmain;

class Platform {
	private SDL_Window* _window;
	private SDL_Renderer* _renderer;
	private SDL_GLContext _context;
	
	public int width = 1200;
	public int height = 800;
	public float aspectRatio = 1f;
	
	private bool _running = true;
	
	public vec3f cameraPosition = vec3f(0, 0, 0);
	public quatf cameraRotation = quatf.identity;
	public mat4f cameraMatrix = mat4f.identity;
	
	public float time = 0f;
	
	public void delegate() renderDelegate;
	public void delegate(float dt) updateDelegate;
	
	public float mouseDeltaX = 0f;
	public float mouseDeltaY = 0f;
	
	this() {
		aspectRatio = width / cast(float)height;
	}
	
	void start() {
		writecln(Fg.lightGreen, "Starting rendering platform");
		loadLibraries();
		initWindow();
		enterLoop();
	}
	
	private void loadLibraries() {
		writecln(Fg.lightYellow, "Loading libraries");
		DerelictSDL2.load("lib/SDL2");
		DerelictIL.load("lib/DevIL");
		DerelictGL.load();
		DerelictImgui.load("lib/cimgui");
		
		ilInit();
	}
	
	private void initWindow() {
		if(SDL_Init(SDL_INIT_VIDEO) < 0)
			writecln(Fg.lightRed, "There was an error while initializing SDL.");
		
		SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
		SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
		SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
		SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);
		SDL_GL_SetAttribute(SDL_GL_BUFFER_SIZE, 32);
		SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
		
		writecln(Fg.lightYellow, "Creating window");
		_window = SDL_CreateWindow("rayman2lib", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL);
		//SDL_CreateWindowAndRenderer(_width, _height, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN, &_window, &_renderer);
		//SDL_SetWindowTitle(_window, "rayman2lib");
		writecln(Fg.lightYellow, "Creating OpenGL context");
		_context = SDL_GL_CreateContext(_window);
		
		DerelictGL3.reload();
	}
	
	private float _lastTime = 0;
	
	private void enterLoop() {
		writecln(Fg.white, "Entering main loop");
		
		setupImgui();
		
		auto io = igGetIO();
		io.DisplaySize = ImVec2(cast(float)width, cast(float)height);
		
		while(_running) {
			if(!engineUpdating && !canUpdateEngine) {
				canUpdateEngine = false;

				igNewFrame();
				
				updateEvents();
				
				try {
					if(updateDelegate)
						updateDelegate(time - _lastTime);
				}
				catch(Throwable e) {
					writecln("Error in update delegate");
					writecln(e.toString);
				}
				
				_lastTime = time;
				
				render();
				limitFps();

				canUpdateEngine = true;
			}
		}
		
		SDL_GL_DeleteContext(_context);
		SDL_DestroyWindow(_window);
	}
	
	private void updateEvents() {
		SDL_Event event;
		
		mouseDeltaX = 0f;
		mouseDeltaY = 0f;
		
		auto io = igGetIO();
		
		int mx, my;
		uint mouseMask = SDL_GetMouseState(&mx, &my);
		io.MousePos = ImVec2(cast(float)mx, cast(float)my);
		
		io.MouseDown[0] = (mouseMask & SDL_BUTTON(SDL_BUTTON_LEFT)) != 0;
		io.MouseDown[1] = (mouseMask & SDL_BUTTON(SDL_BUTTON_RIGHT)) != 0;
		io.MouseDown[2] = (mouseMask & SDL_BUTTON(SDL_BUTTON_MIDDLE)) != 0;
		
		while(SDL_PollEvent(&event)) {
			switch(event.type) {
				case SDL_QUIT:
					_running = false;
					break;
					
				case SDL_MOUSEBUTTONDOWN:
					if(event.button.button == SDL_BUTTON_LEFT) io.MouseDown[0] = true;
					if(event.button.button == SDL_BUTTON_RIGHT) io.MouseDown[1] = true;
					if(event.button.button == SDL_BUTTON_MIDDLE) io.MouseDown[2] = true;
					
					break;
					
				case SDL_KEYDOWN:
					if(event.key.keysym.scancode == SDL_SCANCODE_ESCAPE)
						_running = false;
					
					int key = event.key.keysym.sym & ~SDLK_SCANCODE_MASK;
					io.KeysDown[key] = (event.type == SDL_KEYDOWN);
					io.KeyShift = ((SDL_GetModState() & KMOD_SHIFT) != 0);
					io.KeyCtrl = ((SDL_GetModState() & KMOD_CTRL) != 0);
					io.KeyAlt = ((SDL_GetModState() & KMOD_ALT) != 0);
					io.KeySuper = ((SDL_GetModState() & KMOD_GUI) != 0);
					
					break;
					
				case SDL_KEYUP:
					int key = event.key.keysym.sym & ~SDLK_SCANCODE_MASK;
					io.KeysDown[key] = (event.type == SDL_KEYDOWN);
					io.KeyShift = ((SDL_GetModState() & KMOD_SHIFT) != 0);
					io.KeyCtrl = ((SDL_GetModState() & KMOD_CTRL) != 0);
					io.KeyAlt = ((SDL_GetModState() & KMOD_ALT) != 0);
					io.KeySuper = ((SDL_GetModState() & KMOD_GUI) != 0);
					
					break;
					
				case SDL_TEXTINPUT:
					ImGuiIO_AddInputCharactersUTF8(event.text.text.ptr);
					break;
					
				case SDL_MOUSEMOTION:
					mouseDeltaX = event.motion.xrel;
					mouseDeltaY = event.motion.yrel;
					break;
					
				default:
					break;
			}
		}
	}
	
	private void render() {
		glViewport(0, 0, width, height);
		
		glClearColor(0.1f, 0.1f, 0.4f, 1f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		
		auto projMatrix = mat4f.perspective(PI_2, aspectRatio, 0.01, 1000f);
		glMatrixMode(GL_PROJECTION);
		glLoadMatrixf(projMatrix.transposed.ptr);
		
		glMatrixMode(GL_MODELVIEW);
		auto cameraInverseMatrix = (cameraMatrix * mat4f.rotateX(PI_2)).inverse;
		glLoadMatrixf(cameraInverseMatrix.transposed.ptr);
		
		glDisable(GL_CULL_FACE);
		glEnable(GL_DEPTH_TEST);
		glDepthFunc(GL_LEQUAL);
		
		try {
			if(renderDelegate)
				renderDelegate();
		}
		catch(Throwable e) {
			writecln("Error in render delegate");
			writecln(e.toString);
		}
		
		try {
			igRender();
		}
		catch(Throwable e) {
			writecln("Got exception in igRender()");
		}
		
		SDL_GL_SwapWindow(_window);
	}
	
	private void limitFps() {
		static StopWatch sw = StopWatch();
		static StopWatch timeSw = StopWatch();
		enum maxFPS = 60;
		
		if(maxFPS != -1) {
			long desiredNs = 1_000_000_000 / maxFPS; // How much time the frame should take
			
			if(desiredNs - sw.peek.nsecs >= 0)
				Thread.sleep(nsecs(desiredNs - sw.peek.nsecs));
			
			sw.reset();
			sw.start();
		}
		
		time += timeSw.peek.msecs / 1000f;
		
		timeSw.reset();
		timeSw.start();
	}
	
	private uint[string] _textures;
	
	public uint getTexture(string filename) {
		if(!(filename in _textures))
			_textures[filename] = loadTexture(filename);
		
		return _textures[filename];
	}
	
	private uint loadTexture(string filename) {
		filename = "textures\\" ~ filename.replace(".tga", ".gf.png");
		
		writecln(Fg.cyan, "Loading texture ", filename);
		
		int img = ilGenImage();	
		ilBindImage(img);
		ilLoadImage(filename.toStringz);
		int width = ilGetInteger(IL_IMAGE_WIDTH), height = ilGetInteger(IL_IMAGE_HEIGHT);
		
		ubyte[] data = new ubyte[width * height * 4];
		ilCopyPixels(0, 0, 0, width, height, 1, IL_RGBA, IL_UNSIGNED_BYTE, data.ptr);
		
		ilDeleteImage(img);
		
		uint id;
		glGenTextures(1, &id);
		glBindTexture(GL_TEXTURE_2D, id);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data.ptr);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		
		return id;
	}
	
	private void setupImgui() {
		ImGuiIO* io = igGetIO();
		
		io.KeyMap[ImGuiKey_Tab] = SDLK_TAB;
		io.KeyMap[ImGuiKey_LeftArrow] = SDL_SCANCODE_LEFT;
		io.KeyMap[ImGuiKey_RightArrow] = SDL_SCANCODE_RIGHT;
		io.KeyMap[ImGuiKey_UpArrow] = SDL_SCANCODE_UP;
		io.KeyMap[ImGuiKey_DownArrow] = SDL_SCANCODE_DOWN;
		io.KeyMap[ImGuiKey_PageUp] = SDL_SCANCODE_PAGEUP;
		io.KeyMap[ImGuiKey_PageDown] = SDL_SCANCODE_PAGEDOWN;
		io.KeyMap[ImGuiKey_Home] = SDL_SCANCODE_HOME;
		io.KeyMap[ImGuiKey_End] = SDL_SCANCODE_END;
		io.KeyMap[ImGuiKey_Delete] = SDLK_DELETE;
		io.KeyMap[ImGuiKey_Backspace] = SDLK_BACKSPACE;
		io.KeyMap[ImGuiKey_Enter] = SDLK_RETURN;
		io.KeyMap[ImGuiKey_Escape] = SDLK_ESCAPE;
		io.KeyMap[ImGuiKey_A] = SDLK_a;
		io.KeyMap[ImGuiKey_C] = SDLK_c;
		io.KeyMap[ImGuiKey_V] = SDLK_v;
		io.KeyMap[ImGuiKey_X] = SDLK_x;
		io.KeyMap[ImGuiKey_Y] = SDLK_y;
		io.KeyMap[ImGuiKey_Z] = SDLK_z;
		
		io.RenderDrawListsFn = &igImplGlfwGL3_RenderDrawLists;
		igImplGlfwGL3_CreateDeviceObjects();
	}
}

/*
	ImGui support
*/

double       g_Time = 0.0f;
bool[3]      g_MousePressed;
float        g_MouseWheel = 0.0f;
GLuint       g_FontTexture = 0;
int          g_ShaderHandle = 0, g_VertHandle = 0, g_FragHandle = 0;
int          g_AttribLocationTex = 0, g_AttribLocationProjMtx = 0;
int          g_AttribLocationPosition = 0, g_AttribLocationUV = 0, g_AttribLocationColor = 0;
uint         g_VboHandle, g_VaoHandle, g_ElementsHandle;

extern(C) nothrow void igImplGlfwGL3_RenderDrawLists(ImDrawData* data)
{
	// Setup render state: alpha-blending enabled, no face culling, no depth testing, scissor enabled
	GLint last_program, last_texture;
	glGetIntegerv(GL_CURRENT_PROGRAM, &last_program);
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
	glEnable(GL_BLEND);
	glBlendEquation(GL_FUNC_ADD);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_CULL_FACE);
	glDisable(GL_DEPTH_TEST);
	glEnable(GL_SCISSOR_TEST);
	glActiveTexture(GL_TEXTURE0);
	
	auto io = igGetIO();
	// Setup orthographic projection matrix
	const float width = io.DisplaySize.x;
	const float height = io.DisplaySize.y;
	const float[4][4] ortho_projection =
	[
		[ 2.0f/width,	0.0f,			0.0f,		0.0f ],
		[ 0.0f,			2.0f/-height,	0.0f,		0.0f ],
		[ 0.0f,			0.0f,			-1.0f,		0.0f ],
		[ -1.0f,		1.0f,			0.0f,		1.0f ],
	];
	glUseProgram(g_ShaderHandle);
	glUniform1i(g_AttribLocationTex, 0);
	glUniformMatrix4fv(g_AttribLocationProjMtx, 1, GL_FALSE, &ortho_projection[0][0]);
	
	glBindVertexArray(g_VaoHandle);
	glBindBuffer(GL_ARRAY_BUFFER, g_VboHandle);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, g_ElementsHandle);
	
	foreach (n; 0..data.CmdListsCount)
	{
		ImDrawList* cmd_list = data.CmdLists[n];
		ImDrawIdx* idx_buffer_offset;
		
		auto countVertices = ImDrawList_GetVertexBufferSize(cmd_list);
		auto countIndices = ImDrawList_GetIndexBufferSize(cmd_list);
		
		glBufferData(GL_ARRAY_BUFFER, countVertices * ImDrawVert.sizeof, cast(GLvoid*)ImDrawList_GetVertexPtr(cmd_list,0), GL_STREAM_DRAW);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, countIndices * ImDrawIdx.sizeof, cast(GLvoid*)ImDrawList_GetIndexPtr(cmd_list,0), GL_STREAM_DRAW);
		
		auto cmdCnt = ImDrawList_GetCmdSize(cmd_list);
		
		foreach(i; 0..cmdCnt)
		{
			auto pcmd = ImDrawList_GetCmdPtr(cmd_list, i);
			
			if (pcmd.UserCallback)
			{
				pcmd.UserCallback(cmd_list, pcmd);
			}
			else
			{
				glBindTexture(GL_TEXTURE_2D, cast(GLuint)pcmd.TextureId);
				glScissor(cast(int)pcmd.ClipRect.x, cast(int)(height - pcmd.ClipRect.w), cast(int)(pcmd.ClipRect.z - pcmd.ClipRect.x), cast(int)(pcmd.ClipRect.w - pcmd.ClipRect.y));
				glDrawElements(GL_TRIANGLES, pcmd.ElemCount, GL_UNSIGNED_SHORT, idx_buffer_offset);
			}
			
			idx_buffer_offset += pcmd.ElemCount;
		}
	}
	
	// Restore modified state
	glBindVertexArray(0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glUseProgram(last_program);
	glDisable(GL_SCISSOR_TEST);
	glBindTexture(GL_TEXTURE_2D, last_texture);
}

void igImplGlfwGL3_CreateDeviceObjects()
{
	const GLchar *vertex_shader =
		"#version 330\n"
			"uniform mat4 ProjMtx;\n"
			"in vec2 Position;\n"
			"in vec2 UV;\n"
			"in vec4 Color;\n"
			"out vec2 Frag_UV;\n"
			"out vec4 Frag_Color;\n"
			"void main()\n"
			"{\n"
			"	Frag_UV = UV;\n"
			"	Frag_Color = Color;\n"
			"	gl_Position = ProjMtx * vec4(Position.xy,0,1);\n"
			"}\n";
	
	const GLchar* fragment_shader =
		"#version 330\n"
			"uniform sampler2D Texture;\n"
			"in vec2 Frag_UV;\n"
			"in vec4 Frag_Color;\n"
			"out vec4 Out_Color;\n"
			"void main()\n"
			"{\n"
			"	Out_Color = Frag_Color * texture( Texture, Frag_UV.st);\n"
			"}\n";
	
	g_ShaderHandle = glCreateProgram();
	g_VertHandle = glCreateShader(GL_VERTEX_SHADER);
	g_FragHandle = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(g_VertHandle, 1, &vertex_shader, null);
	glShaderSource(g_FragHandle, 1, &fragment_shader, null);
	glCompileShader(g_VertHandle);
	glCompileShader(g_FragHandle);
	glAttachShader(g_ShaderHandle, g_VertHandle);
	glAttachShader(g_ShaderHandle, g_FragHandle);
	glLinkProgram(g_ShaderHandle);
	
	g_AttribLocationTex = glGetUniformLocation(g_ShaderHandle, "Texture");
	g_AttribLocationProjMtx = glGetUniformLocation(g_ShaderHandle, "ProjMtx");
	g_AttribLocationPosition = glGetAttribLocation(g_ShaderHandle, "Position");
	g_AttribLocationUV = glGetAttribLocation(g_ShaderHandle, "UV");
	g_AttribLocationColor = glGetAttribLocation(g_ShaderHandle, "Color");
	
	glGenBuffers(1, &g_VboHandle);
	glGenBuffers(1, &g_ElementsHandle);
	
	glGenVertexArrays(1, &g_VaoHandle);
	glBindVertexArray(g_VaoHandle);
	glBindBuffer(GL_ARRAY_BUFFER, g_VboHandle);
	glEnableVertexAttribArray(g_AttribLocationPosition);
	glEnableVertexAttribArray(g_AttribLocationUV);
	glEnableVertexAttribArray(g_AttribLocationColor);
	
	glVertexAttribPointer(g_AttribLocationPosition, 2, GL_FLOAT, GL_FALSE, ImDrawVert.sizeof, cast(void*)0);
	glVertexAttribPointer(g_AttribLocationUV, 2, GL_FLOAT, GL_FALSE, ImDrawVert.sizeof, cast(void*)ImDrawVert.uv.offsetof);
	glVertexAttribPointer(g_AttribLocationColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, ImDrawVert.sizeof, cast(void*)ImDrawVert.col.offsetof);
	
	glBindVertexArray(0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	igImplGlfwGL3_CreateFontsTexture();
}

void igImplGlfwGL3_CreateFontsTexture()
{
	ImGuiIO* io = igGetIO();
	
	ubyte* pixels;
	int width, height;
	ImFontAtlas_GetTexDataAsRGBA32(io.Fonts,&pixels,&width,&height,null);
	
	glGenTextures(1, &g_FontTexture);
	glBindTexture(GL_TEXTURE_2D, g_FontTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
	
	// Store our identifier
	ImFontAtlas_SetTexID(io.Fonts, cast(void*)g_FontTexture);
}

void drawCube(vec3f min, vec3f max) {
	vec3f diff = max - min;
	
	glBegin(GL_QUADS);
	
	glVertex3f(min.x, min.y, min.z);
	glVertex3f(min.x + diff.x, min.y, min.z);
	glVertex3f(min.x + diff.x, min.y, min.z + diff.z);
	glVertex3f(min.x, min.y, min.z + diff.z);
	
	glVertex3f(min.x, min.y + diff.y, min.z);
	glVertex3f(min.x + diff.x, min.y + diff.y, min.z);
	glVertex3f(min.x + diff.x, min.y + diff.y, min.z + diff.z);
	glVertex3f(min.x, min.y + diff.y, min.z + diff.z);
	
	glVertex3f(min.x, min.y, min.z);
	glVertex3f(min.x, min.y + diff.y, min.z);
	glVertex3f(min.x, min.y + diff.y, min.z + diff.z);
	glVertex3f(min.x, min.y, min.z + diff.z);
	
	glVertex3f(min.x + diff.x, min.y, min.z);
	glVertex3f(min.x + diff.x, min.y + diff.y, min.z);
	glVertex3f(min.x + diff.x, min.y + diff.y, min.z + diff.z);
	glVertex3f(min.x + diff.x, min.y, min.z + diff.z);
	
	glVertex3f(min.x, min.y, min.z);
	glVertex3f(min.x + diff.x, min.y, min.z);
	glVertex3f(min.x + diff.x, min.y + diff.y, min.z);
	glVertex3f(min.x, min.y + diff.y, min.z);
	
	glVertex3f(min.x, min.y, min.z + diff.z);
	glVertex3f(min.x + diff.x, min.y, min.z + diff.z);
	glVertex3f(min.x + diff.x, min.y + diff.y, min.z + diff.z);
	glVertex3f(min.x, min.y + diff.y, min.z + diff.z);
	
	glEnd();
}