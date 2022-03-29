using PSAttack.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PSAttack.PSAttackProcessing
{
    class TabExpansion
    {
        public static AttackState Process(AttackState attackState)
        {
            if (attackState.loopType == null)
            {
                int lastSpace = attackState.displayCmd.LastIndexOf(" ");
                if (lastSpace > 0)
                {
                    // get the command that we're autocompleting for by looking for the last space and pipe
                    // anything after the last space we're going to try and autocomplete. Anything between the
                    // last pipe and last space we assume is a command. 
                    int lastPipe = attackState.displayCmd.Substring(0, lastSpace + 1).LastIndexOf("|");
                    attackState.autocompleteSeed = attackState.displayCmd.Substring(lastSpace);
                    if (lastSpace - lastPipe > 2)
                    {
                        attackState.displayCmdSeed = attackState.displayCmd.Substring(lastPipe + 1, (lastSpace - lastPipe));
                    }
                    else
                    {
                        attackState.displayCmdSeed = attackState.displayCmd.Substring(0, lastSpace);
                    }
                    // trim leading space from command in the event of "cmd | cmd"
                    if (attackState.displayCmdSeed.IndexOf(" ").Equals(0))
                    {
                        attackState.displayCmdSeed = attackState.displayCmd.Substring(1, lastSpace);
                    }
                }
                else
                {
                    attackState.autocompleteSeed = attackState.displayCmd;
                    attackState.displayCmdSeed = "";
                }
                if (attackState.autocompleteSeed.Length == 0)
                {
                    return attackState;
                }

                // route to appropriate autcomplete handler
                if (attackState.autocompleteSeed.Contains(" -"))
                {
                    attackState = paramAutoComplete(attackState);
                }
                else if (attackState.autocompleteSeed.Contains("$"))
                {
                    attackState = variableAutoComplete(attackState);
                }
                else if (attackState.autocompleteSeed.Contains(":") || attackState.autocompleteSeed.Contains("\\"))
                {
                    attackState = pathAutoComplete(attackState);
                }
                else
                {
                    attackState = cmdAutoComplete(attackState);
                }
            }
            // If we're already in an autocomplete loop, increment loopPos appropriately
            else if (attackState.loopType != null)
            {
                if (attackState.keyInfo.Modifiers == ConsoleModifiers.Shift)
                {
                    attackState.loopPos -= 1;
                    // loop around if we're at the beginning
                    if (attackState.loopPos < 0)
                    {
                        attackState.loopPos = attackState.results.Count - 1;
                    }
                }
                else
                {
                    attackState.loopPos += 1;
                    // loop around if we reach the end
                    if (attackState.loopPos >= attackState.results.Count)
                    {
                        attackState.loopPos = 0;
                    }
                }
            }

            // if we have results, format them and return them
            if (attackState.results.Count > 0)
            {
                string seperator = "";
                string result;
                switch (attackState.loopType)
                {
                    case "param":
                        seperator = "-";
                        result = attackState.results[attackState.loopPos].ToString();
                        break;
                    case "variable":
                        seperator = "$";
                        result = attackState.results[attackState.loopPos].Members["Name"].Value.ToString();
                        break;
                    case "path":
                        result = attackState.results[attackState.loopPos].Members["FullName"].Value.ToString();
                        break;
                    default:
                        result = attackState.results[attackState.loopPos].BaseObject.ToString();
                        break;
                }
                attackState.displayCmd = attackState.displayCmdSeed + seperator + result;
                attackState.cursorPos = attackState.endOfDisplayCmdPos();
            }
            return attackState;
        }

        // PARAMETER AUTOCOMPLETE
        static AttackState paramAutoComplete(AttackState attackState)
        {
            attackState.loopType = "param";
            int lastParam = attackState.displayCmd.LastIndexOf(" -");
            string paramSeed = attackState.displayCmd.Substring(lastParam).Replace(" -", "");
            int firstSpace = attackState.displayCmd.IndexOf(" ");
            string paramCmd = attackState.displayCmdSeed.Substring(0, firstSpace);
            attackState.cmd = "(Get-Command " + paramCmd + ").Parameters.Keys | Where{$_ -like '" + paramSeed + "*'}";
            attackState = Processing.PSExec(attackState);
            return attackState;
        }

        // VARIABLE AUTOCOMPLETE
        static AttackState variableAutoComplete(AttackState attackState)
        {
            attackState.loopType = "variable";
            string variableSeed = attackState.autocompleteSeed.Replace("$", "");
            attackState.cmd = "Get-Variable " + variableSeed + "*";
            attackState = Processing.PSExec(attackState);
            return attackState;
        }

        // PATH AUTOCOMPLETE
        static AttackState pathAutoComplete(AttackState attackState)
        {
            attackState.loopType = "path";
            attackState.cmd = "Get-ChildItem " + attackState.autocompleteSeed + "*";
            attackState = Processing.PSExec(attackState);
            return attackState;
        }
                
        // COMMAND AUTOCOMPLETE
        static AttackState cmdAutoComplete(AttackState attackState)
        {
            attackState.loopType = "cmd";
            attackState.cmd = "Get-Command " + attackState.autocompleteSeed + "*";
            attackState = Processing.PSExec(attackState);
            return attackState;
        }

    }
}
