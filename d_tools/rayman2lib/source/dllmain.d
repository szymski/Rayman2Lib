module dllmain;

version(dll):

import core.runtime;
import std.c.stdio;
import std.c.stdlib;
import std.string;
import core.sys.windows.windows;

HINSTANCE g_hInst;

extern (C)
{
	void gc_setProxy(void* p);
	void gc_clrProxy();
}

extern (Windows) BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved)
{
	switch (ulReason)
	{
		case DLL_PROCESS_ATTACH:
			Runtime.initialize();
			onAttach();
			break;
			
		case DLL_PROCESS_DETACH:
			Runtime.terminate();
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

void onAttach() {
	
}