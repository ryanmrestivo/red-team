using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace NxCommandAndControl.App_Start
{
    public class Constants
    {
        /// <summary>
        /// Location for the Master Password File ;)
        /// </summary>
        public const string MASTER_PASSWORD_FILE_LOCATION = "~/App_Data/mp.info";

        /// <summary>
        /// Application Security Master Seed/Salt - Can and Must be Changed > Generated using https://strongpasswordgenerator.com/
        /// </summary>
        public const string MASTER_SEED = "=4|'9#[Zg=]P1yNACR!Si$nK~_A)9Q";     // <<<< CHANGE-ME

        /// <summary>
        /// Application AES-256 Hard Coded Key - Can and Must be Changed > Generated using https://strongpasswordgenerator.com/
        /// </summary>
        public const string HARD_CODED_KEY = "924' $-iV7~:w~9%|+LCl<}4{X1] Y";

        /// <summary>
        /// Application AES-256 Hard Coded IV - Can and Must be Changed > Generated using https://strongpasswordgenerator.com/
        /// </summary>
        public const string HARD_CODED_IV = "6y7%32N@=$|)6:J(m8#$6}9!6o437M";

        /// <summary>
        /// Use TRUE if you want a second layer of protection - WARNING: Data Cannot be Used on Another Server     // <<<< CHANGE-ME
        /// </summary>
        public const bool USE_MACHINE_KEY_ENCRYPTION = true;

    }
}