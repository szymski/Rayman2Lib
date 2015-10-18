using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Windows.Forms;
using Rayman2Lib;

namespace CNTExplorer
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            //LoadCNT(@"D:\GOG Games\Rayman 2\Data\Textures.cnt");
        }

        CNTFile cnt;
        Dictionary<string, int> iconCache = new Dictionary<string, int>();

        void LoadCNT(string filename)
        {
            cnt = CNTFile.LoadFromFile(filename);

            curDir = "\\";
            UpdateDirectory();
        }

        string curDir = "\\";

        void UpdateDirectory()
        {
            dirTextBox.Text = curDir;
            listView.Clear();

            foreach (var directory in GetDirectories(curDir).Select(d => d.Split('\\').Last()))
            {
                listView.Items.Add(new ListViewItem()
                {
                    Tag = new Tuple<string, object>("dir", directory),
                    Text = directory,
                    ImageIndex = 0
                });
            }

            foreach (var file in GetFiles(curDir))
            {
                if (!iconCache.ContainsKey(file.directory + "\\" + file.name))
                {
                    iconList.Images.Add(GFFile.LoadFromBytes(cnt.GetFileBytes(file.directory + "\\" + file.name)).GetBitmap());
                    iconCache.Add(file.directory + "\\" + file.name, iconList.Images.Count - 1);
                }

                listView.Items.Add(new ListViewItem()
                {
                    Tag = new Tuple<string, object>("file", file),
                    Text = file.name,
                    ImageIndex = iconCache[file.directory + "\\" + file.name]
                });
            }
        }

        IEnumerable<string> GetDirectories(string path)
        {
            string pPath = path.Substring(1);
            return cnt.directoryList.Where(d => d.IndexOf(pPath) == 0 && d.Split('\\').Length == pPath.Split('\\').Length);
        }

        IEnumerable<CNTFile.FileStruct> GetFiles(string path)
        {
            string pPath = path.Substring(1);
            pPath = pPath.Substring(0, pPath.Length > 1 ? pPath.Length - 1 : 0);
            return cnt.fileList.Where(d => d.directory == pPath);
        }

        private void listView_MouseDoubleClick(object sender, MouseEventArgs e)
        {
            if (listView.SelectedItems.Count == 0)
                return;

            var item = listView.SelectedItems[0];
            var tag = (Tuple<string, object>)item.Tag;

            if (tag.Item1 == "dir")
            {
                curDir += (string)tag.Item2 + "\\";
                UpdateDirectory();
            }
            else if (tag.Item1 == "file")
            {
                new GFView(cnt.GetFileBytes(((CNTFile.FileStruct)tag.Item2).directory + "\\" + ((CNTFile.FileStruct)tag.Item2).name)).ShowDialog(this);
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (curDir == "\\")
                return;

            curDir = curDir.Substring(0, curDir.Substring(0, curDir.Length - 1).LastIndexOf("\\") + 1);
            UpdateDirectory();
        }

        private void saveFileMenuStripBtn_Click(object sender, EventArgs e)
        {
            if (listView.SelectedItems.Count == 0)
                return;

            var item = listView.SelectedItems[0];
            var tag = (Tuple<string, object>)item.Tag;

            if (tag.Item1 != "file")
                return;

            var file = (CNTFile.FileStruct)tag.Item2;

            SaveFileDialog dialog = new SaveFileDialog()
            {
                Filter = "Bitmap|*.bmp"
            };

            dialog.FileOk += (o, args) => GFFile.LoadFromBytes(cnt.GetFileBytes(file.directory + "\\" + file.name)).GetBitmap().Save(dialog.FileName);

            dialog.ShowDialog();
        }

        private void viewFileMenuStripBtn_Click(object sender, EventArgs e)
        {
            if (listView.SelectedItems.Count == 0)
                return;

            var item = listView.SelectedItems[0];
            var tag = (Tuple<string, object>)item.Tag;

            if (tag.Item1 != "file")
                return;

            var file = (CNTFile.FileStruct)tag.Item2;

            new GFView(cnt.GetFileBytes(file.directory + "\\" + file.name)).ShowDialog(this);
        }

        private void listView_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button != MouseButtons.Right)
                return;

            if (listView.SelectedItems.Count == 0)
                return;

            var item = listView.SelectedItems[0];
            var tag = (Tuple<string, object>)item.Tag;

            switch (tag.Item1)
            {
                case "file":
                    fileMenuStrip.Show(MousePosition);
                    break;
            }
        }

        private void openToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OpenFileDialog dialog = new OpenFileDialog()
            {
                Filter = "CNT archive|*.cnt"
            };

            dialog.FileOk += (o, args) => LoadCNT(dialog.FileName);

            dialog.ShowDialog();
        }

        private void file_DragEnter(object sender, DragEventArgs e)
        {
            if (e.Data.GetDataPresent(DataFormats.FileDrop))
                e.Effect = DragDropEffects.Copy;
        }

        private void file_DragDrop(object sender, DragEventArgs e)
        {
            string[] files = (string[])e.Data.GetData(DataFormats.FileDrop);
            if (files.Length > 0)
            {
                string dragFilename = files[0];
                LoadCNT(dragFilename);
            }
        }

        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            MessageBox.Show("A tool made with love for Rayman 2 fans.\nSoon, it will be possible to modify textures.\n\nBy Szymekk.");
        }
    }
}
