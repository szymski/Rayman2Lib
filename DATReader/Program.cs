using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Rayman2Lib;

namespace DATReader
{
    class Program
    {
        struct LEVELS0DAT_Header
        {
            public int field_0, field_4, field_8, field_C;
        }

        static void Main(string[] args)
        {
            BinaryReader r = new BinaryReader(File.OpenRead(@"D:\GOG Games\Rayman 2\Data\World\Levels\LEVELS0.DAT"));

            // ReadLEVELS0DAT_1

            LEVELS0DAT_Header header = new LEVELS0DAT_Header();

            header.field_0 = r.ReadInt32();
            header.field_4 = r.ReadInt32();
            header.field_8 = r.ReadInt32();
            header.field_C = r.ReadInt32();
            header.field_0 += header.field_8;
            header.field_4 += header.field_C;

            r.ReadInt32();

            int number = r.ReadInt32();
            int levels0DatValue_0 = header.field_4 ^ (number - header.field_0);
            header.field_0 += header.field_8;
            header.field_4 += header.field_C;

            number = r.ReadInt32();
            int levels0DatValue_1 = (header.field_4 ^ (number - header.field_0)) >> 2;
            header.field_0 += header.field_8;
            header.field_4 += header.field_C;

            number = r.ReadInt32();
            header.field_0 += header.field_8;
            header.field_4 += header.field_C;

            number = r.ReadInt32();
            int levels0DatValue_2 = header.field_4 ^ (number - header.field_0);
            header.field_0 += header.field_8;
            header.field_4 += header.field_C;

            number = r.ReadInt32();
            int levels0DatValue_3 = header.field_4 ^ (number - header.field_0);
            header.field_0 += header.field_8;
            header.field_4 += header.field_C;

            number = r.ReadInt32();
            int levels0DatValue_4 = header.field_4 ^ (number - header.field_0);
            header.field_0 += header.field_8;
            header.field_4 += header.field_C;

            number = r.ReadInt32();
            int levels0DatValue_5 = header.field_4 ^ (number - header.field_0);
            header.field_0 += header.field_8;
            header.field_4 += header.field_C;

            // ReadLEVELS0DAT_2

            // I don't get this - floating-point operations on file pointers!?
            double v9 = 1.06913;
            double v30 = 1.06913;
            int v8 = 5;
            int v10 = 0;
            do
            {
                int v11 = v10++;
                v9 = v9 - Math.Abs(Math.Sin(v11 * v11 * 1.69314)) * -0.69314 - -0.52658;
            }
            while (v10 < v8);
            v30 = v9;

            double v12 = v30 - Math.Floor(v30);
            double v13 = Math.Floor(v12 * 1000000.0);
            int v14 = (int) Math.Floor(levels0DatValue_0*(v13*0.000001));

            r.BaseStream.Seek(levels0DatValue_4 + levels0DatValue_5 * v14, SeekOrigin.Begin);

            Console.WriteLine(levels0DatValue_4 + levels0DatValue_5 * v14);

            // TODO: This part is not finished

            r.Close();

            // Encoded part
            r = new BinaryReader(new EncodedStream(File.ReadAllBytes(@"D:\GOG Games\Rayman 2\Data\World\Levels\LEVELS0.DAT")));
            r.BaseStream.Seek(0x427B000, SeekOrigin.Begin);
            int byte_5116F0 = 0x00030000;
            //((EncodedStream)r.BaseStream).magic = (uint)(16807 * (byte_5116F0 ^ 0x75BD924) - 0x7FFFFFFF * ((byte_5116F0 ^ 0x75BD924u) / 0x1F31D));
            ((EncodedStream) r.BaseStream).magic = 0x6AB5CC79;
            File.WriteAllBytes("encoded", r.ReadBytes(1024*1024));

            Console.ReadKey();
        }
    }
}
