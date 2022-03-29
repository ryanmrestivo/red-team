using System;   
using System.Collections.Generic;
using System.Text;
using System.DirectoryServices;

namespace Reconerator
{
    class LDAP
    {
        public void LDAPQuery(string ldapbase, string filter, int limit)
        {
            Boolean islimit = false;

            if (limit > 0) { islimit = true; }
            //DirectoryEntry deRoot = new DirectoryEntry("LDAP://W2K8DC/dc=stufus,dc=lan");
            DirectoryEntry deRoot = new DirectoryEntry(ldapbase);

            DirectorySearcher dsFindUser = new DirectorySearcher(deRoot);
            dsFindUser.SearchScope = SearchScope.Subtree;

            if (islimit == false) {
                Console.Out.WriteLine("LDAP Search for '{0}' without a results limit", filter);
            } else {
                Console.Out.WriteLine("LDAP Search for '{0}' with a limit of {1} {2}", filter, limit, (limit==1)?"result":"results");
            }

            dsFindUser.Filter = filter;

            SearchResultCollection result = dsFindUser.FindAll();
            int number_of_results = result.Count;
            Console.Out.WriteLine("Total: {0} result{1}", number_of_results, (number_of_results==1)?"":"s");

            if (result != null)
            {
                foreach (System.DirectoryServices.SearchResult resEnt in result)
                {
                    Console.Out.WriteLine("------------------------------------");
                    System.DirectoryServices.DirectoryEntry de = resEnt.GetDirectoryEntry();
                    foreach (string prop in de.Properties.PropertyNames) { 
                        try { 
                            int num_items = de.Properties[prop].Count;
                            foreach (string pval in de.Properties[prop]) {
                                Console.Out.WriteLine("{0}[{1}]: {2}", prop, num_items, pval);
                            }
                        }
                        catch
                        {
                            // TODO some attributes can't be casted to a string - so work through them
                            //Console.Out.WriteLine("{0}=(ERROR)", prop);
                        }
                    }
                    if (islimit == true)
                    {
                        limit--;
                        if (limit == 0) { return;  }
                    }
                }
            }
           
        }
    }
}
