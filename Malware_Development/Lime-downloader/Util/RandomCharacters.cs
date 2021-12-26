using System;
using System.Text;

namespace LimeDownloader.Util
{
    public class RandomCharacters
    {
        private readonly Random random = new Random();
        const string alphabet = "asdfghjklqwertyuiopmnbvcxz";

        public string getRandomCharacters(int length)
        {
            var sb = new StringBuilder();
            for (int i = 1; i <= length; i++)
            {
                var randomCharacterPosition = random.Next(0, alphabet.Length);
                sb.Append(alphabet[randomCharacterPosition]);
            }
            return sb.ToString();
        }
    }
}
