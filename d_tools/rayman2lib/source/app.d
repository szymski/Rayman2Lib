import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string;
import decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, global, utils, structures.sector;
import consoled, imageformats;

void main(string[] args)
{
	debug {
		args ~= "gpt";
	}

	if(args.length <= 1) {
		writeln("Usage: ", args[0], " option");

		writeln("Available options:");
		foreach(key, value; handlers)
			writeln("\t", key);

		return;
	}

	if(auto handleFunc = args[1] in handlers)
		(*handleFunc)(args[2 .. $]);
	else
		writeln("No such option");
}

/*
	Handler registering.
*/

struct handler;

void function(string[])[string] handlers;

/**
	Registers functions with @handler attribute, so then can be ran by a command.
*/
mixin template registerHandlers(string moduleName = __MODULE__) {
	static this() {
		import std.traits;

		mixin("import thisModule = " ~ moduleName ~ ";");

		foreach(member; __traits(allMembers, thisModule))
			static if(isSomeFunction!(mixin(member)) && hasUDA!(mixin(member), handler)) 
				mixin("app.handlers[member] = &" ~ member ~ ";");
	}
}