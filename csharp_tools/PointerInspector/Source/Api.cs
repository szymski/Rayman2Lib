using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace PointerInspector.Source
{
    class Api
    {
        public struct Pointer
        {
            public int Address { get; set; }
            public int Value { get; set; }
        }

        public static Pointer[] GetPointers(string snaFile, string level0dat, long offset, long magic)
        {
            var process = new Process
            {
                StartInfo = new ProcessStartInfo()
                {
                    FileName = "rayman2lib.exe",
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    Arguments = $"snarelocation \"{snaFile}\" \"{level0dat}\" {offset} {magic}"
                }
            };

            process.OutputDataReceived += (sender, args) =>
            {
                MessageBox.Show(args.Data);
            };

            try
            {
                process.Start();
            }
            catch
            {
                MessageBox.Show("Please copy rayman2lib.exe to the current directory and restart the application.", "rayman2lib.exe not found", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Application.Exit();
            }

            var pointers = new List<Pointer>();

            using (StreamReader reader = process.StandardOutput)
            {
                while (!process.HasExited)
                {
                    var result = reader.ReadLine().Split(' ');
                    pointers.Add(new Pointer()
                    {
                        Address = int.Parse(result[0]),
                        Value = int.Parse(result[1]),
                    });
                }
            }

            return pointers.ToArray();
        }
    }
}
