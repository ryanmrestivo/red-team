namespace BatchProtect
{
    partial class Form1
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.contextMenu = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.TSMIRemoveCommentary = new System.Windows.Forms.ToolStripMenuItem();
            this.TSMIRandomVarSub = new System.Windows.Forms.ToolStripMenuItem();
            this.TSMISubstringEncode = new System.Windows.Forms.ToolStripMenuItem();
            this.TSMIFlowObf = new System.Windows.Forms.ToolStripMenuItem();
            this.FCTBBatchCode = new FastColoredTextBoxNS.FastColoredTextBox();
            this.contextMenu.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.FCTBBatchCode)).BeginInit();
            this.SuspendLayout();
            // 
            // contextMenu
            // 
            this.contextMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.TSMIRemoveCommentary,
            this.TSMIRandomVarSub,
            this.TSMISubstringEncode,
            this.TSMIFlowObf});
            this.contextMenu.Name = "contextMenuStrip1";
            this.contextMenu.ShowImageMargin = false;
            this.contextMenu.Size = new System.Drawing.Size(274, 92);
            // 
            // TSMIRemoveCommentary
            // 
            this.TSMIRemoveCommentary.Name = "TSMIRemoveCommentary";
            this.TSMIRemoveCommentary.Size = new System.Drawing.Size(273, 22);
            this.TSMIRemoveCommentary.Text = "Remove comments";
            this.TSMIRemoveCommentary.Click += new System.EventHandler(this.TSMIRemoveCommentary_Click);
            // 
            // TSMIRandomVarSub
            // 
            this.TSMIRandomVarSub.Name = "TSMIRandomVarSub";
            this.TSMIRandomVarSub.Size = new System.Drawing.Size(273, 22);
            this.TSMIRandomVarSub.Text = "Randomize variables and subroutines names";
            this.TSMIRandomVarSub.Click += new System.EventHandler(this.TSMIRandomVar_Click);
            // 
            // TSMISubstringEncode
            // 
            this.TSMISubstringEncode.Name = "TSMISubstringEncode";
            this.TSMISubstringEncode.Size = new System.Drawing.Size(273, 22);
            this.TSMISubstringEncode.Text = "Custom substrings encoding";
            this.TSMISubstringEncode.Click += new System.EventHandler(this.TSMISubstringEncode_Click);
            // 
            // TSMIFlowObf
            // 
            this.TSMIFlowObf.Name = "TSMIFlowObf";
            this.TSMIFlowObf.Size = new System.Drawing.Size(273, 22);
            this.TSMIFlowObf.Text = "Obfuscate flow";
            this.TSMIFlowObf.Click += new System.EventHandler(this.TSMIFlowObf_Click);
            // 
            // FCTBBatchCode
            // 
            this.FCTBBatchCode.AllowMacroRecording = false;
            this.FCTBBatchCode.AutoCompleteBracketsList = new char[] {
        '(',
        ')',
        '{',
        '}',
        '[',
        ']',
        '\"',
        '\"',
        '\'',
        '\''};
            this.FCTBBatchCode.AutoIndentCharsPatterns = "\r\n^\\s*\\$[\\w\\.\\[\\]\\\'\\\"]+\\s*(?<range>=)\\s*(?<range>[^;]+);\r\n";
            this.FCTBBatchCode.AutoScrollMinSize = new System.Drawing.Size(227, 14);
            this.FCTBBatchCode.BackBrush = null;
            this.FCTBBatchCode.BracketsHighlightStrategy = FastColoredTextBoxNS.BracketsHighlightStrategy.Strategy2;
            this.FCTBBatchCode.CharHeight = 14;
            this.FCTBBatchCode.CharWidth = 8;
            this.FCTBBatchCode.ContextMenuStrip = this.contextMenu;
            this.FCTBBatchCode.Cursor = System.Windows.Forms.Cursors.IBeam;
            this.FCTBBatchCode.DisabledColor = System.Drawing.Color.FromArgb(((int)(((byte)(100)))), ((int)(((byte)(180)))), ((int)(((byte)(180)))), ((int)(((byte)(180)))));
            this.FCTBBatchCode.Dock = System.Windows.Forms.DockStyle.Fill;
            this.FCTBBatchCode.IsReplaceMode = false;
            this.FCTBBatchCode.LeftBracket = '(';
            this.FCTBBatchCode.LeftBracket2 = '{';
            this.FCTBBatchCode.Location = new System.Drawing.Point(0, 0);
            this.FCTBBatchCode.Name = "FCTBBatchCode";
            this.FCTBBatchCode.Paddings = new System.Windows.Forms.Padding(0);
            this.FCTBBatchCode.RightBracket = ')';
            this.FCTBBatchCode.RightBracket2 = '}';
            this.FCTBBatchCode.SelectionColor = System.Drawing.Color.FromArgb(((int)(((byte)(60)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(255)))));
            this.FCTBBatchCode.ServiceColors = ((FastColoredTextBoxNS.ServiceColors)(resources.GetObject("FCTBBatchCode.ServiceColors")));
            this.FCTBBatchCode.Size = new System.Drawing.Size(637, 369);
            this.FCTBBatchCode.TabIndex = 1;
            this.FCTBBatchCode.Text = "REM Batch Code Obfuscator github.com/guillaC";
            this.FCTBBatchCode.Zoom = 100;
            this.FCTBBatchCode.TextChanged += new System.EventHandler<FastColoredTextBoxNS.TextChangedEventArgs>(this.FCTBBatchCode_TextChanged);
            this.FCTBBatchCode.Pasting += new System.EventHandler<FastColoredTextBoxNS.TextChangingEventArgs>(this.FCTBBatchCode_Pasting);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(637, 369);
            this.Controls.Add(this.FCTBBatchCode);
            this.Name = "Form1";
            this.Text = "Batch Code Obfuscator";
            this.contextMenu.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.FCTBBatchCode)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private ContextMenuStrip contextMenu;
        private FastColoredTextBoxNS.FastColoredTextBox FCTBBatchCode;
        private ToolStripMenuItem TSMIRemoveCommentary;
        private ToolStripMenuItem TSMIRandomVarSub;
        private ToolStripMenuItem TSMISubstringEncode;
        private ToolStripMenuItem TSMIFlowObf;
    }
}
