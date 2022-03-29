function createCookie(name,value,hours) {
    if (hours) {
        var date = new Date();
        date.setTime(date.getTime()+(hours*60*60*1000));
        var expires = "; expires="+date.toGMTString();
    }
    else var expires = "";
    document.cookie = name+"="+value+expires+"; path=/";
}

function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for(var i=0;i < ca.length;i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1,c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    }
    return null;
}

function eraseCookie(name) {
    createCookie(name,"",-1);
}


  function confirm_prompt( text,url ) {
     if (confirm( text )) {
      window.location = url ;
    }
  }
  
  
function isNumberInt(inputString) {
  return (!isNaN(parseInt(inputString))) ? true : false;
}

function cutLongText( field ) {

   var elem, size, text, ftext;
	elem = document.getElementById( field );
	text = elem.innerHTML;
	size = 100;
	ftext=elem.innerHTML;
	if (text.length > size) {
		text = text.slice(0, size);
	}
   	elem.innerHTML = text +'<a href="#" onclick="return alert( ftext );">...</a>';
}
//Now, calling functions

// createCookie('ppkcookie','testcookie',7);

//var x = readCookie('ppkcookie')
//if (x) {
//    [do something with x]
//}

function to_logout( ) {
	eraseCookie('id');
	eraseCookie('login');
	eraseCookie('name');
	eraseCookie('secret');
	return true;
}

function show_login_as( ) {
   var elem, text , elem_home;
	elem_home = document.getElementById( 'div_home' );

	elem = document.getElementById( 'login_as' );

	//var mypath=window.location.pathname;
	//var f=mypath.search( /bulktool3/ );
	//if ( f == -1 )  {
		if( text=readCookie( 'name' ) ) {
			elem.innerHTML = '<table width="100%"><tr><td width="70%"> <a href="../index.html">home</a> </td><td align="right"> You are login as '+text+' [  <a href="" onclick="to_logout();"> logout </a> ]</td></tr></table> ';	
		} else {
			elem.innerHTML = '<table width="100%"><tr><td width="70%"> <a href="../index.html">home</a> </td><td align="right"> [  <a href="login.cgi"> login </a> ]</td></tr></table> ';									
		}
}


function show_login_as_main_page( ) {
   var elem, text , elem_home;
	elem_home = document.getElementById( 'div_home' );

	elem = document.getElementById( 'login_as' );

	//var mypath=window.location.pathname;
	//var f=mypath.search( /bulktool3/ );
	//if ( f == -1 )  {
		if( text=readCookie( 'name' ) ) {
			elem.innerHTML = '<table width="100%"><tr><td width="70%"> </td><td align="right"> You are login as '+text+' [  <a href="" onclick="to_logout();"> logout </a> ]</td></tr></table> ';	
		} else {
			elem.innerHTML = '<table width="100%"><tr><td width="70%"> </td><td align="right"> [  <a href="./cgi-bin/login.cgi"> login </a> ]</td></tr></table> ';									
		}
}


function getObj(objID)
{
    if (document.getElementById) {return document.getElementById(objID);}
    else if (document.all) {return document.all[objID];}
    else if (document.layers) {return document.layers[objID];}
}


function show_value() {
		var minute, hour, day, month, weekday;
		
		minute	= getSelection('minute');
		hour	= getSelection('hour');
		day		= getSelection('day');
		month	= getSelection('month');
		weekday	= getSelection('weekday');
		getObj("cron").value = minute + "\t" + hour + "\t" + day + "\t" + month + "\t" + weekday ;
		//console.log( getObj('cron').value );
}

function getSelection(name) {
	var chosen;
		var all_selected = [];
		var a=getObj(name);
		for ( var index=a.options.length -1 ; index >= 0; --index) {
			//console.log(a.options.length);

			if(a[index].selected) {
				if( a[index].value == '*' ) {
					chosen = '*';
					return chosen;
				}
				all_selected.push(a[index].value);
			}
		}		

		if(all_selected.length)
			chosen = all_selected.join(",");
		else
			chosen = '*';
	return chosen;
}