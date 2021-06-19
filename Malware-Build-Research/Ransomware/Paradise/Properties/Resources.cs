
using System.CodeDom.Compiler;
using System.ComponentModel;
using System.Diagnostics;
using System.Drawing;
using System.Globalization;
using System.Resources;
using System.Runtime.CompilerServices;

namespace DP_Builder.Properties
{
  [GeneratedCode("System.Resources.Tools.StronglyTypedResourceBuilder", "4.0.0.0")]
  [DebuggerNonUserCode]
  [CompilerGenerated]
  internal class Resources
  {
    private static ResourceManager resourceMan;
    private static CultureInfo resourceCulture;

    internal Resources()
    {
    }

    [EditorBrowsable(EditorBrowsableState.Advanced)]
    internal static ResourceManager ResourceManager
    {
      get
      {
        if (DP_Builder.Properties.Resources.resourceMan == null)
          DP_Builder.Properties.Resources.resourceMan = new ResourceManager("DP_Builder.Properties.Resources", typeof (DP_Builder.Properties.Resources).Assembly);
        return DP_Builder.Properties.Resources.resourceMan;
      }
    }

    [EditorBrowsable(EditorBrowsableState.Advanced)]
    internal static CultureInfo Culture
    {
      get
      {
        return DP_Builder.Properties.Resources.resourceCulture;
      }
      set
      {
        DP_Builder.Properties.Resources.resourceCulture = value;
      }
    }

    internal static string DP_Decrypter
    {
      get
      {
        return DP_Builder.Properties.Resources.ResourceManager.GetString(nameof (DP_Decrypter), DP_Builder.Properties.Resources.resourceCulture);
      }
    }

    internal static string DP_Keygen
    {
      get
      {
        return DP_Builder.Properties.Resources.ResourceManager.GetString(nameof (DP_Keygen), DP_Builder.Properties.Resources.resourceCulture);
      }
    }

    internal static Bitmap image_2
    {
      get
      {
        return (Bitmap) DP_Builder.Properties.Resources.ResourceManager.GetObject(nameof (image_2), DP_Builder.Properties.Resources.resourceCulture);
      }
    }

    internal static string res
    {
      get
      {
        return DP_Builder.Properties.Resources.ResourceManager.GetString(nameof (res), DP_Builder.Properties.Resources.resourceCulture);
      }
    }
  }
}
