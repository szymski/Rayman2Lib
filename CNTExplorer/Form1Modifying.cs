using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Rayman2Lib;

namespace CNTExplorer
{
    public partial class Form1 : Form
    {
        public Dictionary<string, CNTFile.FileStruct> watchedFiles = new Dictionary<string, CNTFile.FileStruct>();
        //public List<Tuple<>> 

        void RegisterFileWatcher()
        {
            FileSystemWatcher watcher = new FileSystemWatcher(tempFolder);

            watcher.Changed += (o, args) =>
            {
                if (watchedFiles.ContainsKey(args.FullPath))
                {
                    Invoke(new Action(() =>
                    {
                        cnt.fileList.Remove(watchedFiles[args.FullPath]);

                        UpdateDirectory();
                    }));
                }
            };

            watcher.EnableRaisingEvents = true;
        }

        private void modifyToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (listView.SelectedItems.Count == 0)
                return;

            var item = listView.SelectedItems[0];
            var tag = (Tuple<string, object>)item.Tag;

            if (tag.Item1 != "file")
                return;

            var file = (CNTFile.FileStruct)tag.Item2;

            string bitmapName = tempFolder + "\\" + file.name + ".bmp";
            GFFile.LoadFromBytes(cnt.GetFileBytes(file.directory + "\\" + file.name)).GetBitmap().Save(bitmapName);
            Process.Start("explorer.exe", $"/select, \"{bitmapName}\"");

            if (watchedFiles.ContainsKey(bitmapName))
                return;

            watchedFiles.Add(bitmapName, file);
        }
    }
}
