using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Rayman2Lib;

namespace BNKReader
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        private void decodeButton_Click(object sender, EventArgs e)
        {
            openFileDialog1.Multiselect = true;
            if (openFileDialog1.ShowDialog() == DialogResult.OK) {
                string dir = "";
                foreach (var fileName in openFileDialog1.FileNames) {
                    if (File.Exists(fileName)) {
                        BNMFile bnm = new BNMFile(File.ReadAllBytes(fileName));

                        var fileInfo = new FileInfo(fileName);
                        dir = Path.Combine(fileInfo.DirectoryName, fileInfo.Name.Replace(".bnm", ""));

                        Directory.CreateDirectory(dir);

                        int file = 0;
                        foreach (var soundFile in bnm.soundFiles) {
                            var filename = Path.Combine(dir, (addIndexCheckBox.Checked ? file++ + "_" : "") + soundFile.name);

                            if (File.Exists(filename))
                                File.Delete(filename);
                            soundFile.Save(File.Create(filename));
                        }
                    }
                }

                ProcessStartInfo startInfo = new ProcessStartInfo(dir);
                startInfo.UseShellExecute = true;

                Process.Start(startInfo);
            }
        }
    }
}
