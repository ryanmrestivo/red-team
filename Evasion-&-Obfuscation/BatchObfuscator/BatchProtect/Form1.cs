using FastColoredTextBoxNS;

namespace BatchProtect
{
    public partial class Form1 : Form
    {
        Style BlueStyle = new TextStyle(Brushes.DarkBlue, null, FontStyle.Bold);
        Style OrangeStyle = new TextStyle(Brushes.DarkOrange, null, FontStyle.Bold);
        Style GreenStyle = new TextStyle(Brushes.Green, null, FontStyle.Italic);
        Style TurquoiseStyle = new TextStyle(Brushes.DarkTurquoise, null, FontStyle.Bold);
        Style RedStyle = new TextStyle(Brushes.DarkRed, null, FontStyle.Bold);

        public Form1()
        {
            InitializeComponent();
        }

        private void TSMIRemoveCommentary_Click(object sender, EventArgs e)
        {
            FCTBBatchCode.SelectedText = Obfuscator.RemoveCommentary(FCTBBatchCode.SelectedText);
        }

        private void TSMIRandomVar_Click(object sender, EventArgs e)
        {
            FCTBBatchCode.SelectedText = Obfuscator.RandomVariableName(Obfuscator.RandomSubroutineName(FCTBBatchCode.SelectedText)); ;
        }

        private void TSMISubstringEncode_Click(object sender, EventArgs e)
        {
            Tuple<string, string> data = Obfuscator.SubstringEncode(FCTBBatchCode.SelectedText);
            FCTBBatchCode.SelectedText = data.Item2;
            FCTBBatchCode.Text = data.Item1 + FCTBBatchCode.Text;
        }

        private void TSMIFlowObf_Click(object sender, EventArgs e)
        {
            FCTBBatchCode.SelectedText = Obfuscator.ControlFlow(FCTBBatchCode.SelectedText);
        }

        private void FCTBBatchCode_TextChanged(object sender, FastColoredTextBoxNS.TextChangedEventArgs e)
        {
            e.ChangedRange.SetStyle(BlueStyle, @"(?i)(\W|^)(ASSOC|AT|ATTRIB|CALL|CD|CERTUTIL|CHCP|CHDIR|CHKDSK|CLS|CMDKEY|COLOR|COPY|CPROFILE|CSCRIPT|DATE|DEL|DIR|ECHO|ENDLOCAL|ERASE|EVENTCREATE|SET|EXIT|EXPAND|EXTRACT|FC|FIND|FINDSTR|FORMAT|GPRESULT|LABEL|MD|MKDIR|MKLINK|MOVE|PATH|PAUSE|PRINT|RD|REG|REGEDIT|REN|RENAME|REPLACE|RMDIR|SHUTDOWN|SORT|START|TASKKILL|TASKLIST|TIME|TITLE|TREE|TYPE|WMIC|WSCRIPT|XCOPY)(\W|$)");
            e.ChangedRange.SetStyle(OrangeStyle, @"(?i)(\W|^)(ARP|FTP|GETMAC|NBTSTAT|NET|NETSH|NETSTAT|NLTEST|NSLOOKUP|PING|PING6|POPD)(\W|$)");
            e.ChangedRange.SetStyle(GreenStyle, "REM.*$");
            e.ChangedRange.SetStyle(GreenStyle, "::.*$");
            e.ChangedRange.SetStyle(TurquoiseStyle, @"(?i)(\W|^)(IF|ELSE|FOR)(\W|$)");
            e.ChangedRange.SetStyle(RedStyle, @"(?i)(\W|^)(EQU|NEQ|LSS|LEQ|GTR|GEQ)(\W|$)");
        }

        private void FCTBBatchCode_Pasting(object sender, TextChangingEventArgs e)
        {
            e.InsertingText = Obfuscator.TrimSpace(e.InsertingText);
        }
    }
}
