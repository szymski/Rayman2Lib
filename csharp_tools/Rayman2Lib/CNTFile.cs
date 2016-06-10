using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rayman2Lib
{
    /*
        CNT structure:
            4 bytes     - directory count
            4 bytes     - file count
            2 bytes     - signature
            1 byte      - xor key
            Directories
            1 byte      - version id
            Files


        Directory:
            4 bytes     - name size
            string      - directory name
           
        File:
            4 bytes     - directory index
            4 bytes     - file name size
            string      - file name ^ xor key
            4 bytes     - file xor key
            4 bytes     - unknown
            4 bytes     - pointer
            4 bytes     - size

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
            public byte[] xorKey;
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

            byte xorKey = r.ReadByte();

            // Load directories
            for (int i = 0; i < directoryCount; i++)
            {
                int strLen = r.ReadInt32();
                string directory = "";

                for (int j = 0; j < strLen; j++)
                {
                    directory += (char)(xorKey ^ r.ReadByte());
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
                    file += (char)(xorKey ^ r.ReadByte());
                }

                byte[] fileXorKey = new byte[4];
                r.Read(fileXorKey, 0, 4);

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
                    xorKey = fileXorKey,
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
                    data[i] = (byte)(data[i] ^ file.xorKey[i % 4]);
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

        public class SaveFileStruct
        {
            public string name;
            public string dir;
            public byte[] data;
        }

        static string XORString(string str, byte key)
        {
            string newStr = "";

            for (int i = 0; i < str.Length; i++)
            {
                newStr += (char)(str[i] ^ key);
            }

            return newStr;
        }

        public static void Save(Stream stream, List<SaveFileStruct> files)
        {
            // Preparation

            List<string> directoryList = new List<string>();
            List<Tuple<int, string, byte[]>> fileList = new List<Tuple<int, string, byte[]>>();

            int directoryCount = 0;
            int fileCount = 0;

            foreach (var file in files)
            {
                if (file.dir != "" && !directoryList.Contains(file.dir))
                {
                    if (file.dir.Split('\\').Length >= 2 && !directoryList.Contains(file.dir.Split('\\')[0]))
                    {
                        directoryList.Add(file.dir.Split('\\')[0]);
                        directoryCount++;
                    }
                    directoryList.Add(file.dir);
                    directoryCount++;
                }

                fileList.Add(new Tuple<int, string, byte[]>(directoryList.IndexOf(file.dir), file.name, file.data));
                fileCount++;
            }

            // Write to file

            BinaryWriter w = new BinaryWriter(stream);

            w.Write(directoryCount);
            w.Write(fileCount);
            w.Write((short)257); // Signature
            w.Write((byte)4);

            // Directories
            for (int i = 0; i < directoryCount; i++)
            {
                var dir = directoryList[i];
                w.Write(dir.Length);
                w.Write(Encoding.ASCII.GetBytes(XORString(dir, 4)));
            }

            w.Write((byte)246);

            /*
                CNT structure:
                    4 bytes     - directory count
                    4 bytes     - file count
                    2 bytes     - signature
                    1 byte      - xor key
                    Directories
                    1 byte      - version id
                    Files


                Directory:
                    4 bytes     - name size
                    string      - directory name
           
                File:
                    4 bytes     - directory index
                    4 bytes     - file name size
                    string      - file name ^ xor key
                    4 bytes     - file xor key
                    4 bytes     - unknown
                    4 bytes     - pointer
                    4 bytes     - size

            */

            List<Tuple<long, byte[]>> fileQueue = new List<Tuple<long, byte[]>>();

            // Files
            for (int i = 0; i < fileCount; i++)
            {
                var file = fileList[i];
                w.Write(file.Item1);
                w.Write(file.Item2.Length);
                w.Write(Encoding.ASCII.GetBytes(XORString(file.Item2, 4)));
                w.Write(0);
                w.Write(0);
                long pos = w.BaseStream.Position;
                w.Write(0);
                w.Write(file.Item3.Length);

                fileQueue.Add(new Tuple<long, byte[]>(pos, file.Item3));
            }

            // Data
            foreach (var file in fileQueue)
            {
                long dataPos = w.BaseStream.Position;
                w.BaseStream.Position = file.Item1;
                w.Write((int)dataPos);
                w.BaseStream.Position = dataPos;
                for (int i = 0; i < file.Item2.Length; i++)
                {
                    w.Write((byte)(file.Item2[i] ^ 0));
                }
            }

            w.Close();
        }
    }
}
