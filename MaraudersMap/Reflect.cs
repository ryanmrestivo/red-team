using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace MaraudersMap
{
    class Reflect
    {
        /*taken from https://github.com/mdsecactivebreach/SharpPack/blob/master/DotNetLoader.cs*/

        public static object loadAssemblyFromEntryPoint(byte[] bin, object[] commands)
        {
            Assembly ass = Assembly.Load(bin);
            object result = null;
            try
            {
                result = ass.EntryPoint.Invoke(null, new object[] { commands });
            }
            catch
            {
                MethodInfo method = ass.EntryPoint;
                if (method != null)
                {
                    object o = ass.CreateInstance(method.Name);
                    result = method.Invoke(o, null);
                }
            }
            return result;
        }



    }
}
