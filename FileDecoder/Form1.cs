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

namespace FileDecoder
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void decodeButton_Click(object sender, EventArgs e)
        {
            openFileDialog1.Filter = "";
            if (openFileDialog1.ShowDialog() == DialogResult.OK && File.Exists(openFileDialog1.FileName))
            {
                saveFileDialog1.FileName = new FileInfo(openFileDialog1.FileName).Name + ".decoded";
                if (saveFileDialog1.ShowDialog() == DialogResult.OK)
                {
                    var stream = new EncodedStream(File.ReadAllBytes(openFileDialog1.FileName));
                    stream.Seek(4, SeekOrigin.Current);
                    byte[] buff = new byte[stream.Length];
                    buff[0] = 0x79;
                    buff[1] = 0xCC;
                    buff[2] = 0xB5;
                    buff[3] = 0x6A;
                    stream.Read(buff, 4, (int)stream.Length - 4);
                    File.WriteAllBytes(saveFileDialog1.FileName, buff);
                    stream.Close();
                    MessageBox.Show("File decoded!");
                }
            }
        }

        private void encodeButton_Click(object sender, EventArgs e)
        {
            openFileDialog1.Filter = "Decoded files|*.decoded";

            if (openFileDialog1.ShowDialog() == DialogResult.OK && File.Exists(openFileDialog1.FileName))
            {
                saveFileDialog1.FileName = new FileInfo(openFileDialog1.FileName).Name.Replace(".decoded", "");
                if (saveFileDialog1.ShowDialog() == DialogResult.OK)
                {
                    var stream = new EncodedStream(File.ReadAllBytes(openFileDialog1.FileName));
                    stream.Seek(4, SeekOrigin.Current);
                    byte[] buff = new byte[stream.Length];
                    buff[0] = 0x79;
                    buff[1] = 0xCC;
                    buff[2] = 0xB5;
                    buff[3] = 0x6A;
                    stream.Read(buff, 4, (int)stream.Length - 4);
                    File.WriteAllBytes(saveFileDialog1.FileName, buff);
                    stream.Close();
                    MessageBox.Show("File saved!");
                }
            }
        }
    }
}
