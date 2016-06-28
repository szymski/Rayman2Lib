import std.stdio, std.file;
import decoder, snaformat, gptformat, global, levels0format;

void main()
{
	readRelocationTable(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT");
	SNAFormat snaFormat = new SNAFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.sna");
	GPTFormat gptFormat = new GPTFormat(r"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Fix.gpt");
}
