// tree.js
// Copyright (C) Stas'M Corp. 2015

imgLogo = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAADYElEQVR4nFWTXUhkdQDFf///vV6dGWccZ9RW10XRFr9NlB4CI1ta2I2+JCEjwhZZNkihdgvtoTXZB2mJaKuH7Cmh54q2bPclSmiCWGVXNpzSEj+m3Jmc75k798796CFatgPn8XdezjmC/0sKIQKBQKA5HA6fFlKeMA2jply2tnW9+GU+n//Otu0MYP0HiHvgCq/X29ze3j6lqupEOpMNFQ1bmLaNqRcplwq2Y1tbjuO87TjO54B5b0BFMBjsHB4e/iyVzvYfCj/xudeww7XYFQoYZdxsjvKZ85R3f7FxrcXV1dULg4ODJQFIn8/XOjY29sWdeLr/4FBjc/4c+tJPuBkFVAmmiQjYqFOPYZ6aRjGjbnf38fcikchbqhCiZmRkZMrj8fXF0zq/vjONPv4hlZ9OIRoacVMuIqTixvYwxj9Bu3oF6/FJsbm5NbW0tHRNhMPhvtnZ2e+Xl5dDN2/HSel1hD5+ndS7EeiuA9MApRp2K/BfeoDs6EXQN/Fqh7S1tX6rDg0NndI0rTaRSJBO7YPiYLzxEYHgUfTx0xCuhmIJz6tLWBPfgLkDHGKaJfb29h5RBwYGRjKZjEilUrhuGewkhaRJ1xGV387MAxLsIk0tHjYSt8HVwTGwXRsppVcNhUI1xWKRQlEHIUHAfU1NTJ59EU3T7naciMe5fPkAI38AUgXbwufzofT29p44dqylfyWyTtFQwN/E/MXztLUcJeD33XXjkQZ8oXrWNmLgSCRlGuprUSORyNdPPT06XlnXogip41YFcIwMZyemocpFeTmJc8NH5ZM53uz9CgL14A3isUJ4vVZKvRnd/TGbzW539XTen1iPYWoa13/P8fC5eZDKv3vrcxF/OCzu3oCaAORydB5vcQNual2xy6XS7s52/KXnR5/5YWNf6DUhsa1bRHMlojmdaKZANJkjeidNPF8CKaivsp1WT674wZX3X1FwHTsWi21J4XY898SjPT+nSsKoDYLfC14PVFWCpxI8GqiCBtV0HqrOW9nU4fWZmZlFBcB1XSsajV5VnHLzhWdP9hhWmT/zRWkBuA7SNvE7JU42eugzY4W/9neuraysTEsp4/e+kbW1NWVhYeGFrq6uSVmhPZgrO56SYSAc23b0Qib5d+LW3NzcpY6OjltSyiTAP+GYkT9X1CXNAAAAAElFTkSuQmCC";
imgFolder = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABpUlEQVR4nK2TzWqTURCGn6RtksamaSKShb8UKrhyYdWNO6HX4PV4Bb0DN65cCYIKFTeCKIIb6VoMrVGx2DTpd+b8zbgITROSiqADB2aGd54z72LgH6N0kjx+8c4q1RqlhQoLi4szwnptifVOk+uX2qXJ/lg5LIRbVzvElPnSO2D94gU2rnRoNeoAFBJ5s7s3A576avPGNQBublzmoD/kyc4HHmzdobmyTL22xOGg+DPgdN0K9VqblCIhRmAZgOD93wHMAIwYAjYqyGp4cTPa8mShaqRspKzkbITgSVnxIVO4hBPH6/efbC5AVYlp9EJUYja8eJyLDItEfxjYurvJ24+78y2kFAlJUTVUoVwG74Wj44DhCUkBOBoM5gNiCIQ4AuRsJDVEHIMiUK3qeECKYj7Ae4/zmZyVrIZmw4tgOmUZcWcCBJFEtpEFsxOATgO8nAEQGfsc94JH7XSDX/1D2qsr8wEijqcvn9NsNDjfatFeaxFD4NmrHcQViCtYWz3H/Xu32Z4AjA9jMDy2r99/sv/tB5+7+3T3e3T3ejzafjh1PP89fgMKQQNHvsa9vwAAAABJRU5ErkJggg";
imgPage = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABPklEQVR4nKWQvUoDURBGzyYq+h4SQUSihSKInSIWVoI+gO/giwRL25hW8b8NiDam1cLGxkIQISa7d2buWPgDZncRdZo7DN8czlz4ZyWfTfPsyl+6/dLgy/MTO9sbSWlg76DtWRAvqkbzxO8fHr3RPPHBvcpvdNcWZxiEDBUF98+vc7Pj9g0AqvZtXgjYWpnLzdyhnwV2m0c/A4oMNpfz0B8N3CG6E6MTxMiCISEUA9z9a6l1kTdYXajTTw0RKQZEM0Qj7sb60ixmjkXHzFGLdHvCayqEkBUDVJU0M6pVOL3s5AzqtQnSTJFQYqAm9FIlSSLzU5OYRjS+3w+8v+6IlBhIELo9IalU6dzd5gymx2s4EMo+USQQNDI8VGF6vJYDfJmKFgOIkdbhAaqCiqKqmApqH70ZpsrY6Egp/E/1Bo9d2qh3oUvpAAAAAElFTkSuQmCC";
imgUnknown = "data:image/gif;base64,R0lGODlhEAAQAOZxADSBvWSd3YORvEZmq2mh3zJ/vK3K6x9usylpwCc/jKGy0+zt8TJYpnmazzh1xWqNxixTo5S55WiMxkJXmkRtt5S96Zm44HKVy02GzyljuXWg1zdWn4uXv22j4FZ7u5K86fHy826Ryenp7qvK7C1swKO32a/B3oeTvEyH0FyDw46bwzFZqOHh6Y2Yv/Pz9Obm62Sc21uCwmKa26S2126SyoSz5l94sXWq45elyShXqZO55ilGlER8x0VamypkuYiVvkZlqIyn0omXwIuaw4ql0VN4uWiEuy1rwClYqnqbz26k4KzK7aW42d3f6Ian2GGX1zhWnzh1xnei2CpGk57C6pq54UJhp2SAuXOXzYOz5pqv1IOl1naq4yxVpUR8xV+V15uw1ZzB6lVwrWWe3au+3KCz1kRvui1twl6Y2jh2xzJxxD57ykSBzUuH0FKN1FiT1//////8+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAHEALAAAAAAQABAAAAfEgHGCcS4mQQ8SRGQgg41MMVsWBgZVTikljXFgNCMVNVw3WR9LWFqDMyFUSgQArQAEHWEXZXELRRFjAQVwvHAFAQE6HgsKSTBoaHDIycpoMg0KRhpv1NVvvNVSVwNPbt7fvN9uXwNAGG3o6Lzp6ChWNl5s8vK88/I8YjgUa/z8Bwf9+JkZIgKKgzQI0/BKmCbKhiZxVDBQQ1ENr4pqVggZJAACiTMgQx7pIiAThyk5MiBA4APJjh+ZBL1o0SNBggknWDQKBAA7";

