using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Rayman2Lib;

namespace DSBDecompiler
{
    public partial class Form1 : Form
    {
        // 004508A0 ParseDSB - Reads and executes encrypted DSB script

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            try
            {
                DecompileDsb(@"F:\Projects\Rayman2 Tools\Rayman2Lib\SNAReader\bin\Debug\sna_part_5_2.bin");
                //DecompileDsb(@"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Raycap\Raycap.dsb");
            }
            catch
            {
                AppendLine("EXCEPTION");
            }
        }

        void AppendLine(string text) => richTextBox1.AppendText(text + "\n");

        void ParseDSB_1(BinaryReader r)
        {
            int id = 0;
            while ((id = r.ReadInt32()) != 0xFFFF)
            {
                switch (id)
                {
                    case 0x01:
                        AppendLine($"allocate_1 {r.ReadInt32()}");
                        break;
                    case 0x02:
                        AppendLine($"allocate_2 {r.ReadInt32()}");
                        break;
                    case 0x03:
                        AppendLine($"allocate_3 {r.ReadInt32()}");
                        break;
                    case 0x04:
                        AppendLine($"allocate_4 {r.ReadInt32()}");
                        break;
                    case 0x05:
                        AppendLine($"allocate_5 {r.ReadInt32()}");
                        break;
                    case 0x06:
                        AppendLine($"allocate_6 {r.ReadInt32()}");
                        break;
                    case 0x07:
                        AppendLine($"allocate_7 {r.ReadInt32()}");
                        break;
                    case 0x08:
                        AppendLine($"allocate_8 {r.ReadInt32()}");
                        break;
                    case 0x10:
                        AppendLine($"skip {r.ReadInt32()} {r.ReadInt32()}");
                        break;
                    case 0x0F:
                        AppendLine($"allocate_0x0F {r.ReadInt32()}");
                        break;
                    case 0x0B:
                        AppendLine($"allocate_0x0B {r.ReadInt32()}");
                        break;
                    case 0x0C:
                        AppendLine($"allocate_0x0C {r.ReadInt32()}");
                        break;
                    case 0x0D:
                        AppendLine($"allocate_0x0D {r.ReadInt32()}");
                        break;
                    case 0x0E:
                        AppendLine($"allocate_0x0E {r.ReadInt32()}");
                        break;
                }
            }
        }

        void ParseDSB_2(BinaryReader r)
        {
            r.ReadInt32();

            int id = 0;
            while ((id = r.ReadInt32()) != 0xFFFF)
            {
                if (id == 0x1F)
                {
                    AppendLine($"add_level \"{r.ReadNullTermStringWithLength()}\"");
                }
            }
        }

