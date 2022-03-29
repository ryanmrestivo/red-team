using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;

namespace PSAttack.PSAttackShell
{
    public class PSParameter
    {
        #region " Public Properties "

        #region " Parameter "
        [Category("Parameters"),
        Browsable(true),
        ReadOnly(false),
        Bindable(false),
        DesignOnly(false)]
        public String Name { get; set; }
        public String Description { get; set; }
        public String Category { get; set; }
        public Object Value { get; set; }
        public Object DefaultValue { get; set; }
        public Boolean IsFileName { get; set; }
        public Boolean IsHostList { get; set; }
        public Boolean IsCredential { get; set; }
        private Type type;

        [XmlIgnoreAttribute()]
        public Type Type
        {
            get { return type; }
            set
            {
                type = value;
            }
        }

        public String TypeName
        {
            get
            {
                if (Value != null || DefaultValue != null)
                {
                    return (Value ?? DefaultValue).GetType().ToString();
                }
                else
                {
                    return "";
                }
            }
            set { type = System.Type.GetType(value); }
        }
        #endregion

        #endregion
    }
}