imgWireless = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABV0lEQVR4nGNgGBRg5v+0/7LNwv+JVS/bLPx/5v+0/3DNQmWi/xkYGBg6zifyzPyf9l+kjOcTuiaRMp6PM/+n/e84n8jDwMDAIFQm+n/m/7T/TAwMDAxfPzMxMDAwMAgasH5uaVnL8KbrC5+WvSnPhPpJy9LDsleJmknIv+n6wt/SspZB0ID1M7IeFlzOLArKWh4c5uuzfeNFhi9b2fiXMvS7Y1PHhMuAPwy/xB49eMbAxavBwCcsJo1LHU4XnDx5MuTw4VN1HBwiKf/+vfbEawA37z+GnwwMDCv7jnPW1AR/r/px8//81nmMu3bsE7xxToohr0rjsXC1/f+aGnWGlX3HOWF64AAWjSrdoihe2rf30IaF0+7DoxcmjxKN+AC6AdgAzkBkYGBgYGBkYGJiYsSrBL8BDP/x6yZkwP///xkYCRiBMxoZGBgYPnx4z3Ll3lFCjqAMAADaGIHFB6LvlQAAAABJRU5ErkJggg";
imgWired = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABRUlEQVR4nJWSwUeDcRjHP5tkZoexokbs0BJFHbrsOKLoEplEHYqkQ39G98VIjFHTbctkRFH/wI6RiJEOo3elQ3vf9/fb8+swyup9s/d7eXh8n4/nyzeEj07KdQPgugqAg53VkJfvz/K4fGWazWdmplNsrS0CcFa54f6hSSo1wf7mct9N2Iu6t7sOQKFUo1Cq9e1+a8gvAsD2xgoA1fqdr+dfgON2ARBjggOsVwvb1QC8We1gAKWFlvXx/cFLq43SMjjAcbsopXFU78iYnzgDATq2JhaNcHpeASAWjdCx9eAA29GMZbJMxSM8vtsY18Z2AgB6EQSlBaUEoyVQhGw+f3QrXeHSCKYriAhVETILs0ueFC8liw1Te2qbZLFhRg8vfIvgWeUg8gXMjUQJh3pzfjzuC/BtYi6dYDIeIZdOIJ/DXPv4vgBRS4+reM6iEwAAAABJRU5ErkJggg";
imgTest = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACGklEQVR4nJWQzUsUARjGfzOzM7PrqokaaGbUpVMRQhetpTpUVmIeKsqb18IgBBMh6Eu8GET/QF0LKujiKQ8WXQQvgmGFS6ho6/jBfu82M08HI4pU9Lm9vO/ze3he2EKS2Sy57Vvtt5WEHfhIQtdvdDzfNWB9hZFcpl7SUXk/TGEMjOwKkJpDUkxSsyTU03NOMGTvyJz3eKSCpdmvjt69NSTFlJp3hdE/vCNAemEjHaKyaFP35Q5JqPtahza7N/8e1r8xGHMiQADEMWhizTMBi8cD48DdwW0BpTxDkXgUKHM2UUmcvexryAN7ONSSpvPilwdbAtam6TMwIQwBSLTZ1NVHqar7CX4WsBnuex+B+32bdl+aoFycq5CWbclHL1806sKJhMZG61ROm1JYI/no0vmu/H/mzBS93qQlrVRLSaQUykw7ev2sSSojZZGyVZIcTY3WCO7d/Df9A/KT1dK8K80geWhxCn0cRVpByiGVkMJaqYQ627tyf8zpCW55n0xpoVL6jDSLtITAFSQ0/mq/tI5URCqZUmBr8k2tMAd6Acx8hv64HUI5t/FSEzDgYGMFp47d5sjhRigC34HlEFIhLa2rtB6fewgQsYRXyHKAkjBMMAAnDsmxNZS7imFBkARfgAduLAAXimWnprbhTosBcObklafZrN0Vi/pFIMAA1/axzIBCyUEyfhcW8WhgLK5Wx2fm65OF1SenfwETYCW87LyrywAAAABJRU5ErkJggg";
imgWork = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAADAklEQVR4nKXTz0vkdRzH8efnOx/nOx/H3a+zm2ZDuq7TuBpNPw2KunQQxFToIAUdgj2U0C2ILl3sP+hiQuAl6hD0A1ZLFGrZKYkdE5aSXQ/rNAvq4DI648zX+X6+vz4damNpu/U+P3jx4v3mDf9zBMArL55/vTMV540B7QviGDpVTDplaGtBvZXA7jBkzkYYA0cnFlpbN37+tXZFvPfO8OXN7cxCh4Q3po7pTGmulrr4fecMzz/h89JzNe424MvlPu43P5bSeCfxW7K/J+5fq7u2MYbJsUPOORHXtwQnTcikW8y8cMTunuSTz7oA7jMWhy1GrK2baTzPY6D3lC6ZwGsm+WnLQmvNM0Ma301SLCm01v8yAoNEtjwbrY94+qJBt2xuVuCwFmAJeLLfQrdsrm0KtNYPmP4+hRQi0XBdl+5kkhvbFld+CXFdj9wjFrfLSaLYcG3L41TzgEnInoYA+PCDtyfa4Znvbdtmf3+fYrHYnHvzKef9j742986Vy+Xq4+PjjuM4uK5LIj6e+njh8xUJ0Je90J8bfhYpJRsbG5RKpe3maZJ3L78q/DDCOdvJdz/c+i2fz79cKBQIw5Ct61cHAP4OGBoaHBwkDEPGxsZQSj00Ojq6KITAmL9KPHzhVu/IyAjZbBbbtqn8cfviPwHdmZ68MYZEIsHm5ia1Wm374OBg33VdoihCKQWwnUwmh7PZLEopnO7zwwByaWlJKKUuSSk5Pj6mWq2yurr6RT6f/1ZKGQZBgO/7slKpTM3Ozr4mpUQIgeM4lxYXF4Ws1+upVCqVF0IQhiF7e3t3qtVqtlwuFwAfMIBUSj1aqVTuGGMGjDEopR5rNpvKKpfLj9u2bQMEQUCxWPym3W7fBc4BPUAv0Ntut+vr6+tf3duJbdtyZ2enIKanpwvAXBAEMo5jf21tbSGTyVSVUqetVstEUUQ6nRZa63Sj0eibmZmZ833fBsIwDD8V8/PzYnl5WXqeJ4IgMLlcLlpZWYn/63UnJias3d1d2dHRgW3bZnJyMvwTyOd1TLB01tkAAAAASUVORK5CYII";
imgFuture = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAADQ0lEQVR4nCXT2WtcVQDA4d+Ze+7MzSzJLBkmbWwUCZYqJfgoggj1pREUV6ogSl9spNIiKGJFpD61EPGpdcEFpILWJSamqaamC4mkpJFKaowx2lizTBxn5s5k7uQuc8/xoXx/wyc+Ovmx7unuZn31OmY0gmVZFO0y0WyWVluCiq+oBSHtmU727d0jDAAf8lHQLeCLU6f1Zrmmfbum9Zajdehqz21oT2u97iu9qrV+7+Ksntjw9KETp/SG1tha42pNoDWRZsslmU1idrSBoUErzKiFBuKmoKVg9a8abs3g0MDTfPjJGR0qqNqbCBTSDbcIUfiuw/yvczSbLq4viKW2UXMl99y3E7/eorJa4R+d58mH+hn6/Ix+9ql+YRAgt4ImmhDDitLVfQsx06LuKAwzS6Db8BuQS7Qz9tXXELoEjQ1y7YL9+/oBhXj73UF94PkDhL5Pw3bI5Qo0Nj1EJIGMgRagNdRt6MrDhfErnP9hmLgR8MCe+4W0ohITg0q5zuLCdeKxItVqDaUUpmkQKp8777qDVMLiyqV5pn88yxMP7sXeKDN49JiWm9UKBpCMZ0jFbTo78mSSWSI0EKKJGQ3pzlX447drTIx9wwv7D3N1ZoF/V5rggQwaHkIbyFaMuGwnk8jjUCJqbpFOG6jQZunaOc6Pj/LaS4e5MD6MU7YYG5ri+NFBIS0ZA7eF6wQUV0qsLxfxvBLbu0JaXpNNe5aJc58x8PrLLP80Sb1a49uhn3n/gzER69mFdOpN7EqNUslBCEE6kyEZT1IobLH0+1lmpkcYeOUgxauXWVlZ4/SXkxTyu4n13gYKIr4fkC4U6OnZwbYdXUhL4GsfQ0YZGfmeRx97hqXZRaYuzXH82CSfjg6z/fZeEAFoRaS4UYIIzPwyzezcZRb+nmd5/QZ/3ljjnRNTQA+9ux5h9LtF3nzrVfA68GUKN2hAUiFT2TQISOYSZFQSKSWq5eL4EE9AX99zPP7wvbx48CSZzjxkdrJWbaISJp7wkF6oKNv/0Xf3bkLUTTokIeKsrPtEpAnq5kBigFY4WASGIMBFur7HkTeOEEqFXS/TkU0jWgal5Qq35nvRtoCWQXsqTc2r4MYa+FYEkNSo8j/tY6S83TnyoQAAAABJRU5ErkJggg";