        void ParseDSB_3(BinaryReader r)
        {
            int id = 0;
            while ((id = r.ReadInt32()) != 0xFFFF)
            {
                switch (id)
                {
                    case 41:
                        AppendLine($"drivers \"{Encoding.ASCII.GetString(r.ReadBytes(r.ReadInt16())).Replace((char)0x00, '"')}");
                        break;
                    case 42:
                        AppendLine($"game_data \"{Encoding.ASCII.GetString(r.ReadBytes(r.ReadInt16())).Replace((char)0x00, '"')}");
                        break;
                    case 43:
                        AppendLine($"world \"{Encoding.ASCII.GetString(r.ReadBytes(r.ReadInt16())).Replace((char)0x00, '"')}");
                        break;
                    case 44:
                        AppendLine($"levels \"{Encoding.ASCII.GetString(r.ReadBytes(r.ReadInt16())).Replace((char)0x00, '"')}");
                        break;
                    case 45:
                        AppendLine($"sound \"{Encoding.ASCII.GetString(r.ReadBytes(r.ReadInt16())).Replace((char)0x00, '"')}");
                        break;
                    case 46:
                        AppendLine($"saves \"{Encoding.ASCII.GetString(r.ReadBytes(r.ReadInt16())).Replace((char)0x00, '"')}");
                        break;
                    case 47:
                        AppendLine($"47 \"{Encoding.ASCII.GetString(r.ReadBytes(r.ReadInt16())).Replace((char)0x00, '"')}");
                        break;
                    case 48:
                        AppendLine($"vignette \"{Encoding.ASCII.GetString(r.ReadBytes(r.ReadInt16())).Replace((char)0x00, '"')}");
                        break;
                    case 49:
                        AppendLine($"options \"{Encoding.ASCII.GetString(r.ReadBytes(r.ReadInt16())).Replace((char)0x00, '"')}");
                        break;
                }
            }
        }

        void ParseDSB_4(BinaryReader r)
        {
            var size = r.ReadInt32();

            int id = 0;
            while ((id = r.ReadInt32()) != 0xFFFF)
            {
                if (id == 0x1F)
                {
                    var temp = id - 33;

                    if (temp <= 0)
                        break;
                    if (temp == 1)
                    {
                        r.ReadBytes(size * 4);
                    }
                }
            }
        }

        void ParseDSB_5(BinaryReader r)
        {
            int id = 0;
            while ((id = r.ReadInt32()) != 0xFFFF)
            {
                if (id == 72)
                    AppendLine($"set \"{Encoding.ASCII.GetString(r.ReadBytes(r.ReadInt16())).Replace((char)0x00, '"')}");

                else if (id == 71)
                    AppendLine($"set \"{r.ReadNullTermStringWithLength()}\"");

                else if (id == 73)
                    AppendLine("73");

                else if (id == 75)
                    AppendLine($"show");

                else if (id == 76)
                {
                    r.ReadInt32();
                    r.ReadInt32();
                    r.ReadInt32();
                    var cR = r.ReadByte();
                    var cG = r.ReadByte();
                    var cB = r.ReadByte();
                    var cA = r.ReadByte();
                    AppendLine($"outline_color {cR} {cG} {cB} {cA}");
                }

                else if (id == 77)
                {
                    r.ReadInt32();
                    r.ReadInt32();
                    r.ReadInt32();
                    var cR = r.ReadByte();
                    var cG = r.ReadByte();
                    var cB = r.ReadByte();
                    var cA = r.ReadByte();
                    AppendLine($"inside_color {cR} {cG} {cB} {cA}");
                }

                else if (id == 78)
                {
                    r.ReadBytes(16);
                    r.ReadBytes(16);
                    r.ReadBytes(16);
                    r.ReadBytes(16);
                    // TODO: Add these as parameters
                    AppendLine($"78");
                }

                else if (id == 79)
                {
                    r.ReadInt32();
                    r.ReadInt32();
                    r.ReadInt32();
                    r.ReadInt32();
                    // TODO: Add these as parameters
                    AppendLine($"79");
                }

                else if (id == 80)
                    AppendLine($"add_bar");

                else if (id == 81)
                    AppendLine($"bar_max_value {r.ReadInt32()}");
            }
        }

        void ParseDSB_6(BinaryReader r)
        {
            int id = 0;
            while ((id = r.ReadInt32()) != 0xFFFF)
            {
                var temp = id - 65;
                if (temp > 0)
                {
                    if (temp == 1)
                    {
                        AppendLine($"add_textures \"{Encoding.ASCII.GetString(r.ReadBytes(r.ReadInt16())).Replace((char)0x00, '"')}");
                    }
                }
                else
                {
                    AppendLine($"add_vignette \"{Encoding.ASCII.GetString(r.ReadBytes(r.ReadInt16())).Replace((char)0x00, '"')}");
                }
            }
        }

        void ParseDSB_7(BinaryReader r)
        {
            int id = 0;
            while ((id = r.ReadInt32()) != 0xFFFF)
            {
                var temp = id - 91;
                if (temp > 0)
                {
                    if (temp == 1)
                    {
                        int bankType = 0;
                        while ((bankType = r.ReadInt32()) != 0xFFFF)
                        {
                            var temp2 = bankType - 93;
                            if (temp2 > 0)
                            {
                                if (temp2 == 1)
                                    AppendLine($"add_bank {r.ReadInt32()}");
                            }
                            else
                            {
                                // TODO: Print
                                r.ReadBytes(r.ReadInt32() * 4);
                                AppendLine($"add_bank2");
                            }
                        }
                    }
                }
                else
                {
                    AppendLine($"unknown {r.ReadInt32()}");
                }
            }
        }

        void ParseDSB_8(BinaryReader r)
        {
            int id = 0;
            while ((id = r.ReadInt32()) != 0xFFFF)
            {
                var temp = id - 101;
                if (temp > 0)
                {
                    if (temp - 1 > 0)
                    {
                        if (temp - 1 == 1)
                        {
                            AppendLine($"something \"{r.ReadNullTermStringWithLength()}\" \"{r.ReadNullTermStringWithLength()}\" \"{r.ReadNullTermStringWithLength()}\"");
                        }
                    }
                    else
                    {
                        AppendLine($"something2 \"{r.ReadNullTermStringWithLength()}\"");
                    }
                }
                else
                {
                    AppendLine($"something3 \"{r.ReadNullTermStringWithLength()}\"");
                }
            }
        }

        void ParseDSB_9(BinaryReader r)
        {
            int bankType = 0;
            while ((bankType = r.ReadInt32()) != 0xFFFF)
            {
                var temp2 = bankType - 93;
                if (temp2 > 0)
                {
                    if (temp2 == 1)
                        AppendLine($"add_bank {r.ReadInt32()}");
                }
                else
                {
                    // TODO: Print
                    r.ReadBytes(r.ReadInt32() * 4);
                    AppendLine($"add_bank2");
                }
            }
        }

        void ParseDSB_10(BinaryReader r)
        {
                AppendLine($"start {r.ReadInt32()}");
        }

        void DecompileDsb(string filename)
        {
            var r = new BinaryReader(new EncodedStream(File.ReadAllBytes(filename)));
            r.BaseStream.Seek(4, SeekOrigin.Current); // Header

            AppendLine("// DSB Decompiler");
            AppendLine($"// File: {filename}\n");

            int id = 0;
            while ((id = r.ReadInt32()) != 0xFFFF)
            {
                switch (id)
                {
                    case 0x00:
                        AppendLine("\nstart allocation_part");
                        ParseDSB_1(r);
                        AppendLine("end allocation_part\n");
                        break;
                    case 0x1E:
                        AppendLine("\nstart levels_part");
                        ParseDSB_2(r);
                        AppendLine("end levels_part\n");
                        break;
                    case 0x28:
                        AppendLine("\nstart data_directories");
                        ParseDSB_3(r);
                        AppendLine("end data_directories\n");
                        break;
                    case 0x20:
                        AppendLine("\nstart 0x20");
                        ParseDSB_4(r);
                        AppendLine("end 0x20\n");
                        break;
                    case 0x46:
                        AppendLine("\nstart vignette_part");
                        ParseDSB_5(r);
                        AppendLine("end vignette_part\n");
                        break;
                    case 0x40:
                        AppendLine("\nstart texture_files_part");
                        ParseDSB_6(r);
                        AppendLine("end texture_files_part\n");
                        break;
                    case 0x5A:
                        AppendLine("\nstart sound_banks_part");
                        ParseDSB_7(r);
                        AppendLine("end sound_banks_part\n");
                        break;
                    case 0x64:
                        AppendLine("\nstart 0x64");
                        ParseDSB_8(r);
                        AppendLine("end 0x64\n");
                        break;
                    case 0x5C:
                        AppendLine("\nstart load_sound_banks_part");
                        ParseDSB_9(r);
                        AppendLine("end load_sound_banks_part\n");
                        break;
                    case 0x6E:
                        AppendLine("\nstart window_something");
                        ParseDSB_10(r);
                        AppendLine("end window_something\n");
                        break;
                    case 0x78:
                        AppendLine("\nstart window_something");
                        // TODO: This
                        AppendLine("end window_something\n");
                        break;
                }
            }
        }
    }
}
