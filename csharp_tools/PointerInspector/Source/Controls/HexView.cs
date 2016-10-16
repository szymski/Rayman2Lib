using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace PointerInspector.Source.Controls
{
    public enum HighlightType
    {
        Pointer,
        ReferencedValue,
    }

    public struct Highlight
    {
        public int Address { get; set; }
        public Color Color { get; set; }
        public int Length { get; set; }
        public HighlightType Type { get; set; }
        public object Value { get; set; }
    }

    public partial class HexView : Panel
    {
        private Graphics g;

        Font MainFont { get; set; } = new Font("Consolas", 11);
        private float fontWidth;
        private float fontHeight;

        private byte[] _data = { };

        public byte[] Data
        {
            get { return _data; }
            set
            {
                _data = value;
                UpdateScrollbar();
                UpdateHighlights();
            }
        }

        private int position = 0;

        public int Position
        {
            get { return position; }
            set
            {
                if (value >= Data.Length)
                    return;

                position = value;
                scrollBar.Value = position;
                UpdateScrollbar();
                UpdateHighlights();
                Refresh();
            }
        }

        private int selectedPosition = 0;

        public int SelectedPosition
        {
            get { return selectedPosition; }
            set {
                if (value >= Data.Length)
                    return;

                AddAddressToHistory(value);

                selectedPosition = value;

                if (selectedPosition < position || selectedPosition > position + VisibleLines * BytesInLine)
                    Position = value;

                ByteSelected?.Invoke(this, selectedPosition, currentHighlights[SelectedIndexFromFirstVisibleByte] ?? new Highlight[0]);
                Refresh();
            }
        }

        private VScrollBar scrollBar;

        public Highlight[] allHighlights = { };

        private Highlight[][] currentHighlights = { };

        public List<int> History { get; set; } = new List<int>();
        private int historyIndex = 0;

        public delegate void ByteSelectedEventHandler(object sender, int position, Highlight[] highlights);
        public event ByteSelectedEventHandler ByteSelected;

        public delegate void ByteDoubleClickEventHandler(object sender, int position, Highlight[] highlights);
        public event ByteDoubleClickEventHandler ByteDoubleClick;

        public HexView()
        {
            BackColor = Color.White;

            Init();

            InitializeComponent();
        }

        public HexView(IContainer container)
        {
            Init();

            container.Add(this);

            InitializeComponent();
        }

        private void Init()
        {
            InitScrollbar();

            DoubleBuffered = true;

            UpdateFont();
            UpdateScrollbar();
        }

        private void UpdateFont()
        {
            g = CreateGraphics();

            fontWidth = g.MeasureString("a", MainFont, 200, StringFormat.GenericTypographic).Width;
            fontHeight = g.MeasureString("a", MainFont, 200, StringFormat.GenericTypographic).Height;
        }

        private float LineHeight => fontHeight + 4;
        private int BytesInLine { get; set; } = 5;

        #region Drawing

        protected override void OnPaint(PaintEventArgs e)
        {
            g = e.Graphics;
            for (int i = 0; i < VisibleLines; i++)
            {
                var address = position + i * BytesInLine;

                var currLineBytes = Math.Min(BytesInLine, Data.Length - address);

                byte[] bytes = new byte[currLineBytes];
                Array.Copy(Data, address, bytes, 0, currLineBytes);

                if (bytes.Length == 0)
                    break;

                DrawLine(address, i * LineHeight, bytes);

                if (bytes.Length != BytesInLine)
                    break;
            }

            DrawSelection();
        }

        private void DrawLine(int address, float y, byte[] bytes)
        {
            DrawAddress(address, y);
            DrawHighlights(address, AddressWidth + BytesOffsetFromAddress, y);
            DrawBytes(AddressWidth + BytesOffsetFromAddress, y, bytes);
            DrawText(AddressWidth + BytesOffsetFromAddress + AllBytesWidth + StringOffsetFromBytes, y, bytes);
        }

        private void DrawAddress(long address, float y)
        {
            TextRenderer.DrawText(g, "0x" + ToHexString(address), MainFont, new Point(0, (int)y), Color.DodgerBlue);
        }

        private void DrawHighlights(int address, float x, float y)
        {
            for (int i = 0; i < BytesInLine; i++)
            {
                int relativeBytesFromFirstByte = address - position + i;

                if (currentHighlights.Length <= relativeBytesFromFirstByte)
                    break;

                if (currentHighlights[relativeBytesFromFirstByte] == null || currentHighlights[relativeBytesFromFirstByte].Length == 0)
                    continue;

                var highlights = currentHighlights[relativeBytesFromFirstByte];
                float heightFactor = 1f / highlights.Length;

                for (int highlightIndex = 0; highlightIndex < highlights.Length; highlightIndex++)
                {
                    var highlight = highlights[highlightIndex];

                    // Bytes

                    int byteX = (int)(x + i * ByteFullWidth);
                    int byteY = (int)y;

                    // Join the highlight
                    var shouldJoin = currentHighlights.Length >= relativeBytesFromFirstByte + i &&
                                     (currentHighlights[relativeBytesFromFirstByte + 1]?.Any(h => h.Address == highlight.Address && h.Type == highlight.Type) ?? false);

                    g.FillRectangle(new SolidBrush(highlight.Color),
                        byteX - 1, byteY + (int)Math.Ceiling(fontHeight * heightFactor * highlightIndex), (shouldJoin ? ByteFullWidth : fontWidth * 2) + 1, (int)Math.Ceiling(fontHeight * heightFactor));

                    // Characters

                    byteX = (int)(x + ByteFullWidth * BytesInLine + StringOffsetFromBytes + i * StringCharacterWidth);
                    byteY = (int)y;

                    g.FillRectangle(new SolidBrush(highlight.Color),
                        byteX - 1, byteY + (int)Math.Ceiling(fontHeight * heightFactor * highlightIndex), fontWidth + 1, (int)Math.Ceiling(fontHeight * heightFactor));
                }
            }
        }

        private void DrawBytes(float x, float y, byte[] bytes)
        {
            for (int i = 0; i < bytes.Length; i++)
                g.DrawString(bytes[i].ToString("X2"), MainFont, Brushes.Black, (int)(x + i * (fontWidth * 2 + ByteOffset)), (int)y, StringFormat.GenericTypographic);
        }

        private void DrawText(float x, float y, byte[] bytes)
        {
            g.DrawString(BytesToString(bytes), MainFont, Brushes.Black, (int)x, (int)y, StringFormat.GenericTypographic);
        }

        private void DrawSelection()
        {
            DrawByteSelection();
            DrawCharSelection();
        }

        private Brush selectionBrush = new SolidBrush(Color.FromArgb(40, 50, 200, 255));

        private void DrawByteSelection()
        {
            int x = (int)(AddressWidth + BytesOffsetFromAddress + ByteFullWidth * (selectedPosition % BytesInLine));
            int y = (int)(LineHeight * Math.Floor((selectedPosition - position) / (float)BytesInLine));

            g.FillRectangle(selectionBrush, x - 1, y, fontWidth * 2 + 1, fontHeight);
            g.DrawRectangle(Pens.CornflowerBlue, x - 1, y, fontWidth * 2 + 1, fontHeight);
        }

        private void DrawCharSelection()
        {
            int x = (int)(AddressWidth + BytesOffsetFromAddress + BytesInLine * ByteFullWidth + StringOffsetFromBytes + StringCharacterWidth * (selectedPosition % BytesInLine));
            int y = (int)(LineHeight * Math.Floor((selectedPosition - position) / (float)BytesInLine));

            g.FillRectangle(selectionBrush, x - 1, y, fontWidth + 1, fontHeight);
            g.DrawRectangle(Pens.CornflowerBlue, x - 1, y, fontWidth + 1, fontHeight);
        }

        #endregion

        #region Hex conversion

        private string ToHexString(long value)
        {
            return value.ToString("X8");
        }

        private string BytesToString(byte[] bytes)
        {
            string output = "";

            foreach (byte b in bytes)
                if (b < 32 || b > 127)
                    output += "·";
                else
                    output += (char)b;

            return output;
        }

        #endregion

        #region Calculations

        private void CalculateBytesInLine()
        {
            var left = Width - AddressWidth - BytesOffsetFromAddress - StringOffsetFromBytes - scrollBar.Width;

            left /= ByteFullWidth + StringCharacterWidth;

            BytesInLine = Math.Max(1, (int)Math.Floor(left));
        }

        private float AddressWidth => fontWidth * 10;
        private float BytesOffsetFromAddress => 32;
        private float ByteOffset => 8;
        private float ByteFullWidth => fontWidth * 2 + ByteOffset;
        private float AllBytesWidth => ByteFullWidth * BytesInLine;
        private float StringOffsetFromBytes => 32 - ByteOffset;
        private float StringCharacterWidth => fontWidth;

        private int VisibleLines => (int)Math.Ceiling(Height / LineHeight);

        private int SelectedIndexFromFirstVisibleByte => selectedPosition - position;

        private void UpdateHighlights()
        {
            int index = 0;

            for (int i = 0; i < allHighlights.Length; i++)
                if (allHighlights[i].Address >= position)
                {
                    index = i;
                    break;
                }

            int visibleBytes = VisibleLines * BytesInLine;

            currentHighlights = new Highlight[visibleBytes][];

            while (index < allHighlights.Length && allHighlights[index].Address <= position + visibleBytes)
            {
                var highlight = allHighlights[index];

                int relativeByte = highlight.Address - position;

                if (relativeByte < 0)
                    break;

                // Concatenate the highlights
                for (int i = 0; i < highlight.Length; i++)
                {
                    if (relativeByte + i >= visibleBytes)
                        break;

                    if (currentHighlights[relativeByte + i] == null)
                        currentHighlights[relativeByte + i] = new Highlight[0];

                    currentHighlights[relativeByte + i] = currentHighlights[relativeByte + i].Concat(new Highlight[] { highlight }).ToArray();
                }

                index++;
            }
        }

        public void EnsureSelectedByteVisible()
        {
            if (selectedPosition >= Data.Length)
                return;

            if (selectedPosition < position || selectedPosition > position + VisibleLines * BytesInLine)
                Position = selectedPosition;
        }

        #endregion

        #region Scroll bar

        private void InitScrollbar()
        {
            scrollBar = new VScrollBar
            {
                Parent = this,
                Dock = DockStyle.Right,
                Minimum = 0
            };

            scrollBar.ValueChanged += ScrollBar_ValueChanged;
        }

        private void UpdateScrollbar()
        {
            scrollBar.Maximum = Data.Length;
            scrollBar.SmallChange = BytesInLine;
            scrollBar.LargeChange = BytesInLine * 3;
        }

        private void ScrollBar_ValueChanged(Object sender, EventArgs e)
        {
            position = (int)Math.Floor(scrollBar.Value / (float)BytesInLine) * BytesInLine;

            UpdateHighlights();

            Refresh();
        }

        #endregion

        #region Events

        protected override void OnSizeChanged(EventArgs e)
        {
            base.OnSizeChanged(e);

            CalculateBytesInLine();
            UpdateScrollbar();
            UpdateHighlights();

            Refresh();
        }

        protected override void OnMouseWheel(MouseEventArgs e)
        {
            scrollBar.Value = Math.Max(0, Math.Min(scrollBar.Maximum, scrollBar.Value - (e.Delta > 0 ? 1 : -1) * scrollBar.LargeChange));
        }

        protected override void OnMouseClick(MouseEventArgs e)
        {
            Focus();

            HandleByteSelecting(e.X, e.Y);

            AddAddressToHistory(selectedPosition);

            ByteSelected?.Invoke(this, selectedPosition, currentHighlights[SelectedIndexFromFirstVisibleByte] ?? new Highlight[0]);

            Refresh();
        }

        protected override void OnMouseDoubleClick(MouseEventArgs e)
        {
            HandleByteSelecting(e.X, e.Y);

            ByteDoubleClick?.Invoke(this, selectedPosition, currentHighlights[SelectedIndexFromFirstVisibleByte] ?? new Highlight[0]);

            Refresh();
        }


        private void HandleByteSelecting(int clickX, int clickY)
        {
            int relativeX = (int)(clickX - AddressWidth - BytesOffsetFromAddress);
            int relativeY = clickY;

            // String character click
            if (relativeX > BytesInLine * ByteFullWidth + StringOffsetFromBytes)
            {
                relativeX -= (int)(BytesInLine * ByteFullWidth + StringOffsetFromBytes);

                int charX = (int)(relativeX / StringCharacterWidth);
                int charY = (int)(relativeY / LineHeight);

                selectedPosition = Math.Min(_data.Length - 1, charX + position + charY * BytesInLine);
            }
            // Byte click
            else
            {
                if (relativeX < 0 || relativeX >= BytesInLine * ByteFullWidth)
                    return;

                int byteX = (int)(relativeX / ByteFullWidth);
                int byteY = (int)(relativeY / LineHeight);

                selectedPosition = Math.Min(_data.Length - 1, byteX + position + byteY * BytesInLine);
            }
        }

        #endregion

        #region History

        public void AddAddressToHistory(int address)
        {
            if (History.Count > 30)
                History.RemoveAt(0);

            if (historyIndex < History.Count - 1)
            {
                History.RemoveRange(historyIndex + 1, History.Count - historyIndex - 1);
                historyIndex = History.Count;
            }
            else
                historyIndex = History.Count;

            historyIndex++;

            History.Add(address);
        }

        public void GoBackward()
        {
            if (historyIndex == 0)
                return;

            historyIndex--;

            selectedPosition = History[historyIndex];
            EnsureSelectedByteVisible();
            Refresh();

            ByteSelected?.Invoke(this, selectedPosition, currentHighlights[SelectedIndexFromFirstVisibleByte] ?? new Highlight[0]);
        }

        public void GoForward()
        {
            if (historyIndex == History.Count || historyIndex == History.Count - 1)
                return;

            historyIndex++;

            selectedPosition = History[historyIndex];
            EnsureSelectedByteVisible();
            Refresh();

            ByteSelected?.Invoke(this, selectedPosition, currentHighlights[SelectedIndexFromFirstVisibleByte] ?? new Highlight[0]);
        }

        #endregion
    }
}
