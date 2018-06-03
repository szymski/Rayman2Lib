module dllmain;

version(dll):

import core.runtime, core.thread;
import std.stdio;
import std.string;
import core.sys.windows.windows;
import core.sys.windows.winnt;
import core.sys.windows.dbghelp;
import core.stdc.signal;
import detours;
import structures.superobject;

pragma(lib, "detours");

HINSTANCE g_hInst;

extern (C)
{
	void gc_setProxy(void* p);
	void gc_clrProxy();
}

__gshared HINSTANCE currentModule;

extern (Windows) BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved)
{
	switch (ulReason)
	{
		case DLL_PROCESS_ATTACH:
			Runtime.initialize();

			currentModule = hInstance;

			AllocConsole();
			stdout.windowsHandleOpen(GetStdHandle(STD_OUTPUT_HANDLE), "w");
			stderr.windowsHandleOpen(GetStdHandle(STD_ERROR_HANDLE), "w");

			writeln("Dll injected");

			detourFunctions();

			try {
				new Thread({
					onAttach();
				}).start();
			}
			catch(Throwable e) {
				writeln(e.toString());
			}

			break;
			
		case DLL_PROCESS_DETACH:
			break;
			
		case DLL_THREAD_ATTACH:
			return false;
			
		case DLL_THREAD_DETACH:
			return false;
			
		default:
	}
	g_hInst = hInstance;
	return true;
}

extern(C)
@system void signalHandler(int signal) {
	throw new Exception("Access violation");
}

void onAttach() {
	alias signalfn = extern(C) void function(int) nothrow @nogc @system;

	signal(SIGSEGV, cast(signalfn)&signalHandler);

//	writeln("Sleeping");
//	Thread.sleep(msecs(15000)); 
//	writeln("Resuming");

	import handlers.levelviewer;

	try {
		levelviewer([]);
	}
	catch(Throwable e) {
		writeln("Got exception");
		writeln(e.toString());
	}

	writeln("Freeing library");

	//FreeLibrary(currentModule);
	Runtime.unloadLibrary(currentModule);
	Runtime.terminate();
	FreeLibrary(currentModule);
}

__gshared extern(C):

auto DrawFrame = cast(char function())0x401160;
auto fn_p_stBooleanCondition = cast(tdstNodeInterpret* function(SuperObject* superObject, tdstNodeInterpret* node, tdstGetSetParam* getSetParam))0x489B40;

void detourFunctions() {
	writeln("Detouring functions...");

	DetourRestoreAfterWith();
	DetourTransactionBegin();
	DetourUpdateThread(GetCurrentThread());
	
	DetourAttach(&DrawFrame, &NEW_DrawFrame);
	DetourAttach(&fn_p_stBooleanCondition, &NEW_fn_p_stBooleanCondition);
	
	DetourTransactionCommit();

	writeln("Functions detoured");
}

bool canUpdateEngine = true;
bool engineUpdating = false;
bool engineUpdated = false;
bool pauseEngine = false;

char NEW_DrawFrame() {
	char result = 0;

	if(!canUpdateEngine)
		return 0;

	engineUpdating = true;
	if(!pauseEngine)
		result = DrawFrame();

	engineUpdating = false;
	canUpdateEngine = false;

	return result;
}

bool[SuperObject*] forceTrueConditionSuperObjects;

import std.random;

tdstNodeInterpret* NEW_fn_p_stBooleanCondition(SuperObject* superObject, tdstNodeInterpret* node, tdstGetSetParam* getSetParam)
{
	tdstNodeInterpret* result = fn_p_stBooleanCondition(superObject, node, getSetParam);
	if(superObject in forceTrueConditionSuperObjects && forceTrueConditionSuperObjects[superObject])
		getSetParam.conditionByte = uniform(0, 2);
	return result;
}