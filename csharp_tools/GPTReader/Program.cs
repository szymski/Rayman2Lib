using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Rayman2Lib;

namespace GPTReader
{
    class Program
    {
        static SNAFile sna = new SNAFile(File.ReadAllBytes(@"D:\GOG Games\Rayman 2\Data\World\Levels\Learn_30\Learn_30.sna"));

        static void Main(string[] args)
        {
            foreach (var id in sna.gptRelocationIdToPartPosition)
            {
                //MessageBox.Show(id.Key.ToString("X") + " - " + id.Value.ToString("X8"));
            }

            string filename = @"D:\GOG Games\Rayman 2\Data\World\Levels\Learn_30\Learn_30.gpt";
            var stream = File.OpenRead(filename);
            var b = new BinaryReader(stream);

            uint SNA_g_stFixInfo = b.ReadUInt32();
            for (int i = 0; SNA_g_stFixInfo > i; i++)
            {
                uint ptr1 = ReadPointer(b);
                if (true)
                {
                    uint ptr2 = ReadPointer(b);
                    var data = b.ReadBytes(88);
                    uint ptr3 = ReadPointer(b);
                }
            }

            Console.ReadLine();
        }

        static uint ReadPointer(BinaryReader b)
        {
            var relativePtr = b.ReadUInt32();
            MessageBox.Show((relativePtr + sna.gptRelocationIdToPartPosition[0x33]).ToString("X8"));
            return relativePtr;
        }
    }
}
