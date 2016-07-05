module formats.gf;

import std.stdio, std.string, std.conv, std.algorithm, consoled;
import std.file : read;
import std.path : baseName;
import utils, global;
import imageformats;

enum GFType { rayman2, rayman2ios, rayman3 };

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
		name = baseName(filename);
		this(cast(ubyte[])read(filename), type);
	}
	
	this(ubyte[] data, GFType type = GFType.rayman2)
	{
		this.type = type;
		writecln(Fg.lightMagenta, "Reading ", type, " GF");
		this.data = data;
		parse();
	}
	
	void parse() {
		reader = new MemoryReader(data);

		if(type != GFType.rayman2ios) 
			signature = reader.read!uint;
		width = reader.read!uint;
		height = reader.read!uint;
		channelCount = reader.read!ubyte;


		// TODO: Fix Rayman 3 texture unpacking
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

		transparent = false;

		uint channelSize = width * height;

		//Determine if transparent
		foreach(i; 0 .. channelSize) {
			if(((pixels[i] >> 24) & 0xFF) < 0xFF) {
				transparent = true;
				break;
			}
		}

		signature = transparent ? 8888 : 888;
		channelCount = transparent ? 4 : 3;
		repeatByte = 1;

		foreach(y; 0 .. height / 2) {
			foreach(x; 0 .. width) {
				uint temp = pixels[y * width + x];
				pixels[y * width + x] = pixels[(height - 1 - y) * width + x];
				pixels[(height - 1 - y) * width + x] = temp;
			}
		}

		ubyte[] tempBlueChannel;
		ubyte[] tempGreenChannel;
		ubyte[] tempRedChannel;
		ubyte[] tempAlphaChannel;

		tempBlueChannel.length = channelSize;
		tempGreenChannel.length = channelSize;
		tempRedChannel.length = channelSize;
		tempAlphaChannel.length = channelSize;

		foreach(i; 0 .. channelSize) {
			tempRedChannel[i] = pixels[i] & 0xFF;
			tempGreenChannel[i] = (pixels[i] >> 8) & 0xFF;
			tempBlueChannel[i] = (pixels[i] >> 16) & 0xFF;
			tempAlphaChannel[i] = (pixels[i] >> 24) & 0xFF;

			// Get rid of all 1s, RLE isn't yet supported
			//if(redChannel[i] == 1) redChannel[i] = 0;
			//if(greenChannel[i] == 1) greenChannel[i] = 0;
			//if(blueChannel[i] == 1) blueChannel[i] = 0;
			//if(alphaChannel[i] == 1) alphaChannel[i] = 0;
		}

		debug writecln(Fg.lightGreen, "Compressing GF");
		
		ubyte[] blueChannel = compressChannel(tempBlueChannel);
		ubyte[] greenChannel = compressChannel(tempGreenChannel);
		ubyte[] redChannel = compressChannel(tempRedChannel);
		ubyte[] alphaChannel = compressChannel(tempAlphaChannel);

		MemoryWriter writer = new MemoryWriter(width * height * 4 + 1024);

		writer.write(signature);
		writer.write(width);
		writer.write(height);
		writer.write(channelCount);
		writer.write(repeatByte);

		writer.write(blueChannel);
		writer.write(greenChannel);
		writer.write(redChannel);
		if(transparent)
			writer.write(alphaChannel);

		data = writer.data;
	}

	private ubyte[] compressChannel(ubyte[] channel) {
		ubyte[] compressedData;

		uint pixel = 0;

		while(pixel < channel.length) {
			ubyte color = channel[pixel];

			pixel++;

			if(pixel >= channel.length) {
				compressedData ~= color == repeatByte ? 0 : color;
				break;
			}

			for(ubyte i = 1; i < 255; i++) {
				if(i == 254 || pixel >= channel.length - 1 || (i > 1 && (channel[pixel] != color))) {
					compressedData ~= repeatByte;
					compressedData ~= color;
					compressedData ~= i;
					compressedData ~= channel[pixel] == repeatByte ? 0 : channel[pixel];
					pixel++;
					break;
				}
				if(i == 1 && channel[pixel] != color) {
					compressedData ~= color == repeatByte ? 0 : color;
					compressedData ~= channel[pixel] == repeatByte ? 0 : channel[pixel];
					pixel++;
					break;
				}

				pixel++;
			}
		}

		return compressedData;
	}
}