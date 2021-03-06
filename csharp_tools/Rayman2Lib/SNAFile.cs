﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Rayman2Lib
{
    /*
        SNA file format
            SNA is encoded, except it's magic number (first 4 bytes),
            so everytime we open SNA with EncodedStream, we have to skip these bytes.

        SNA is split into parts, here are some I identified:
            4   - probably pointers to other strcutures, may also contain models or prefabs
            5   - level mesh
            6   - models (has texture names, uv mapping)
            13  - waypoints, probably events, triggers
            14  - language

        File structure:
            4 bytes - magic number (no encoding)
            x bytes - part
            
            Part structure:
                1 byte  - part id 
                1 byte  - some offset used to save parts in game's memory
                1 byte  - unknown
                4 bytes - unknown 
                4 bytes - unknown 
                4 bytes - unknown 
                4 bytes - unknown 
                4 bytes - data size 
                x bytes - data
        
    */

    public class SNAFile
    {
        struct PartStruct
        {
            public long position;
            public byte partId;
            public long size;
        }

        byte[] data;
        List<PartStruct> parts = new List<PartStruct>();

        public Dictionary<int, long> gptRelocationIdToPartPosition = new Dictionary<int, long>();

        public SNAFile(byte[] data)
        {
            this.data = data;
            EncodedStream stream = new EncodedStream(data);
            var r = new BinaryReader(stream);

            stream.Seek(4, SeekOrigin.Current); // SNA's magic number is not encoded

            do
            {
                long position = stream.Position;

                var partId = r.ReadByte();
                var memorySomething = r.ReadByte();
                var v32 = r.ReadByte();
                var v29 = r.ReadInt32();

                var v42 = r.ReadInt32();
                var v27 = r.ReadInt32();
                var v33 = r.ReadInt32();
                var dataSize = r.ReadInt32(); // 0, 0, 0, 0, 0, 0, 0, 0x0001BC4C (113740), 0x006934D0, 0x00053770

                //MessageBox.Show(toMove.ToString("X8"));

                //MessageBox.Show((10 * partId + memorySomething).ToString());
                if (!gptRelocationIdToPartPosition.ContainsKey(10*partId + memorySomething))
                    gptRelocationIdToPartPosition.Add(10*partId + memorySomething, position);
                else
                    gptRelocationIdToPartPosition[10*partId + memorySomething] = position;

                if (ParseSNA3(partId, memorySomething))
                {
                    if (dataSize > 0)
                    {
                        byte[] v41 = r.ReadBytes(dataSize);

                        parts.Add(new PartStruct()
                        {
                            position = position,
                            partId = partId,
                            size = dataSize
                        });

                        File.WriteAllBytes($"sna_part_{partId}_{memorySomething}.bin", v41);
                    }
                }
                else if (dataSize > 0)
                {
                    // MessageBox.Show("Moving" + toMove.ToString());
                }

                // WIP - do not touch
            }
            while (stream.Position < stream.Length);
        }

        bool ParseSNA3(int a, int b)
        {
            return a > 0;
        }

        public override string ToString()
        {
            var builder = new StringBuilder();

            builder.AppendLine("// SNA decoder, very very WIP");
            builder.AppendLine("// File name: \n");

            foreach (var part in parts)
            {
                builder.AppendLine($"{part.position.ToString("X8")} - {(part.position + part.size).ToString("X8")}: Part id {part.partId}");
                builder.AppendLine("\n");
            }

            return builder.ToString();
        }

    }
}
