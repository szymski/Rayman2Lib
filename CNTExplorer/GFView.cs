using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Rayman2Lib;

namespace CNTExplorer
{
    public partial class GFView : Form
    {
        GFFile gfFile;

        public GFView(byte[] gfData)
        {
            InitializeComponent();
            gfFile = GFFile.LoadFromBytes(gfData);
        }

        private void GFView_Load(object sender, EventArgs e)
        {
            pictureBox1.Image = gfFile.GetBitmap();
            gfInfoLabel.Text = $"Width: {gfFile.width} Height: {gfFile.height}, {(gfFile.alphaChannel ? "Transparent" : "Not transparent")}";
        }
    }
}
