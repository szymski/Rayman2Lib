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
            if (openFileDialog1.ShowDialog() == DialogResult.OK && File.Exists(openFileDialog1.FileName))
            {
                BNMFile bnm = new BNMFile(File.ReadAllBytes(openFileDialog1.FileName));

                var fileInfo = new FileInfo(openFileDialog1.FileName);
                var dir = fileInfo.DirectoryName + "/" + fileInfo.Name.Replace(".bnm", "");

                Directory.CreateDirectory(dir);

                int file = 0;
                foreach (var soundFile in bnm.soundFiles)
                {
                    var filename = dir + "/" + (addIndexCheckBox.Checked ? file++ + "_" : "") + soundFile.name;

                    if (File.Exists(filename))
                        File.Delete(filename);
                    soundFile.Save(File.Create(filename));
                }

                Process.Start(dir);
            }
        }
    }
}
