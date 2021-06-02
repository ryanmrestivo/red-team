using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(NxCommandAndControl.Startup))]
namespace NxCommandAndControl
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
