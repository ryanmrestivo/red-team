# test for open redirect vulns (google dorks) 


| dork | injection param |
|:---:|:---:|
| inurl:redirect= | - |
| inurl:rdir=  | - |
| inurl:to=  | FP |
| inurl:destination= | - |
| inurl:ReturnURL=  | - |
| inurl:redirect_uri= | - |
| inurl:/allowcookies= | - |
| inurl:next= | - |
| inurl:url=https | - |
| inurl:url=http | - |
| inurl:redirect?https | - |
| inurl:redirect?http | - |
| inurl:url=http | - |
| inurl:?goto= | - |
| inurl:/?node= | - |
| inurl:/setLanguage.php?return= | - |
| inurl:?url= | - |
| inurl:?sUrl= | - |
| inurl:?from= | - |
| inurl:?home= | - |
| inurl:?redir= | - |
| inurl:?link= | - |
| inurl:?r= | - |
| inurl:?resource= | - |
| inurl:?return= | - |
| inurl:?referer= | - |
| inurl:?ref= | - |
| inurl:?retour= | - |
| inurl:?back= | - |
| inurl:?file= | - |
| inurl:?rb= | - |
| inurl:?end_display= | - |
| inurl:?urlact= | - |
| inurl:?redirectBack= | - |
| inurl:/search?q= | - |
| inurl:/r.php?u= | - |
| inurl:?page= | - |
| inurl:?l= | - |
| inurl:?loc= | - |
| inurl:?path= | - |
| inurl:?r2= | - |
redirect.html?open&url=
redirects/redir.cgi?full_url=


# note
* run your search excluding words that can include false positives and links which include login portals because often will require authentication to redirect

use something like: 

inurl:logout?returnUrl= -checkout -tickets -user -docs -kr  -account  -signup -signin -login -support -enroll -register -questions -logon -help -signin -log -password

a good example would be checkout, logout, signout, allowcookies, etc. 
