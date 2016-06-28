module global;

import snaformat;

SNAFormat[] loadedSnas;

struct PointerRelocationInfo { ubyte byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7; }

uint pointerRelocationInfoIndex = 0;
PointerRelocationInfo[10240] relocationKeyValues; 
uint[256] gptPointerRelocation;