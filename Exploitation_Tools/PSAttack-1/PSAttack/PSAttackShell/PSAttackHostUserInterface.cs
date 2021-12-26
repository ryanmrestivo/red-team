using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Host;
using System.Security;
using System.Text;

namespace PSAttack.PSAttackShell
{
    class PSAttackHostUserInterface : PSHostUserInterface
    {
        private PSAttackRawUserInterface PSAttackRawUI = new PSAttackRawUserInterface();

        // Function used for PromptForCredential
        private PSCredential GetCreds(string caption, string message)
        {
            Console.WriteLine(caption);
            Console.WriteLine(message);
            Console.Write("Enter Username (domain\\user): ");
            string userName = Console.ReadLine();
            Console.Write("Enter Pass: ");
            ConsoleKeyInfo info = Console.ReadKey(true);
            string password = "";
            while (info.Key != ConsoleKey.Enter)
            {
                if (info.Key != ConsoleKey.Backspace)
                {
                    Console.Write("*");
                    password += info.KeyChar;
                }
                else if (info.Key == ConsoleKey.Backspace)
                {
                    if (!string.IsNullOrEmpty(password))
                    {
                        password = password.Substring(0, password.Length - 1);
                        int pos = Console.CursorLeft;
                        Console.SetCursorPosition(pos - 1, Console.CursorTop);
                        Console.Write(" ");
                        Console.SetCursorPosition(pos - 1, Console.CursorTop);
                    }
                }
                info = Console.ReadKey(true);
            }

            SecureString secPasswd = new SecureString();
            foreach (char c in password)
            {
                secPasswd.AppendChar(c);
            }
            secPasswd.MakeReadOnly();
            return new PSCredential(userName, secPasswd);
        }
        public override PSHostRawUserInterface RawUI
        {
            get
            {
                return PSAttackRawUI;
            }
        }

        public override Dictionary<string, System.Management.Automation.PSObject> Prompt(string caption, string message, System.Collections.ObjectModel.Collection<FieldDescription> descriptions)
        {
            Dictionary<string, System.Management.Automation.PSObject> rtn = null;
            string msg = message + "\n";
            if (descriptions != null)
            {
                rtn = GetParameters(descriptions);
            }
            return rtn;
        }

        private Dictionary<string, System.Management.Automation.PSObject> GetParameters(System.Collections.ObjectModel.Collection<FieldDescription> descriptions)
        {
            Dictionary<string, System.Management.Automation.PSObject> rtn = new Dictionary<string, System.Management.Automation.PSObject>();
            PSParamType parm = new PSParamType();
            foreach (FieldDescription descr in descriptions)
            {
                PSParameter prm = new PSParameter();
                prm.Name = descr.Name;
                if (descr.IsMandatory)
                {
                    prm.Category = "Required";
                }
                else
                {
                    prm.Category = "Optional";
                }
                prm.DefaultValue = descr.DefaultValue;
                prm.Description = descr.HelpMessage;
                prm.Type = Type.GetType(descr.ParameterAssemblyFullName);
                if (prm.Name.ToLower() == "file" || prm.Name.ToLower() == "filename")
                {
                    prm.IsFileName = true;
                }
                if (prm.Name.ToLower() == "credential")
                {
                    prm.IsCredential = true;
                }
                parm.Properties.Add(prm);
            }
            return rtn;
        }

        public override void Write(ConsoleColor foregroundColor, ConsoleColor backgroundColor, string message)
        {
            Console.ForegroundColor = PSColors.outputText;
            Console.Write(message);
        }

        public override void Write(string message)
        {
            Console.ForegroundColor = PSColors.outputText;
            Console.Write(message);
        }

        public override void WriteDebugLine(string message)
        {
            Console.ForegroundColor = PSColors.debugText;
            Console.WriteLine("DEBUG: {0}", message);
            Console.ForegroundColor = PSColors.outputText;
        }

        public override void WriteErrorLine(string message)
        {
            Console.ForegroundColor = PSColors.errorText;
            Console.WriteLine("ERROR: {0}", message);
            Console.ForegroundColor = PSColors.outputText;
        }

        public override void WriteLine(string message)
        {
            Console.ForegroundColor = PSColors.outputText;
            Console.WriteLine(message);
        }

        public override void WriteVerboseLine(string message)
        {
            Console.ForegroundColor = PSColors.outputText;
            Console.WriteLine(message);
        }

        public override void WriteWarningLine(string message)
        {
            Console.ForegroundColor = PSColors.warningText;
            Console.WriteLine("WARNING: {0}", message);
            Console.ForegroundColor = PSColors.outputText;
        }

        public override void WriteProgress(long sourceId, ProgressRecord record)
        {
            return;
        }

        public override int PromptForChoice(string caption, string message, Collection<ChoiceDescription> choices, int defaultChoice)
        {
            Console.ForegroundColor = PSColors.outputText;
            Console.WriteLine(caption);
            Console.WriteLine(message);
            int choiceInt = defaultChoice;
            foreach (ChoiceDescription choice in choices)
            {
                Console.ForegroundColor = PSColors.outputText;
                if (choices.IndexOf(choice) == defaultChoice)
                {
                    Console.ForegroundColor = PSColors.warningText;
                }
                Console.WriteLine("[{0}] {1} ", choices.IndexOf(choice), choice.Label.ToString().Replace("&",""));
            }
            Console.WriteLine("Default is: {0}", choices[defaultChoice].Label.ToString().Replace("&",""));
            Console.Write("\nEnter your choice: ");
            string choiceStr = Console.ReadLine();
            choiceInt = Int32.Parse(choiceStr);
            return choiceInt;

        }

        public override PSCredential PromptForCredential(string caption, string message, string userName, string targetName)
        {
            return GetCreds(caption, message);
        }

        public override PSCredential PromptForCredential(string caption, string message, string userName, string targetName, PSCredentialTypes allowedCredentialTypes, PSCredentialUIOptions options)
        {
            return GetCreds(caption, message);
        }

        public override string ReadLine()
        {
            throw new NotImplementedException();
        }

        public override SecureString ReadLineAsSecureString()
        {
            throw new NotImplementedException();
        }
    }
}