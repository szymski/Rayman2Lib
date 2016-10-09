module formats.cnt;

import std.stdio, std.string, std.conv, std.algorithm, std.path, consoled;
import std.file : read;
import std.path : baseName;
import utils, global;

enum CNTVersion { rayman2, rayman2Vignette, rayman3, rayman3Vignette, unknown }

/**
	This class represents CNT archive.
*/
class CNTFormat {

	string name = "Unknown";
	ubyte[] data;
	MemoryReader reader;

	uint directoryCount;
	uint fileCount;
	ushort signature;
	ubyte xorKey;
	CNTVersion archiveVersion;

	string[] directoryList;
	CNTFile[] fileList;

	/**
		Constructs an empty CNT archive. It can be built, using this.build function.
	*/
	this()
	{
	}

	/**
		Parses a CNT file.
	*/
	this(string filename)
	{
		name = baseName(filename);
		this(cast(ubyte[])read(filename));
	}

	/**
		Parses a CNT file.
	*/
	this(ubyte[] data)
	{
		writecln(Fg.lightMagenta, "Reading CNT");
		this.data = data;
		parse();
	}

	private void parse() {
		reader = new MemoryReader(data);

		directoryCount = reader.read!uint;
		fileCount = reader.read!uint;
		signature = reader.read!ushort;
		xorKey = reader.read!ubyte;

		assert(signature == 257, "This isn't a valid CNT archive!");

		writecln(Fg.lightGreen, "Found ", Fg.white, directoryCount, Fg.lightGreen, " directories with ", Fg.white, fileCount, Fg.lightGreen, " files");

		foreach(i; 0 ..directoryCount)
			readDirectory();

		readVersion();

		foreach(i; 0 .. fileCount)
			readFile();
	}

	private void readDirectory() {
		string name = readXorredString();
		directoryList ~= name;
		debug writecln(Fg.white, "Directory: ", name);
	}

	private void readVersion() {
		switch(reader.read!ubyte) {
			case 246:
				archiveVersion = CNTVersion.rayman2;
				break;

			case 197:
				archiveVersion = CNTVersion.rayman3;
				break;

			case 71:
				archiveVersion = CNTVersion.rayman3Vignette;
				break;
			
			default:
				archiveVersion = CNTVersion.rayman2Vignette;
				break;
		}
	}

	private void readFile() {
		auto directoryIndex = reader.read!int;
		auto name = readXorredString();
		auto xorSequence = reader.read!(ubyte[4]);
		auto unknown = reader.read!uint;
		auto pointer = reader.read!uint;
		auto size = reader.read!uint;

		foreach(i; 0 .. size)
			if((size % 4) + i < size)
			data[pointer + i] ^= xorSequence[i % 4];

		CNTFile file = new CNTFile;
		file.cntArchive = this;
		file.directory = directoryIndex != -1 ? directoryList[directoryIndex] : "";
		file.name = name;
		file.pointer = pointer;
		file.size = size;
		file.xorSequence = xorSequence;

		fileList ~= file;

		debug writecln(Fg.white, "File: ", name);
	}

	private string readXorredString() {
		auto strLength = reader.read!uint;
		
		char[] str;
		str.reserve(strLength);
		
		foreach(i; 0 .. strLength)
			str ~= reader.read!char ^ xorKey;
		
		return str.idup;
	}

	/**
		Builds a new CNT archive. The output is stored into this.data.
	*/
	void build() {
		buildDirectoryList();
	
		signature = 257;
		fileCount = fileList.length;
		directoryCount = directoryList.length;
		xorKey = 0x4;

		MemoryWriter writer = new MemoryWriter(fileList.map!"a.data.length".reduce!"a + b" + 2024);

		writer.write(directoryCount);
		writer.write(fileCount);
		writer.write(signature);
		writer.write(xorKey);

		foreach(dir; directoryList) {
			writer.write(dir.length);
			writer.write(xorred(dir.dup, xorKey));
		}

		switch(archiveVersion) {
			case CNTVersion.rayman2:
				writer.write(cast(ubyte)246);
				break;

			case CNTVersion.rayman3:
				writer.write(cast(ubyte)197);
				break;
				
			case CNTVersion.rayman3Vignette:
				writer.write(cast(ubyte)246);
				break;
				
			default:
				writer.write(cast(ubyte)0);
				break;
		}

		foreach(file; fileList) {
			writer.write((file.directory == "." || file.directory == "") ? -1 : directoryList.countUntil!(d => d == file.directory));
			writer.write(file.name.length);
			writer.write(xorred(file.name.dup, xorKey));
			writer.write(file.xorSequence);
			writer.write(0);
			file.pointer = writer.position; // Use temporary to save location, where to save pointer later
			writer.write(0xFFFFFFFF);
			writer.write(file.data.length);
		}

		foreach(file; fileList) {
			uint position = writer.position;
			writer.position = file.pointer;
			writer.write(position);
			writer.position = position;
			writer.write(xorred(file.data, 0)); // TODO: Xor sequence support
		}

		data = writer.data;
	}

	private void buildDirectoryList() {
		foreach(file; fileList) {
			if(!directoryList.canFind(file.directory) && file.directory != ".")
				directoryList ~= file.directory;
			if(!directoryList.canFind(dirName(file.directory)) && dirName(file.directory) != ".")
				directoryList ~= dirName(file.directory);
		}
	}
}

/**
	This class represents a single file from CNT archive.
*/
class CNTFile {
	CNTFormat cntArchive;
	string directory;
	string name;
	uint pointer;
	uint size;
	ubyte[4] xorSequence;
	
	private ubyte[] newData;
	
	ubyte[] data() {
		if(cntArchive !is null)
			return cntArchive.data[pointer .. pointer + size];
		else
			return newData;
	}

	void data(ubyte[] newData) {
		this.newData = newData;
	}
}

private T[] xorred(T)(in T[] arr, ubyte key) {
	T[] xorred;
	xorred.length = arr.length;
	
	foreach(i; 0 .. arr.length)
		xorred[i] = arr[i] ^ key;
	
	return xorred;
}