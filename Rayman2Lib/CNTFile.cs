using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rayman2Lib
{
    /*
        CNT file structure
            4 bytes     - directory count
            4 bytes     - size2
            2 bytes     - signature
            1 byte      - something
            int, string - directory list

    */

    public sealed class CNTFile : IDisposable
    {
        public enum CNTVersion
        {
            Rayman2,
            Rayman2Vignette
        }

        public class FileStruct
        {
            public string name;
            public string directory;
            public int pointer;
            public int size;
            public byte[] magic1;
            public int magic2;
        }

        public CNTVersion version;

        public List<string> directoryList = new List<string>();
        public List<FileStruct> fileList = new List<FileStruct>();

        BinaryReader r;

        public CNTFile(Stream stream)
        {
            r = new BinaryReader(stream);

            int directoryCount = r.ReadInt32();
            int fileCount = r.ReadInt32();

            // Check signature
            if (r.ReadInt16() != 257)
            {
                throw new InvalidDataException("This is not a valid CNT archive!");
            }

            byte magic = r.ReadByte();

            // Load directories
            for (int i = 0; i < directoryCount; i++)
            {
                int strLen = r.ReadInt32();
                string directory = "";

                for (int j = 0; j < strLen; j++)
                {
                    directory += (char)(magic ^ r.ReadByte());
                }

                directoryList.Add(directory);
            }

            // Load and check version
            byte verId = r.ReadByte();

            switch (verId)
            {
                case 246:
                    version = CNTVersion.Rayman2;
                    break;
                default:
                    version = CNTVersion.Rayman2Vignette;
                    break;
            }

            // Read files
            for (int i = 0; i < fileCount; i++)
            {
                int dirIndex = r.ReadInt32();
                int size = r.ReadInt32();

                string file = "";

                for (int j = 0; j < size; j++)
                {
                    file += (char)(magic ^ r.ReadByte());
                }

                byte[] magic1 = new byte[4];
                r.Read(magic1, 0, 4);

                int magic2 = r.ReadInt32();

                int dataPointer = r.ReadInt32();
                int fileSize = r.ReadInt32();

                string dir = dirIndex != -1 ? directoryList[dirIndex] : "";

                fileList.Add(new FileStruct()
                {
                    directory = dir,
                    name = file,
                    pointer = dataPointer,
                    size = fileSize,
                    magic1 = magic1,
                    magic2 = magic2
                });
            }
        }

        public byte[] GetFileBytes(string filename)
        {
            FileStruct file = fileList.FirstOrDefault(f => (f.directory + "\\" + f.name) == filename);
            if (file == null)
                throw new FileNotFoundException($"{filename} could not be found!");

            r.BaseStream.Position = file.pointer;

            byte[] data = new byte[file.size];
            r.Read(data, 0, data.Length);

            for (int i = 0; i < file.size; i++)
            {
                if ((file.size % 4) + i < file.size)
                    data[i] = (byte)(data[i] ^ file.magic1[i % 4]);
            }

            return data;
        }

        public void Dispose()
        {
            r.Close();
        }

        public static CNTFile LoadFromFile(string filename)
        {
            return new CNTFile(File.OpenRead(filename));
        }
    }
}
