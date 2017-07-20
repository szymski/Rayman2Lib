module detours;

import std.traits, core.sys.windows.windows;

pragma(lib, "detours");

extern(Windows) {
	
	struct _DETOUR_TRAMPOLINE
	{
		BYTE[23] rbCode;
		BYTE cbTarget;
		PBYTE pbRemain;
		PBYTE pbDetour;
	};
	
	alias PDETOUR_TRAMPOLINE = _DETOUR_TRAMPOLINE*;
	alias PDETOUR_BINARY = VOID*;
	
	LONG DetourTransactionBegin();
	LONG DetourTransactionAbort();
	LONG DetourTransactionCommit();
	
	LONG DetourUpdateThread(HANDLE hThread);
	
	LONG DetourAttach(PVOID* ppPointer, PVOID pDetour);
	LONG DetourAttachEx(PVOID* ppPointer, PVOID pDetour, PDETOUR_TRAMPOLINE* ppRealTrampoline, PVOID* ppRealTarget, PVOID* ppRealDetour);
	
	LONG DetourDetach(PVOID* ppPointer, PVOID pDetour);
	
	VOID DetourSetIgnoreTooSmall(BOOL fIgnore);
	
	BOOL DetourRestoreAfterWith();
}

uint DetourAttach(T1, T2)(T1 ppPointer, T2 pDetour) {
	static assert(isPointer!T1, "First parameter must be a pointer to function pointer.");
	static assert(isFunctionPointer!T2, "Second parameter must be function pointer.");
	
	return DetourAttach(cast(PVOID*)ppPointer, cast(PVOID)pDetour);
}