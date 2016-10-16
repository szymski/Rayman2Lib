using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using PointerInspector.Source;
using PointerInspector.Source.Controls;
using PointerInspector.Source.Forms;

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
            var snaFile = @"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.sna";
            var levels0dat = @"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\LEVELS0.DAT";
            var offset = 79187968;
            var magic = 1982693709;

            var pointers = Api.GetPointers(snaFile, levels0dat, offset, magic);

            List<Highlight> highlights = new List<Highlight>();

            foreach (var pointer in pointers)
            {
                highlights.Add(new Highlight()
                {
                    Address = pointer.Address,
                    Length = 4,
                    Type = HighlightType.Pointer,
                    Color = Color.Yellow,
                    Value = pointer.Value
                });

                highlights.Add(new Highlight()
                {
                    Address = pointer.Value,
                    Length = 1,
                    Type = HighlightType.ReferencedValue,
                    Color = Color.LawnGreen,
                    Value = pointer.Address
                });
            }

            hexView1.allHighlights = highlights.OrderBy(h => h.Address).ToArray();

            hexView1.Data = File.ReadAllBytes(@"D:\GOG Games\Rayman 2\Rayman 2 Modded\Data\World\Levels\Learn_30\Learn_30.sna.decoded");
        }

        private void statusStrip1_ItemClicked(Object sender, ToolStripItemClickedEventArgs e)
        {

        }

        private void hexView1_ByteSelected(Object sender, int position, Highlight[] highlights)
        {
            labelPosition.Text = $"Position: {position}, 0x{position.ToString("X")}";

            UpdateByteLabel(position, highlights);

            PopulateReferenceList(position, highlights);
        }

        private void UpdateByteLabel(int position, Highlight[] highlights)
        {
            if (highlights.Any(h => h.Type == HighlightType.Pointer))
            {
                var highlight = highlights.First(h => h.Type == HighlightType.Pointer);
                int relativePos = (int)highlight.Value - position;

                labelByteInfo.Text = $"0x{((int)highlight.Value).ToString("X8")} ({(relativePos > 0 ? "+" : "-")}{Math.Abs(relativePos)})";
            }
            else
                labelByteInfo.Text = "Not a pointer";

            if (hexView1.History.Count > 0)
                textBoxHistory.Text = hexView1.History.Select(a => hexView1.SelectedPosition == a ? $"(0x{a.ToString("X8")})" : $" 0x{a.ToString("X8")} ").Aggregate((a, b) => $"{a} > {b}");
        }

        private void hexView1_ByteDoubleClick(Object sender, Int32 position, Highlight[] highlights)
        {
            var pointers = highlights.Where(h => h.Type == HighlightType.Pointer);

            if (pointers.Any())
            {
                var pointer = pointers.First();
                hexView1.SelectedPosition = (int)pointer.Value;
            }
        }

        #region Toolbar

        private void exitToolStripMenuItem_Click(Object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void aboutToolStripMenuItem_Click(Object sender, EventArgs e)
        {
            MessageBox.Show($"PointerInspector - a tool for exploring pointers and references in Rayman 2 SNA files. Any help will be appreciated.\n\nAuthor: Szymekk (szymskipl@gmail.com)\n\nMay Polokus be with you.", "PointerInspector");
        }

        private void goToByteToolStripMenuItem_Click(Object sender, EventArgs e)
        {
            var dialog = new GoToByteForm();
            dialog.ShowDialog(this);

            var positionText = dialog.Output;
            if (string.IsNullOrEmpty(positionText))
                return;

            int newPos;

            if (int.TryParse(positionText, out newPos))
                hexView1.SelectedPosition = newPos;
            else if (int.TryParse(positionText.Replace("0x", ""), NumberStyles.HexNumber, new NumberFormatInfo(), out newPos))
                hexView1.SelectedPosition = newPos;
            else
            {
                MessageBox.Show("Invalid value!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                goToByteToolStripMenuItem_Click(sender, e);
            }
        }

        private void goBackwardsToolStripMenuItem_Click(Object sender, EventArgs e)
        {
            hexView1.GoBackward();
        }

        private void goForwardToolStripMenuItem_Click(Object sender, EventArgs e)
        {
            hexView1.GoForward();
        }

        #endregion

        #region Reference list

        private void PopulateReferenceList(int position, Highlight[] highlights)
        {
            listView1.Clear();

            foreach (var highlight in highlights.Where(h => h.Type == HighlightType.ReferencedValue))
            {
                int relativePos = (int)highlight.Value - position;

                listView1.Items.Add(new ListViewItem()
                {
                    Text = $"0x{((int)highlight.Value).ToString("X8")} ({(relativePos > 0 ? "+" : "-")}{Math.Abs(relativePos)})",
                    Tag = highlight.Value
                });
            }
        }

        private void listView1_DoubleClick(Object sender, EventArgs e)
        {
            if (listView1.SelectedItems.Count == 0)
                return;

            var item = listView1.SelectedItems[0];

            hexView1.SelectedPosition = (int)item.Tag;
        }

        #endregion
    }
}
