module decoder;

enum uint firstMagicNumber = 1790299257;

ubyte[] decodeData(ubyte[] data, uint magicNumber = firstMagicNumber) {
	ubyte[] decoded = data.dup;

	foreach(i; 4 .. decoded.length) {
		decoded[i] = decodeByte(decoded[i], magicNumber);
		magicNumber = getNextMagic(magicNumber);
	}

	return decoded;
}

uint getNextMagic(uint currentMagic) {
	return cast(uint)(16807 * (currentMagic ^ 0x75BD924) - 0x7FFFFFFF * ((currentMagic ^ 0x75BD924) / 0x1F31D));
}

ubyte decodeByte(ubyte toDecode, uint magic) {
	return toDecode ^ ((magic >> 8) & 0xFF);
}