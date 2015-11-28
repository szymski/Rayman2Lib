using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Rayman2Lib
{
    public class SNAFile
    {
        byte[] data;

        bool ParseSNA3(int a, int b)
        {
            return a == 4;
        }

        public SNAFile(byte[] data)
        {
            this.data = data;
            EncodedStream stream = new EncodedStream(data);
            var r = new BinaryReader(stream);

            stream.Seek(4, SeekOrigin.Current); // SNA's magic number is not encoded

            do
            {
                var v25 = r.ReadByte();
                var v26 = r.ReadByte();
                var v32 = r.ReadByte();
                var v29 = r.ReadInt32();

                var v42 = r.ReadInt32();
                var v27 = r.ReadInt32();
                var v33 = r.ReadInt32();
                var toMove = r.ReadInt32(); // 0, 0, 0, 0, 0, 0, 0, 0x0001BC4C (113740)
                
                if (ParseSNA3(v25, v29))
                {
                    if (toMove > 0)
                    {
                        MessageBox.Show(toMove.ToString());
                        //byte[] v41 = r.ReadBytes(toMove);
                    }
                }
                else if (toMove > 0)
                {
                   // MessageBox.Show("Moving" + toMove.ToString());
                }

                // WIP - do not touch
            }
            while (stream.Position < stream.Length);
        }
    }
}
