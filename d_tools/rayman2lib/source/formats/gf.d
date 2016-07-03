module formats.gf;

import std.stdio, std.string, std.conv, std.algorithm, consoled;
import std.file : read;
import std.path : baseName;
import utils, global;
import imageformats;

enum GFType { rayman2, rayman3 };

class GFFormat {

	string name = "Unknown";
	ubyte[] data;
	MemoryReader reader;
	
	uint signature;
	uint width;
	uint height;
	ubyte channelCount;
	ubyte repeatByte;
	bool transparent;
	
	uint[] pixels;

	GFType type;

	this(GFType type = GFType.rayman2)
	{
		this.type = type;
	}

	this(string filename, GFType type = GFType.rayman2)
	{
		this.type = type;
		name = baseName(filename);
		this(cast(ubyte[])read(filename));
	}
	
	this(ubyte[] data, GFType type = GFType.rayman2)
	{
		this.type = type;
		writecln(Fg.lightMagenta, "Reading GF");
		this.data = data;
		parse();
	}
	
	void parse() {
		reader = new MemoryReader(data);
		
		signature = reader.read!uint;
		width = reader.read!uint;
		height = reader.read!uint;
		channelCount = reader.read!ubyte;

		if(type == GFType.rayman3) {
			ubyte enlargeByte = reader.read!ubyte;

			uint w = width, h = height;

			foreach(i; 1 .. enlargeByte) {
				w /= 2;
				h /= 2;
				width += w;
				height += h;
			}
		}

		repeatByte = reader.read!ubyte;

		writeln(width, " ", height);

		transparent = channelCount == 4;
		
		ubyte[] blueChannel = readChannel();
		ubyte[] greenChannel = readChannel();
		ubyte[] redChannel = readChannel();
		ubyte[] alphaChannel;
		if(transparent)
			alphaChannel = readChannel();
		
		pixels.length = width * height;
		
		foreach(i; 0 .. width * height) {
			pixels[i] = redChannel[i];
			pixels[i] |= greenChannel[i] << 8;
			pixels[i] |= blueChannel[i] << 16;
			pixels[i] |= (transparent ? alphaChannel[i] : 0xFF) << 24;
		}
		
		foreach(y; 0 .. height / 2) {
			foreach(x; 0 .. width) {
				uint temp = pixels[y * width + x];
				pixels[y * width + x] = pixels[(height - 1 - y) * width + x];
				pixels[(height - 1 - y) * width + x] = temp;
			}
		}
	}
	
	ubyte[] readChannel() {
		ubyte[] channel;
		channel.length = width * height;

		int pixels = width * height;
		int pixel = 0;

		while (pixel < pixels)
		{
			//writeln(pixel, " - ", pixels);
			ubyte b1 = reader.read!ubyte;
			if (b1 == repeatByte)
			{
				ubyte b2 = reader.read!ubyte;
				ubyte b3 = reader.read!ubyte;
				
				for (uint i = 0; i < b3; ++i)
				{
					if(pixel < pixels)
						channel[pixel] = b2;
					pixel++;
				}
			}
			else
			{
				channel[pixel] = b1;
				pixel++;
			}
		}

		return channel;
	}
	
	void saveToPng(string filename) {
		write_png(filename, width, height, cast(ubyte[])pixels); 
	}

	void build() {
		assert(width != 0, "Width isn't set.");
		assert(height != 0, "Height isn't set.");
		assert(pixels.length == width * height, "Invalid pixels size or pixels not provided.");

		transparent = true;

		signature = transparent ? 8888 : 888;
		channelCount = 4;
		repeatByte = 1;

		uint channelSize = width * height;

		foreach(y; 0 .. height / 2) {
			foreach(x; 0 .. width) {
				uint temp = pixels[y * width + x];
				pixels[y * width + x] = pixels[(height - 1 - y) * width + x];
				pixels[(height - 1 - y) * width + x] = temp;
			}
		}

		ubyte[] blueChannel;
		ubyte[] greenChannel;
		ubyte[] redChannel;
		ubyte[] alphaChannel;

		blueChannel.length = channelSize;
		greenChannel.length = channelSize;
		redChannel.length = channelSize;
		alphaChannel.length = channelSize;

		foreach(i; 0 .. channelSize) {
			redChannel[i] = pixels[i] & 0xFF;
			greenChannel[i] = (pixels[i] >> 8) & 0xFF;
			blueChannel[i] = (pixels[i] >> 16) & 0xFF;
			alphaChannel[i] = (pixels[i] >> 24) & 0xFF;

			// Get rid of all 1s, RLE isn't yet supported
			if(redChannel[i] == 1) redChannel[i] = 0;
			if(greenChannel[i] == 1) greenChannel[i] = 0;
			if(blueChannel[i] == 1) blueChannel[i] = 0;
			if(alphaChannel[i] == 1) alphaChannel[i] = 0;
		}

		MemoryWriter writer = new MemoryWriter(width * height * 4 + 1024);

		writer.write(signature);
		writer.write(width);
		writer.write(height);
		writer.write(channelCount);
		writer.write(repeatByte);

		writer.write(blueChannel);
		writer.write(greenChannel);
		writer.write(redChannel);
		writer.write(alphaChannel);

		data = writer.data;
	}
}