using Microsoft.CSharp;
using System.CodeDom.Compiler;
using System.Collections.Generic;
using System.Windows.Forms;
using System.IO;
using System;

namespace LimeDownloader
{
    class Compiler
    {
        private static readonly string[] referencedAssemblies = new string[]
        {
            "System.dll",
            "System.Windows.Forms.dll",
            "System.Drawing.dll",
            "Microsoft.VisualBasic.dll"
        };

        public static bool CompileFromSource(string source, string outputAssembly, string sourceIconPath = null)
        {
            var destinationIconPath = Environment.CurrentDirectory + "\\icon.ico";

            var providerOptions = new Dictionary<string, string>() {
                {"CompilerVersion", "v4.0" }
            };

            var compilerOptions = "/target:winexe /platform:anycpu /optimize";
            if (sourceIconPath != null)
            {
                File.Copy(sourceIconPath, destinationIconPath, true);
                compilerOptions += $" /win32icon:\"{destinationIconPath}\"";
            }

            using (var cSharpCodeProvider = new CSharpCodeProvider(providerOptions))
            {
                var compilerParameters = new CompilerParameters(referencedAssemblies)
                {
                    GenerateExecutable = true,
                    OutputAssembly = outputAssembly,
                    CompilerOptions = compilerOptions,
                    TreatWarningsAsErrors = false,
                    IncludeDebugInformation = false,
                };
                var compilerResults = cSharpCodeProvider.CompileAssemblyFromSource(compilerParameters, source);

                if (compilerResults.Errors.Count > 0)
                {
                    MessageBox.Show(string.Format("The compiler has encountered {0} errors",
                         compilerResults.Errors.Count), "Errors while compiling", MessageBoxButtons.OK,
                         MessageBoxIcon.Error);

                    foreach (CompilerError compilerError in compilerResults.Errors)
                    {
                        MessageBox.Show(string.Format("{0}\nLine: {1} - Column: {2}\nFile: {3}", compilerError.ErrorText,
                            compilerError.Line, compilerError.Column, compilerError.FileName), "Error",
                            MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }

                File.Delete(destinationIconPath);
                return compilerResults.Errors.Count == 0;
            }
        }
    }
}
