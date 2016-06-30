module global;

import formats.sna;

SNAFormat[] loadedSnas;

struct PointerRelocationInfo { uint dword0; ubyte byte4, byte5, byte6, byte7; }

uint pointerRelocationInfoIndex = 0;
PointerRelocationInfo[10240] relocationKeyValues; 
uint[1024] gptPointerRelocation;