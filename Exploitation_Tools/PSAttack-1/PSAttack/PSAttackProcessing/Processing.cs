using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections.ObjectModel;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using PSAttack.PSAttackShell;
using PSAttack.Utils;

namespace PSAttack.PSAttackProcessing
{
    class Processing
    {
        // This is called everytime a key is pressed.
        public static AttackState CommandProcessor(AttackState attackState)
        {
            attackState.output = null;
            int relativePos = attackState.relativeCursorPos();
            int cmdLength = attackState.displayCmd.Length;
            /////////////////////////
            // BACKSPACE OR DELETE //
            /////////////////////////
            if (attackState.keyInfo.Key == ConsoleKey.Backspace || attackState.keyInfo.Key == ConsoleKey.Delete)
            {
                attackState.ClearLoop();
                if (attackState.displayCmd != "" && attackState.relativeCursorPos() > 0)
                {
                    if (attackState.keyInfo.Key == ConsoleKey.Backspace)
                    {
                        attackState.cursorPos -= 1;
                    }
                    List<char> displayCmd = attackState.displayCmd.ToList();
                    int relativeCursorPos = attackState.relativeCmdCursorPos();
                    displayCmd.RemoveAt(relativeCursorPos);
                    attackState.displayCmd = new string(displayCmd.ToArray());
                }
            }
            /////////////////////////
            // BACKSPACE OR DELETE //
            /////////////////////////
            else if (attackState.keyInfo.Key == ConsoleKey.Home || attackState.keyInfo.Key == ConsoleKey.End)
            {
                if (attackState.keyInfo.Key == ConsoleKey.Home)
                {
                    attackState.cursorPos = Display.createPrompt(attackState).Length;
                }
                else
                {
                    attackState.cursorPos = Display.createPrompt(attackState).Length + attackState.displayCmd.Length;
                }
            }
            ////////////////
            // UP OR DOWN //
            ////////////////
            else if (attackState.keyInfo.Key == ConsoleKey.UpArrow || attackState.keyInfo.Key == ConsoleKey.DownArrow)
            {
                return history(attackState);
            }
            ///////////////////
            // LEFT OR RIGHT //
            ///////////////////

            // TODO: Fix arrows navigating between wrapped command lines
            else if (attackState.keyInfo.Key == ConsoleKey.LeftArrow)
            {
                if (attackState.relativeCmdCursorPos() > 0)
                {
                    attackState.cursorPos -= 1;
                }
                return attackState;
            }
            else if (attackState.keyInfo.Key == ConsoleKey.RightArrow)
            {
                if (attackState.relativeCmdCursorPos() < attackState.displayCmd.Length)
                {
                    attackState.cursorPos += 1;
                }
                return attackState;
            }
            ///////////
            // ENTER //
            ///////////
            else if (attackState.keyInfo.Key == ConsoleKey.Enter)
            {
                Console.WriteLine("\n");
                attackState.ClearLoop();
                attackState.cmd = attackState.displayCmd;
                // don't add blank lines to history
                if (attackState.cmd != "")
                {
                    attackState.history.Add(attackState.cmd);
                }
                if (attackState.cmd == "exit")
                {
                    System.Environment.Exit(0);
                }
                else if (attackState.cmd == "clear")
                {
                    Console.Clear();
                    attackState.displayCmd = "";
                    Display.printPrompt(attackState);

                }
                // TODO: Make this better.
                else if (attackState.cmd.Contains(".exe"))
                {
                    attackState.cmd = "Start-Process -NoNewWindow -Wait " + attackState.cmd;
                    attackState = Processing.PSExec(attackState);
                    Display.Output(attackState);
                }
                // assume that we just want to execute whatever makes it here.
                else
                {
                    attackState = Processing.PSExec(attackState);
                    Display.Output(attackState);
                }
                // clear out cmd related stuff from state
                attackState.ClearIO(display:true);
            }
            /////////
            // TAB //
            /////////
            else if (attackState.keyInfo.Key == ConsoleKey.Tab)
            {
               return TabExpansion.Process(attackState);
            }
            //////////
            // if nothing matched, lets assume its a character and add it to displayCmd
            //////////
            else
            {
                attackState.ClearLoop();
                attackState.cursorPos += 1;
                // reset cursorpos if wrap
                if (attackState.cursorPos >= Console.WindowWidth)
                {
                    attackState.cursorPos = attackState.cursorPos - Console.WindowWidth;
                }
                // figure out where to insert the typed character
                List<char> displayCmd = attackState.displayCmd.ToList();
                int relativeCmdCursorPos = attackState.relativeCmdCursorPos();
                displayCmd.Insert(attackState.relativeCmdCursorPos() - 1, attackState.keyInfo.KeyChar);
                attackState.displayCmd = new string(displayCmd.ToArray());
            }
            return attackState;
        }

        // called when up or down is entered
        static AttackState history(AttackState attackState)
        {
            if (attackState.history.Count > 0)
            {
                if (attackState.loopType == null)
                {
                    attackState.loopType = "history";
                    if (attackState.loopPos == 0)
                    {
                        attackState.loopPos = attackState.history.Count;

                    }
                }
                if (attackState.keyInfo.Key == ConsoleKey.UpArrow && attackState.loopPos > 0)
                {
                    attackState.loopPos -= 1;
                    attackState.displayCmd = attackState.history[attackState.loopPos];

                }
                if (attackState.keyInfo.Key == ConsoleKey.DownArrow)
                {

                    if ((attackState.loopPos + 1) > (attackState.history.Count - 1))
                    {
                        attackState.displayCmd = "";
                    }
                    else
                    {
                        attackState.loopPos += 1;
                        attackState.displayCmd = attackState.history[attackState.loopPos];
                    }
                }
                attackState.cursorPos = attackState.endOfDisplayCmdPos();
            }
            return attackState;
        }

        // Here is where we execute posh code
        public static AttackState PSExec(AttackState attackState)
        {
            using (Pipeline pipeline = attackState.runspace.CreatePipeline())
            {
                pipeline.Commands.AddScript(attackState.cmd);
                // If we're in an auto-complete loop, we want the PSObjects, not the string from the output of the command
                // TODO: clean this up
                if (attackState.loopType != null)
                {
                    pipeline.Commands[0].MergeMyResults(PipelineResultTypes.Error, PipelineResultTypes.Output);
                }
                else
                {
                    pipeline.Commands[0].MergeMyResults(PipelineResultTypes.Error, PipelineResultTypes.Output); pipeline.Commands.Add("out-default");
                }
                try
                {
                    attackState.results = pipeline.Invoke();
                }
                catch (Exception e)
                {
                    attackState.results = null;
                    Display.Exception(attackState, e.Message);
                }

                pipeline.Dispose();
            }
            //Clear out command so it doesn't get echo'd out to console again.
            attackState.ClearIO();
            if (attackState.loopType == null)
            {
                attackState.cmdComplete = true;
            }
            return attackState;
        }
    }

}