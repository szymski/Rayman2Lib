using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rayman2Lib
{
    /*
        GF Header:
            4 bytes - signature
            4 bytes - width
            4 bytes - height
            1 byte  - channel count
            1 byte  - repeat byte
            
        Now, we need to read the channels

        Channel:
            For each pixel (width*height):
                1 byte - color value

                If color value 1 equals repeat byte from header, we read more values:
                    1 byte - color value
                    1 byte - repeat count
                   
                Otherwise:
                    Channel pixel = color value

    */

    public class GF3File
    {
        public int width, height;
        public bool isTransparent = false;
        public Color[,] pixels;

        public GF3File(Stream stream)
        {
            BinaryReader r = new BinaryReader(stream);

            r.ReadInt32(); // Signature

            width = r.ReadInt32();
            height = r.ReadInt32();

            pixels = new Color[width, height];

            int channels = r.ReadByte();
            byte brk = r.ReadByte();

            byte[] blue_channel = ReadChannel(r, brk, width * height);
            byte[] green_channel = ReadChannel(r, brk, width * height);
            byte[] red_channel = ReadChannel(r, brk, width * height);
            byte[] alpha_channel = null;
            if (channels == 4)
            {
                alpha_channel = ReadChannel(r, brk, width * height);
                isTransparent = true;
            }

            for (int y = 0; y < height; y++)
                for (int x = 0; x < width; x++)
                    if (channels == 4)
                        pixels[x, height - y - 1] = Color.FromArgb(alpha_channel[width * y + x], red_channel[width * y + x], green_channel[width * y + x], blue_channel[width * y + x]);
                    else
                        pixels[x, height - y - 1] = Color.FromArgb(red_channel[width * y + x], green_channel[width * y + x], blue_channel[width * y + x]);

            r.Close();
        }

        byte[] ReadChannel(BinaryReader r, byte brk, int pixels)
        {
            byte[] channel = new byte[pixels];

            int pixel = 0;

            while (pixel < pixels)
            {
                byte b1 = r.ReadByte();
                if (b1 == brk)
                {
                    byte b2 = r.ReadByte();
                    byte b3 = r.ReadByte();

                    for (int i = 0; i < b3; ++i)
                    {
                        channel[pixel] = b2;
                        pixel++;
                    }
                }
                else
                {
                    channel[pixel] = b1;
                    pixel++;
                }
            }

            return channel;
        }

        public Bitmap GetBitmap()
        {
            Bitmap bmp = new Bitmap(width, height, isTransparent ? PixelFormat.Format32bppArgb : PixelFormat.Format24bppRgb);

            for (int y = 0; y < height; y++)
                for (int x = 0; x < width; x++)
                    bmp.SetPixel(x, y, pixels[x, y]);

            return bmp;
        }

        public static GFFile LoadFromBytes(byte[] bytes)
        {
            return new GFFile(new MemoryStream(bytes));
        }
    }
}
