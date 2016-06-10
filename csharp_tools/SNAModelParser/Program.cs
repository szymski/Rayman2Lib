using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Rayman2Lib;

namespace SNAModelParser
{
    class Program
    {
        static void Main(string[] args)
        {
            EncodedStream stream = new EncodedStream(File.ReadAllBytes(@"D:\GOG Games\Rayman 2\Data\World\Levels\Learn_30\Learn_30.sna"));
            var r = new BinaryReader(stream);
            stream.Seek(4, SeekOrigin.Current); // SNA's magic number is not encoded

            stream.SeekWithUpdatedMagic(-4 + 0x5a242 - 0x46); // Move to portal stone structure start

            // Texture entry

            int something1 = r.ReadInt32();
            int something2 = r.ReadInt32();

            int something3 = r.ReadInt32();

            int something4 = r.ReadInt32();
            int something5 = r.ReadInt32();

            int something6 = r.ReadInt32();

            short something7 = r.ReadInt16();
            short something8 = r.ReadInt16();
            short texture_width = r.ReadInt16(); // Not sure
            short texture_height = r.ReadInt16(); // Not sure

            int something11 = r.ReadInt32();
            int something12 = r.ReadInt32();
            int something13 = r.ReadInt32();

            int something14 = r.ReadInt32();

            var something15 = r.ReadBytes(21);

            byte something16 = r.ReadByte();

            string texture_name = r.ReadNullTermStringWithLength(130);

            Console.WriteLine("something1: " + something1);
            Console.WriteLine("something2: " + something2);
            Console.WriteLine("something3: " + something3);
            Console.WriteLine("something4: " + something4);
            Console.WriteLine("something5: " + something5);
            Console.WriteLine("something6: " + something6);
            Console.WriteLine("something7: " + something7);
            Console.WriteLine("something8: " + something8);
            Console.WriteLine("texture_width: " + texture_width);
            Console.WriteLine("texture_height: " + texture_height);
            Console.WriteLine("something11: " + something11);
            Console.WriteLine("something12: " + something12);
            Console.WriteLine("something13: " + something13);
            Console.WriteLine("something14: " + something14);
            Console.WriteLine("something15: " + something15);
            Console.WriteLine("something16: " + something16);
            Console.WriteLine("texture_name: " + texture_name);

            Console.ReadLine();
        }
    }
}