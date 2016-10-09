module handlers.cnt;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, global, utils, structures.sector;

mixin registerHandlers;

/*
	Unpacks CNT archive into a folder.
*/

@handler
void unpackcnt(string[] args) {
	debug {
		args ~= r"Textures.cnt";
		args ~= "-png";
		args ~= "-r2";
	}
	
	if(args.length == 0) {
		writecln(Fg.white, "Usage: unpackcnt filename [outputfolder] [-png] [-r2] [-r3] ", Fg.initial);
		return;
	}
	
	GFType type = GFType.rayman2;
	if(args.canFind("-r3"))
		type = GFType.rayman3;
	
	string cntFilename = args[0];
	bool toPng = args.canFind("-png");
	
	CNTFormat cnt = new CNTFormat(cntFilename);
	
	string outputDir = (args.length == 2 && !args[1].startsWith("-")) ? args[1] ~ "/" : baseName(cntFilename) ~ ".extracted/";
	
	foreach(file; cnt.fileList) {
		mkdirRecurse(outputDir ~ file.directory);
		if(!toPng)
			std.file.write(outputDir ~ file.directory ~ "/" ~ file.name, file.data);
		else
			new GFFormat(file.data, type).saveToPng(outputDir ~ file.directory ~ "/" ~ file.name ~ ".png");
	}
}

/*
	Creates CNT archive from a folder.
*/

@handler
void packcnt(string[] args) {
	debug {
		args ~= r"TexturesHD.cnt.extracted";
	}
	
	if(args.length == 0) {
		writecln(Fg.white, "Usage: packcnt folder [outputname] [-r2] [-r2vignette] [-r3] [-r3vignette]", Fg.initial);
		return;
	}
	
	if(!exists(args[0]) || !isDir(args[0])) {
		writecln(Fg.red, "No such directory", Fg.initial);
		return;
	}
	
	CNTVersion type = CNTVersion.rayman2;
	if(args.canFind("-r2vignette"))
		type = CNTVersion.rayman2Vignette;
	if(args.canFind("-r3"))
		type = CNTVersion.rayman3;
	if(args.canFind("-r3vignette"))
		type = CNTVersion.rayman3Vignette;
	
	GFType gfType = GFType.rayman2;
	if(type == CNTVersion.rayman3)
		gfType = GFType.rayman3;
	
	string outputName = (args.length >= 2 && !args[1].startsWith("-")) ? args[1] : baseName(args[0]).replace(".extracted", "");
	
	CNTFile[] cntFileList;
	
	foreach(name; dirEntries(args[0], SpanMode.depth)) {
		if(!name.isDir && name.extension == ".png") { // TODO: Add support for pure GF files
			writecln(Fg.white, "Converting ", name);
			
			IFImage image = read_png(name, ColFmt.RGBA);
			
			GFFormat gf = new GFFormat(gfType);
			gf.width = image.w;
			gf.height = image.h;
			gf.pixels = cast(uint[])image.pixels;
			gf.build();
			
			CNTFile cntFile = new CNTFile();
			cntFile.directory = relativePath(dirName(absolutePath(name)), absolutePath(args[0]));
			cntFile.name = baseName(name).replace(".png", "");
			cntFile.data = gf.data;
			
			cntFileList ~= cntFile;
		}
	}
	
	writecln(Fg.white, "Packing into ", outputName);
	
	CNTFormat cnt = new CNTFormat();
	cnt.archiveVersion = CNTVersion.rayman3;
	foreach(cntFile; cntFileList)
		cnt.fileList ~= cntFile;
	
	cnt.build();
	
	std.file.write(outputName, cnt.data);
	writecln(Fg.lightMagenta, "Done!", Fg.initial);
}

/*
	Transforms GF files into png.
*/

@handler
void gftopng(string[] args) {
	debug {
		args ~= r"r2demo_vignette";
		args ~= r"-r2";
	}
	
	if(args.length == 0) {
		writecln(Fg.white, "Usage: gftopng folder [outputfolder] [-r2] [-r2ios] [-r3]", Fg.initial);
		return;
	}
	
	if(!exists(args[0]) || !isDir(args[0])) {
		writecln(Fg.red, "No such directory", Fg.initial);
		return;
	}
	
	GFType type = GFType.rayman2;
	if(args.canFind("-r2ios"))
		type = GFType.rayman2ios;
	if(args.canFind("-r3"))
		type = GFType.rayman3;
	
	string outputDir = (args.length >= 2 && !args[1].startsWith("-")) ? args[1] : args[0] ~ ".png";
	
	mkdirRecurse(outputDir);
	
	foreach(name; dirEntries(args[0], SpanMode.depth)) {
		if(!name.isDir && name.extension.toLower == ".gf") {
			mkdirRecurse(outputDir ~ "/" ~ dirName(relativePath(absolutePath(name), absolutePath(args[0]))));
			new GFFormat(name, type).saveToPng(outputDir ~ "/" ~ relativePath(absolutePath(name), absolutePath(args[0])) ~ ".png");
		}
	}
}