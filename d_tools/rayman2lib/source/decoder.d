module decoder;

enum uint firstMagicNumber = 1790299257;

/**
	Decodes/encodes data with Rayman 2 algorithm.
*/
ubyte[] decodeData(in ubyte[] data, uint magicNumber = firstMagicNumber) {
	ubyte[] decoded = data.dup;

	foreach(i; 4 .. decoded.length) { // We skip first 4 bytes
		decoded[i] = decodeByte(decoded[i], magicNumber);
		magicNumber = getNextMagic(magicNumber);
	}

	return decoded;
}

/**
	Generates next magic value for decoding/encoding.
*/
uint getNextMagic(uint currentMagic) {
	return cast(uint)(16807 * (currentMagic ^ 0x75BD924) - 0x7FFFFFFF * ((currentMagic ^ 0x75BD924) / 0x1F31D));
}

/**
	Decodes/encodes one byte with specified magic value.
*/
ubyte decodeByte(ubyte toDecode, uint magic) {
	return toDecode ^ ((magic >> 8) & 0xFF);
}