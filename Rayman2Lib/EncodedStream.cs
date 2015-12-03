using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Rayman2Lib
{
    public class EncodedStream : Stream
    {
        byte[] data;

        public uint magic = 1790299257;

        public EncodedStream(byte[] data)
        {
            this.data = data;
            CanRead = true;
            CanSeek = true;
            CanWrite = false;
            Length = data.Length;
            Position = 0;
        }

        public override void Flush()
        {
            throw new NotImplementedException();
        }

        public override long Seek(long offset, SeekOrigin origin)
        {
            Position += offset;
            return Position;
        }

        public override void SetLength(long value)
        {
            throw new NotSupportedException();
        }

        public override int Read(byte[] buffer, int offset, int count)
        {
            for (long i = Position; i < Position + count; i++)
            {
                buffer[i - Position + offset] = data[i];
                buffer[i - Position + offset] ^= (byte)((magic >> 8) & 255);

                magic = (uint)(16807 * (magic ^ 0x75BD924) - 0x7FFFFFFF * ((magic ^ 0x75BD924u) / 0x1F31D));
            }

            Position += count;

            return count;
        }

        public override void Write(byte[] buffer, int offset, int count)
        {
            throw new NotSupportedException();
        }

        public override bool CanRead { get; }
        public override bool CanSeek { get; }
        public override bool CanWrite { get; }
        public override long Length { get; }
        public override long Position { get; set; }
    }
}
