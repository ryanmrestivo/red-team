using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PSAttack.PSAttackShell;
using PSAttack.PSAttackProcessing;


namespace PSAttack.Utils
{
    class Display
    {
        public static string createPrompt(AttackState attackState)
        {
            string prompt = attackState.runspace.SessionStateProxy.Path.CurrentLocation + " #> ";
            return prompt;
        }
        

        public static void Output(AttackState attackState)
        {
            if (attackState.cmdComplete)
            {
                printPrompt(attackState);
            }
            int currentCusorPos = Console.CursorTop;
            string prompt = createPrompt(attackState);
            Console.SetCursorPosition(prompt.Length, attackState.promptPos);
            Console.Write(new string(' ', Console.WindowWidth));
            int cursorDiff = currentCusorPos - attackState.promptPos;
            while (cursorDiff > 0)
            {
                Console.SetCursorPosition(0, attackState.promptPos + cursorDiff);
                Console.Write(new string(' ', Console.WindowWidth));
                cursorDiff -= 1;
            }
            Console.SetCursorPosition(prompt.Length, attackState.promptPos);
            Console.Write(attackState.displayCmd);
            int consoleWrapCount = attackState.consoleWrapCount();
            int relativeCursorPos = attackState.relativeCursorPos();
            if (attackState.cursorPos >= Console.WindowWidth)
            {
                attackState.cursorPos = attackState.cursorPos - Console.WindowWidth * consoleWrapCount;
            }
            Console.SetCursorPosition(attackState.cursorPos, attackState.promptPos + consoleWrapCount);
        }

        public static void Exception(AttackState attackState, string errorMsg)
        {
            Console.ForegroundColor = PSColors.errorText;
            Console.WriteLine("ERROR: {0}\n", errorMsg);
        }

        public static void printPrompt(AttackState attackState)
        {
            attackState.promptPos = Console.CursorTop;
            string prompt = createPrompt(attackState);
            Console.ForegroundColor = PSColors.prompt;
            Console.Write(prompt);
            Console.ForegroundColor = PSColors.inputText;
            attackState.cursorPos = prompt.Length;
        }
    }
}
