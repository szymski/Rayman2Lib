import std.stdio;

version(exe) void main(string[] args)
{
	debug args ~= "levelviewer"; // Use this to run a handler in debug mode

	// Print usage instruction, if no parameter given
	if(args.length <= 1) {
		writeln("Usage: ", args[0], " option");

		writeln("Available options:");
		foreach(key, value; handlers)
			writeln("\t", key);

		return;
	}

	// Make segmentation faults throw
	import core.stdc.signal;
	alias signalfn = extern(C) void function(int) nothrow @nogc @system;
	signal(SIGSEGV, cast(signalfn)&signalHandler);

	try {
		// Handle the given option
		if(auto handleFunc = args[1] in handlers)
			(*handleFunc)(args[2 .. $]);
		else
			writeln("No such option");
	}
	catch(Throwable e) {
		writeln(e.msg);
	}
}

version(exe)
	extern(C)
	@system void signalHandler(int signal) {
		throw new Exception("Access violation");
	}


/*
	Handler registering.
*/

enum handler;

void function(string[])[string] handlers;

/**
	Registers functions with @handler attribute, so they can be run by a command.
*/
mixin template registerHandlers(string moduleName = __MODULE__) {
	static this() {
		import std.traits;

		mixin("import thisModule = " ~ moduleName ~ ";");

		foreach(member; __traits(allMembers, thisModule)) {
			static if(isSomeFunction!(mixin(member)) && hasUDA!(mixin(member), handler)) 
				mixin("app.handlers[`" ~ member ~ "`] = &" ~ member ~ ";");
		}
	}
}