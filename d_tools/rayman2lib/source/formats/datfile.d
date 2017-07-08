module formats.datfile;

import std.stdio, std.file, std.path, std.algorithm, std.traits, std.array, std.conv, std.string, consoled, imageformats, std.math;
import app, decoder, formats.pointertable, formats.relocationtable, formats.sna, formats.cnt, formats.gf, global, utils, structures.superobject;

struct DATHeader {
	int field_0;
	int field_4;
	int field_8;
	int field_C;
}

uint getOffsetInBigFile(File f, ref uint tableToLoad) {
	f.seek(0);

	DATHeader header = f.readType!DATHeader;
	int number;
	f.readTo(&number, 4);
	header.field_0 += header.field_8;
	header.field_4 += header.field_C;
	f.readTo(&number, 4);
	uint levels0DatValue_0 = header.field_4 ^ (number - header.field_0);
	header.field_0 += header.field_8;
	header.field_4 += header.field_C;
	f.readTo(&number, 4);
	uint levels0DatValue_1 = (header.field_4 ^ cast(uint)(number - header.field_0)) >> 2;
	header.field_0 += header.field_8;
	header.field_4 += header.field_C;
	f.readTo(&number, 4);
	header.field_0 += header.field_8;
	header.field_4 += header.field_C;
	f.readTo(&number, 4);
	int v4 = header.field_4 ^ (number - header.field_0);
	header.field_0 += header.field_8;
	header.field_4 += header.field_C;
	uint levels0DatValue_2 = v4;
	f.readTo(&number, 4);
	int v5 = header.field_4 ^ (number - header.field_0);
	header.field_0 += header.field_8;
	uint levels0DatValue_3 = v5;
	header.field_4 += header.field_C;
	f.readTo(&number, 4);
	int v6 = header.field_4 ^ (number - header.field_0);
	header.field_0 += header.field_8;
	header.field_4 += header.field_C;
	uint levels0DatValue_4 = v6;
	f.readTo(&number, 4);
	int levels0DatValue_5 = header.field_4 ^ (number - header.field_0);
	header.field_0 += header.field_8;
	header.field_4 += header.field_C;

	// Get offset with sinus header - SNA_fn_hGetOffSetInBigFileWithSinusHeader
	
	SplitInt SNA_g_ucNextRelocationTableToLoad;
	SNA_g_ucNextRelocationTableToLoad = tableToLoad;
	SNA_g_ucNextRelocationTableToLoad.byte0 = cast(ubyte)(SNA_g_ucNextRelocationTableToLoad.byte0 % levels0DatValue_1);
	SNA_g_ucNextRelocationTableToLoad.byte1 &= 3;
	
	v6 = 4 * SNA_g_ucNextRelocationTableToLoad.byte0;
	int v28 = 4 * SNA_g_ucNextRelocationTableToLoad.byte0;
	
	int v7 = v28;
	
	switch(SNA_g_ucNextRelocationTableToLoad.byte1) {
		case 1:
			v7 = v6 + 1;
			break;
		case 2:
			v7 = v6 + 2;
			break;
		case 3:
			v7 = v6 + 3;
			break;
		default:
			break;
	}
	
	v28 = v7;
	
	uint v8 = SNA_g_ucNextRelocationTableToLoad.byte2 % levels0DatValue_2;
	real v9 = 1.06913; 
	real v30 = 1.06913;
	SNA_g_ucNextRelocationTableToLoad.byte2 = cast(ubyte)v8;
	
	if(v8) {
		uint v10 = 0;
		double v11 = 0;
		
		do
		{
			v30 = v10;
			v11 = cast(double)v10;
			v10++;
			v9 = v9 - fabs(sin(v11 * v11 * 1.69314)) * -0.69314 - -0.52658;
		}
		while ( v10 < v8 );
		
		v30 = v9;
	}
	
	real v23 = 0;
	
	double v12 = modf(v30, v23);
	double v13 = floor(v12 * 1000000.0);
	ulong v24 = levels0DatValue_0;
	long v14 = cast(long)floor(cast(double)cast(uint)levels0DatValue_0 * (v13 * 0.000001));
	
	f.seek(levels0DatValue_4 + levels0DatValue_5 * v14);
	header = f.readType!DATHeader;
	if(v28) {
		int v15, v16;
		
		header.field_0 += v28 * header.field_8;
		v15 = header.field_4;
		v16 = v28;
		do
		{
			v15 += header.field_C;
			--v16;
		}
		while (v16);
		header.field_4 = v15;
	}
	
	f.seek(4 * v28, SEEK_CUR);
	uint value1 = f.readType!uint;
	
	uint dataOffset = header.field_4 ^ (value1 - header.field_0);

	tableToLoad = SNA_g_ucNextRelocationTableToLoad;

	return dataOffset;
}

uint getMagicForTable(uint tableToLoad) {
	SplitInt SNA_g_ucNextRelocationTableToLoad;
	SNA_g_ucNextRelocationTableToLoad = tableToLoad;

	SNA_g_ucNextRelocationTableToLoad.byte3 = ~SNA_g_ucNextRelocationTableToLoad.byte2;

	return getNextMagic(SNA_g_ucNextRelocationTableToLoad);
}