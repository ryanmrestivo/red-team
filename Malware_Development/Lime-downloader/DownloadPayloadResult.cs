using System.ComponentModel;

namespace LimeDownloader
{
    public enum DownloadPayloadResult
    {
        [Description("None")]
        None = 0,

        [Description("Valid")]
        Valid,

        [Description("Invalid URL")]
        InvalidURL,

        [Description("Invalid .NET Assembly")]
        InvalidNETAssembly,

        [Description("Could not load Assembly")]
        InvalidAssembly,
    }
}
