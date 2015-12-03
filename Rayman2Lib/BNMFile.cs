using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Rayman2Lib
{
    public class BNMFile
    {
        public class SoundFile
        {
            public string name;
            public int sampleRate;
            public int length;
            public byte[] data;

            public void Save(Stream stream)
            {
                uint numsamples = 22050;
                ushort numchannels = 1;
                ushort samplelength = 1;

                BinaryWriter wr = new BinaryWriter(stream);

                wr.Write(Encoding.ASCII.GetBytes("RIFF"));
                wr.Write(36 + data.Length);
                wr.Write(Encoding.ASCII.GetBytes("WAVEfmt "));
                wr.Write(16);
                wr.Write((ushort)1);
                wr.Write(numchannels);
                wr.Write(sampleRate);
                wr.Write(sampleRate * samplelength * numchannels);
                wr.Write((ushort)(samplelength * numchannels));
                wr.Write((ushort)(16));
                wr.Write(Encoding.ASCII.GetBytes("data"));
                wr.Write(data.Length);
                wr.Write(data);
                wr.Close();
            }
        }

        byte[] data;

        int dataPos = 0;
        public List<SoundFile> soundFiles = new List<SoundFile>();

        public BNMFile(byte[] data)
        {
            this.data = data;

            BinaryReader r = new BinaryReader(new MemoryStream(data));

            // Header
            var field_0 = r.ReadInt32();
            var field_4 = r.ReadInt32();
            var eventCount = r.ReadInt32();
            var field_C = r.ReadInt32();
            var field_10 = r.ReadInt32();
            var size1 = r.ReadInt32();
            var size2 = r.ReadInt32();
            var field_1C = r.ReadInt32();
            var field_20 = r.ReadInt32();
            var field_24 = r.ReadInt32();
            var field_28 = r.ReadInt32();

            var fileList = r.ReadBytes(size1 - 44);

            if (size2 - size1 > 0)
                r.ReadBytes(size2 - size1);

            dataPos = (int)r.BaseStream.Position;

            if (size2 > 0)
            {
                r.ReadBytes(size2);
            }

            var size3 = field_20 - field_1C;

            if (size3 > 0)
            {
                byte[] dataPart = r.ReadBytes(size3);
            }

            // Read file list

            var mr = new BinaryReader(new MemoryStream(fileList));

            if (eventCount > 0)
            {
                for (int i = 0; i < eventCount; i++)
                {
                    // TODO: Read binary events
                    mr.ReadBytes(32);
                }
                if (field_10 > 0)
                {
                    r.BaseStream.Seek(dataPos, SeekOrigin.Begin);

                    // Here begin file names
                    for (int i = 0; i < field_10; i++)
                    {
                        var someValue = mr.ReadInt32();
                        int type = mr.ReadInt32();
                        mr.ReadBytes(4);
                        var length = mr.ReadInt32();
                        if (type == 0xA)
                        {
                            length = mr.ReadInt32();
                            mr.ReadBytes(40);
                        }
                        else if (type != 1)
                        {
                            //MessageBox.Show("weird type " + type.ToString("X") + " " + i);
                            mr.ReadBytes(44);
                        }
                        else
                            mr.ReadBytes(44);
                        var sampleRate = mr.ReadInt32();
                        mr.ReadBytes(8);
                        //MessageBox.Show((44 + r.BaseStream.Position).ToString());
                        var name = Encoding.ASCII.GetString(mr.ReadBytes(20));
                        name = name.Substring(0, name.IndexOf((char)0x00));
                        if (name.Length == 0)
                            name = "UNKNOWN_TYPE";
                        if (name.IndexOf(".apm") != -1)
                            length = 0;

                        if (type != 1 || soundFiles.Any(f => f.name == name))
                            continue;

                        //MessageBox.Show(name + " " + (44 + mr.BaseStream.Position - 92).ToString());

                        soundFiles.Add(new SoundFile()
                        {
                            name = name,
                            sampleRate = sampleRate,
                            length = length,
                            data = r.ReadBytes(length)
                        });
                    }
                    //MessageBox.Show((44 + mr.BaseStream.Position).ToString());
                }
            }

            r.Close();
        }
    }
}
