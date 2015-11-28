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

namespace SNAReader
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {

            BinaryReader r = new BinaryReader(File.OpenRead(@"D:\GOG Games\Rayman 2\Data\World\Levels\Fix.sna"));

            r.BaseStream.Position = 520632;
            byte[] v71 = r.ReadBytes(386852);

            r.BaseStream.Position = 7296016;
            byte[] v70 = r.ReadBytes(386852);

            for (int i = 0; i < 386852; i++)
            {
                v70[i] = (byte)(v70[i] ^ v71[i]);
                MessageBox.Show("" + (char) v70[i]);
            }

            MessageBox.Show(Encoding.ASCII.GetString(v70));
        }
    }
}
