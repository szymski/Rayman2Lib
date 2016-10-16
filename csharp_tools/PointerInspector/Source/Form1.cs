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
using PointerInspector.Source;
using PointerInspector.Source.Controls;

namespace PointerInspector
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(Object sender, EventArgs e)
        {
            var pointers = Api.GetPointers();

            List<Highlight> highlights = new List<Highlight>();

            foreach (var pointer in pointers)
            {
                highlights.Add(new Highlight()
                {
                    Address = pointer.Address,
                    Length = 4,
                    Type = HighlightType.Pointer,
                    Color = Color.Yellow,
                });

                highlights.Add(new Highlight()
                {
                    Address = pointer.Value,
                    Length = 1,
                    Type = HighlightType.PointedValue,
                    Color = Color.LawnGreen,
                });
            }

            hexView1.allHighlights = highlights.OrderBy(h => h.Address).ToArray();

            hexView1.Data = File.ReadAllBytes(@"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.sna.decoded");
        }

        private void statusStrip1_ItemClicked(Object sender, ToolStripItemClickedEventArgs e)
        {

        }
    }
}
