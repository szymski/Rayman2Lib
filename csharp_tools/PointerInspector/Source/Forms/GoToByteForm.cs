using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace PointerInspector.Source.Forms
{
    public partial class GoToByteForm : Form
    {
        public string Output { get; private set; }

        public GoToByteForm()
        {
            InitializeComponent();
        }

        private void GoToByteForm_Load(Object sender, EventArgs e)
        {
            textBox1.Focus();
        }

        private void textBox1_KeyDown(Object sender, KeyEventArgs e)
        {
            if(e.KeyCode == Keys.Enter)
                button1.PerformClick();
        }

        private void button1_Click(Object sender, EventArgs e)
        {
            Output = textBox1.Text;
            Close();
        }
    }
}
