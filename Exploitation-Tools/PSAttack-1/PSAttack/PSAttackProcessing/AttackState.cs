using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using PSAttack.PSAttackShell;
using PSAttack.Utils;

namespace PSAttack.PSAttackProcessing
{
    class AttackState
    {
        // Powershell runsapce and host
        public Runspace runspace { get; set; }
        public PSAttackHost host { get; set; }

        // contents of cmd are what are executed
        public string cmd { get; set; }

        // contents of displayCmd are what are shown on screen as the command
        public string displayCmd { get; set; }
        
        // string to run autocomplete against
        public string autocompleteSeed { get; set; }

        // string to store displayCmd for autocomplete concatenation
        public string displayCmdSeed { get; set; }

        // key that was last pressed
        public ConsoleKeyInfo keyInfo { get; set; }
        
        // we set a loopPos for when we're in a tab-complete loop
        public int loopPos { get; set; }

        // The vertical position of the last prompt printed. Used so we know where to start re-writing commands
        public int promptPos { get; set; }

        // cusor position
        public int cursorPos { get; set; }
        
        // loop states
        public string loopType { get; set; }
        
        // ouput is what's print to screen
        public string output { get; set; }
        
        // used for auto-complete loops
        public Collection<PSObject> results { get; set; }

        // set once execution of a command has completed, breaks the while loop in main.
        public bool cmdComplete { get; set; }

        // used to store command history
        public List<string> history { get; set; }

        // returns total length of display cmd + prompt. Used to check for text wrap in 
        // so we know what to do with our cursor
        public int totalDisplayLength()
        {
            return Display.createPrompt(this).Length + this.displayCmd.Length;
        }

        public int consoleWrapCount()
        {
            return Console.CursorTop - this.promptPos;
        }

        // return cursor pos ignoring window wrapping
        public int relativeCursorPos()
        {
            int wrapCount = this.consoleWrapCount();
            if (wrapCount > 0)
            {
                return this.cursorPos + Console.WindowWidth * wrapCount;
            }
            return this.cursorPos;
        }

        // return relative cusor pos without prompt
        public int relativeCmdCursorPos()
        {
            int promptLength = Display.createPrompt(this).Length;
            return this.relativeCursorPos() - promptLength;
        }

        // return end of displayCmd accounting for prompt
        public int endOfDisplayCmdPos()
        {
            return Display.createPrompt(this).Length + this.displayCmd.Length;
        }

        // clear out cruft from autocomplete loops
        public void ClearLoop()
        {
            this.loopType = null;
            this.results = null;
            this.autocompleteSeed = null;
            this.displayCmdSeed = null;
            this.loopPos = 0;
        }

        // clear out cruft from working with commands
        public void ClearIO(bool display=false)
        {
            if (display == true)
            {
                this.displayCmd = "";
            }
            this.cmd = "";
            this.keyInfo = new ConsoleKeyInfo();
            this.cmdComplete = false;
            this.output = null;
        }

        public AttackState()
        {
            // init host and runspace
            this.host = new PSAttackHost();
            Runspace runspace = RunspaceFactory.CreateRunspace(this.host);
            runspace.Open();
            this.runspace = runspace;
            // init history
            this.history = new List<string>();
            // hack to keep cmd from being null. others parts of psa don't appreciate that.
            this.cmd = "";
            this.displayCmd = "";
        }
    }
}
