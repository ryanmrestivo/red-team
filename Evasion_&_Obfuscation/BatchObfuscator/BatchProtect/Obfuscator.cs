using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.RegularExpressions;

namespace BatchProtect
{
    public static class Obfuscator
    {

        private static Random random = new Random();
        public static string GetRandomString(int length = 10, bool special = true)
        {
            string chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
            if (special) chars = "阿贝色德饿艾豆贝尔维埃克斯爱耻";
            return new string(Enumerable.Repeat(chars, length).Select(s => s[random.Next(s.Length)]).ToArray());
        }

        public static string OneLineIF(string code)
        {
            string[] splittedCode = code.Split(new[] { "\r\n", "\n", "\r" }, StringSplitOptions.RemoveEmptyEntries);
            bool inIf = false;
            code = "";

            for (int i = 0; i < splittedCode.Length; i++)
            {
                if (splittedCode[i].Contains("(")) inIf = true;
                if (splittedCode[i].Contains(")") && !splittedCode[i].ToUpper().Contains("ELSE")) inIf = false;
                if (inIf)
                {
                    code += splittedCode[i];
                    if (splittedCode.Length > i + 1 && splittedCode[i + 1].Contains(")")) continue;
                    if (splittedCode[i].Contains("(")) continue;
                    code += " && ";
                }
                if (!inIf) code += splittedCode[i] + Environment.NewLine;
            }
            return code;
        }

        public static string TrimSpace(string code)
        {
            string[] splittedCode = code.Split(new[] { "\r\n", "\n", "\r" }, StringSplitOptions.RemoveEmptyEntries);
            code = "";
            foreach (string line in splittedCode) code += line.TrimStart(' ', '\t') + Environment.NewLine;
            return code;
        }

        public static string RemoveCommentary(string code)
        {
            string[] splittedCode = code.Split(new[] { "\r\n", "\n", "\r" }, StringSplitOptions.RemoveEmptyEntries);
            code = "";
            foreach (string line in splittedCode)
            {
                if (line.Length > 2 && line.Substring(0, 3).ToUpper() != "REM" && line.Substring(0, 2) != "::")
                {
                    code += line + Environment.NewLine;
                }
            }
            return code;
        }

        public static List<String> getVariables(string code)
        {
            string[] splittedCode = code.Split(new[] { "\r\n", "\n", "\r" }, StringSplitOptions.RemoveEmptyEntries);
            List<String> variables = new List<String>();

            foreach (string line in splittedCode)
            {
                if (line.Length >= 3 && line.ToUpper().Contains("SET ") && line.Contains("="))
                {
                    string clearLine = line.Replace(" =", "=").Replace("/A ", "").Replace("/a ", "");
                    string[] words = new Regex(" (.*?)=").Split(clearLine);
                    string variableName = words[1];
                    if (variableName.Contains(" ")) variableName = variableName.Split(' ').Last();
                    if (variableName.Contains("[")) variableName = variableName.Split('[').First(); //array
                    variableName = Regex.Replace(variableName, "[^a-zA-Z0-9_.]+", "", RegexOptions.Compiled);
                    if (!variables.Contains(variableName)) variables.Add(variableName);
                };
            }
            return variables;
        }

        public static List<String> getLabels(string code)
        {
            List<String> labels = new List<String>();
            string[] splittedCode = code.Split(new[] { "\r\n", "\n", "\r" }, StringSplitOptions.RemoveEmptyEntries);
            foreach (string line in splittedCode)
            {
                if (line.Length > 1 && line.Substring(0, 1) == ":" && line.Substring(1, 1) != ":")
                {
                    string subName = line.Replace(":", "");
                    if (!labels.Contains((subName))) labels.Add(subName);
                };
            }
            return labels;
        }

        public static string RandomSubroutineName(string code)
        {
            List<String> labels = getLabels(code);
            foreach (string label in labels)
            {
                string newSubName = GetRandomString();
                code = code.Replace(":" + label, ":" + newSubName);
                code = code.Replace("GOTO " + label, "GOTO " + newSubName);
                code = code.Replace("goto " + label, "GOTO " + newSubName);
            };
            return code;
        }

        public static string RandomVariableName(string code)
        {
            List<String> variables = getVariables(code);

            foreach (string variable in variables)
            {
                string newVariableName = GetRandomString();
                code = code.Replace("%" + variable + "%", "%" + newVariableName + "%");
                code = code.Replace("%" + variable + ":", "%" + newVariableName + ":");
                code = code.Replace(variable + "=", newVariableName + "=");
                code = code.Replace(variable + " =", newVariableName + "=");
                code = code.Replace(variable + "[", newVariableName + "[");
                code = code.Replace("[%" + variable + "%]", "[%" + newVariableName + "%]");
            }
            return code;
        }

        public static Tuple<string, string> SubstringEncode(string code)
        {
            char[] letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".ToCharArray().OrderBy(x => Guid.NewGuid()).ToArray();
            string[] splittedCode = code.Split(new[] { "\r\n", "\n", "\r" }, StringSplitOptions.RemoveEmptyEntries);
            string varName = GetRandomString();
            string setStr = "SET " + varName + "=" + new string(letters) + Environment.NewLine;
            string result = "";
            int i = 0;
            foreach (string line in splittedCode)
            {
                i++;
                if (line.ToUpper().Contains("SET") || line.Contains(":"))
                {
                    result += line;
                }
                else
                {
                    string[] splittedLine = line.Split(' ');
                    foreach (string word in splittedLine)
                    {
                        char[] characters = word.ToCharArray();
                        if (word.Contains('%'))
                        {
                            result += word + " ";
                        }
                        else
                        {
                            foreach (char character in characters)
                            {
                                if (letters.Contains(character))
                                {
                                    string lettersStr = new string(letters);
                                    result += "%" + varName + ":~" + lettersStr.IndexOf(character) + ",1%";
                                }
                                else
                                {
                                    result += character;
                                }
                            }
                            result += " ";
                        }
                    }
                }

                if (i< splittedCode.Count()) result += Environment.NewLine;

            }
            return new Tuple<string, string>(setStr, result);
        }
        public static string ControlFlow(string code)
        {
            code = OneLineIF(code);

            string[] splittedCode = code.Split(new[] { "\r\n", "\n", "\r" }, StringSplitOptions.RemoveEmptyEntries);
            Dictionary<int, string> shuffledCode = new Dictionary<int, string>();
            int lNumber = 0;
            while (code.Contains(":l" + Convert.ToString(lNumber))) lNumber++;
            int startNumber = lNumber;
            string eoc = GetRandomString();
            foreach (string line in splittedCode)
            {
                while (code.Contains(":l" + Convert.ToString(lNumber))) lNumber++;
                shuffledCode.Add(lNumber, line);
                lNumber++;
            }
            shuffledCode = shuffledCode.OrderBy(x => Guid.NewGuid())
                .ToDictionary(item => item.Key, item => item.Value);
            code = "";
            foreach (KeyValuePair<int, string> kvPair in shuffledCode)
            {
                code += ":l" + kvPair.Key.ToString() + Environment.NewLine;
                code += kvPair.Value + Environment.NewLine; ;
                code += "GOTO l" + (kvPair.Key + 1).ToString() + Environment.NewLine;
            }

            code = "GOTO l" + startNumber.ToString() + Environment.NewLine + code + ":l" + shuffledCode.Count;
            return RandomSubroutineName(code);
        }
    }
}