function expand(n)
{
	var ul = document.getElementById("ul"+n);
	var img = document.getElementById("img"+n);
	if (img != null && ul.className != null)
	{
		var str = img.src;
		if (ul.className == "Hidden") {
			ul.className = "Shown";
		} else {
			ul.className = "Hidden";
		}
	}
}
function getNextId()
{
	return cnt++;
}
function ReadNode(n, r)
{
	var str = "";
	var tab = "";
	for (var i = 0; i <= r; i++) tab += "\t";

	for (var i = 0; i < n.length; i++)
	{
		if (typeof(n[i]) == "object")
		{
			var x = getNextId();
			switch (n[i][0] & 1)
			{
				case 0:
				str += tab + "<li><img align=\"absmiddle\" src=\"";
				if (typeof n[i][1] == "number")
				{
					if ((n[i][1] & 1) == 0)
					{
						str += imgWired;
					} else
					{
						str += imgWireless;
					}
				}
				if (typeof n[i][1] == "string")
				{
					str += n[i][1];
				}
				str += "\" id=\"img"+x+"\">";
				if (typeof n[i][3] == "string")
				{
					str += "<a href=\""+n[i][3]+"\" target=\"mainFrame\">"+n[i][2]+"</a>";
				} else {
					str += n[i][2];
				}
				if ((n[i][0] & 2) > 0) str += "&nbsp;<img align=\"absmiddle\" src=\""+imgTest+"\">";
				if ((n[i][0] & 4) > 0) str += "&nbsp;<img align=\"absmiddle\" src=\""+imgWork+"\">";
				if ((n[i][0] & 8) > 0) str += "&nbsp;<img align=\"absmiddle\" src=\""+imgFuture+"\">";
				str += "</li>\n";
				break;
				case 1:
				var show = "Hidden";
				if (n[i][1] == 1) show = "Shown";
				str += tab + "<li><a onclick=\"expand('"+x+"')\"><img align=\"absmiddle\" src=\""+n[i][2]+"\" id=\"img"+x+"\">"+n[i][3];
				if ((n[i][0] & 2) > 0) str += "&nbsp;<img align=\"absmiddle\" src=\""+imgTest+"\">";
				if ((n[i][0] & 4) > 0) str += "&nbsp;<img align=\"absmiddle\" src=\""+imgWork+"\">";
				if ((n[i][0] & 8) > 0) str += "&nbsp;<img align=\"absmiddle\" src=\""+imgFuture+"\">";
				str += "</a>\n";
				str += tab + "<ul class=\""+show+"\" id=\"ul"+x+"\">\n";
				str += ReadNode(n[i][4], r + 1);
				str += tab + "</ul>\n";
				break;
			}
		}
	}
	return str;
}
function BuildTree(tNode)
{
	cnt = 0;
	return ReadNode(tNode, 0);
}
function SwitchNodes(b)
{
	var uls = document.getElementsByTagName('ul');
	for (var i = 0; i < uls.length; i++)
	{
		if (uls[i].id.indexOf("ul") == 0)
		{
			var n = uls[i].id.substr(2);
			var ul = document.getElementById("ul"+n);
			var img = document.getElementById("img"+n);
			if (img != null && ul.className != null)
			{
				var str = img.src;
				if (b) {
					ul.className = "Shown";
				} else {
					ul.className = "Hidden";
				}
			}	
		}
	}
}
function FilterNode(n, m)
{
	m = m.toLowerCase();
	var i = 0;
	var a = new Array();
	for (var i = 0; i < n.length; i++)
	{
		if (typeof(n[i]) == "object")
		{
			switch (n[i][0] & 1)
			{
				case 0:
				if (n[i][2].toLowerCase().indexOf(m) >= 0) a.push(n[i]);
				break;
				case 1:
				x = FilterNode(n[i][4], m);
				if ((x.length > 0) || (n[i][3].toLowerCase().indexOf(m) >= 0)) a.push([n[i][0], 1, n[i][2], n[i][3], x]);
				break;
			}
		}
	}
	return a;
}
function FindRouter(Model)
{
	if (Model != '')
	{
		var newTree = FilterNode(Tree, Model);
		document.getElementById('ULRoot').innerHTML = BuildTree(newTree);
	} else {
		document.getElementById('ULRoot').innerHTML = BuildTree(Tree);
	}
}
