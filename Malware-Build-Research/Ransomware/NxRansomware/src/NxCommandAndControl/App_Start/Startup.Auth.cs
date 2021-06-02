using System;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using Microsoft.Owin;
using Microsoft.Owin.Security.Cookies;
using Microsoft.Owin.Security.Google;
using Owin;
using NxCommandAndControl.Models;

namespace NxCommandAndControl
{
    public partial class Startup
    {
        // For more information on configuring authentication, please visit http://go.microsoft.com/fwlink/?LinkId=301864
        public void ConfigureAuth(IAppBuilder app)
        {
            // Enable the application to use a cookie to store information for the signed in user
            // and to use a cookie to temporarily store information about a user logging in with a third party login provider
            // Configure the sign in cookie

            app.UseCookieAuthentication(new CookieAuthenticationOptions
            {
                AuthenticationMode = Microsoft.Owin.Security.AuthenticationMode.Active,
                CookieSecure = CookieSecureOption.SameAsRequest,
                AuthenticationType = DefaultAuthenticationTypes.ApplicationCookie,
                LoginPath = new PathString("/Account/Login"),
                ExpireTimeSpan = TimeSpan.FromMinutes(10),

                // Validate UserAgent and IP Bind
                Provider = new CookieAuthenticationProvider
                {
                    OnValidateIdentity = (ctx) =>
                    {
                        // Validate UA
                        string ua = ctx.Identity.FindFirst("UA").Value;
                        bool isUaValid = ua == ctx.Request.Headers["User-Agent"];

                        // Validate IP
                        string ip = ctx.Identity.FindFirst("IP").Value;
                        bool isIpValid = ip == ctx.Request.RemoteIpAddress;

                        if (! isIpValid || ! isUaValid)
                        {
                            ctx.OwinContext.Authentication.SignOut();
                            ctx.RejectIdentity();
                            ctx.Response.Redirect(ctx.Options.LoginPath.Value);
                        }

                        return System.Threading.Tasks.Task.FromResult(0);
                    }
                },
            });
        }
    }
}