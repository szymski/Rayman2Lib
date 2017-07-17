module dllmain;

version(dll):

import core.runtime, core.thread;
import std.stdio;
import std.string;
import core.sys.windows.windows;

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

			writeln("Dll injected");
			currentModule = hInstance;

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
	AllocConsole();
	stdout.windowsHandleOpen(GetStdHandle(STD_OUTPUT_HANDLE), "w");
	stderr.windowsHandleOpen(GetStdHandle(STD_ERROR_HANDLE), "w");

	import core.stdc.signal;

	alias signalfn = extern(C) void function(int) nothrow @nogc @system;

	signal(SIGSEGV, cast(signalfn)&signalHandler);

//	writeln("Sleeping");
//	Thread.sleep(msecs(15000)); 
//	writeln("Resuming");

	import handlers.rendering;

	try {
		graphics([]);
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