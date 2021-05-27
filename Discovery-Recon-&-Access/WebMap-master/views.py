from django.shortcuts import render
from django.http import HttpResponse
import xmltodict, json, html, os, hashlib, re, urllib.parse, base64
from collections import OrderedDict
from nmapreport.functions import *

def setscanfile(request, scanfile):
	xmlfiles = os.listdir('/opt/xml')

	for i in xmlfiles:
		if i == scanfile:
			request.session['scanfile'] = i
			break

	if scanfile == 'unset':
		if 'scanfile' in request.session:
			del(request.session['scanfile'])

	return render(request, 'nmapreport/index.html', { 'out': '', 'table': '', 'scaninfo': '<script> location.href="/"; </script>', 'scandetails': '', 'trhost': '' })


def port(request, port):
	return render(request, 'nmapreport/index.html', { 'out': '', 'table': '', 'scaninfo': '', 'scandetails': '', 'trhost': '' })

def details(request, address):
	r = {}
	oo = xmltodict.parse(open('/opt/xml/'+request.session['scanfile'], 'r').read())
	r['out2'] = json.dumps(oo['nmaprun'], indent=4)
	o = json.loads(r['out2'])

	r['trhost'] = ''
	v,e,z,h = '','','',''
	pc,po,pf=0,0,0

	scanmd5 = hashlib.md5(str(request.session['scanfile']).encode('utf-8')).hexdigest()
	addressmd5 = hashlib.md5(str(address).encode('utf-8')).hexdigest()

	# collect all labels in labelhost dict
	labelhost = {}
	labelfiles = os.listdir('/opt/notes')
	for lf in labelfiles:
		m = re.match('^('+scanmd5+')_([a-z0-9]{32,32})\.host\.label$', lf)
		if m is not None:
			if m.group(1) not in labelhost:
				labelhost[m.group(1)] = {}
			labelhost[m.group(1)][m.group(2)] = open('/opt/notes/'+lf, 'r').read()

	# collect all notes in noteshost dict
	noteshost = {}
	notesfiles = os.listdir('/opt/notes')
	for nf in notesfiles:
		m = re.match('^('+scanmd5+')_([a-z0-9]{32,32})\.notes$', nf)
		if m is not None:
			if m.group(1) not in noteshost:
				noteshost[m.group(1)] = {}
			noteshost[m.group(1)][m.group(2)] = open('/opt/notes/'+nf, 'r').read()


	r['trhead'] = '<tr><th>Port</th><th style="width:300px;">Product / Version</th><th>Extra Info</th><th>&nbsp;</th></tr>'
	pel=0
	for ik in o['host']:
		# this fix single host report
		if type(ik) is dict:
			i = ik
		else:
			i = o['host']

		if '@addr' in i['address']:
			saddress = i['address']['@addr']
		elif type(i['address']) is list:
			for ai in i['address']:
				if ai['@addrtype'] == 'ipv4':
					saddress = ai['@addr'] 


		if str(saddress) == address:
			#r['out'] = json.dumps(i, indent=4)
			h = '<span style="color:#999;font-size:12px;"><i>No Hostname</i></span>'
			if 'hostnames' in i:
				if type(i['hostnames']) is dict and 'hostname' in i['hostnames']:
					if '@name' in i['hostnames']['hostname']:
						h = '<span style="color:#999;font-size:12px;">'+i['hostnames']['hostname']['@name']+'</span>'

			labelout = '<span id="hostlabel"></span>'
			if scanmd5 in labelhost:
				if addressmd5 in labelhost[scanmd5]:
					labelcolor = labelToColor(labelhost[scanmd5][addressmd5])
					labelmargin = labelToMargin(labelhost[scanmd5][addressmd5])
					labelout = '<span id="hostlabel" style="margin-left:60px;margin-top:-24px;" class="rightlabel '+labelcolor+'">'+html.escape(labelhost[scanmd5][addressmd5])+'</span>'

			r['scaninfo'] = '<div class="row">'+\
			'	<div class="col s3"><span class="card-title">Host Details:</span><h6>'+html.escape(address)+'</h6>'+h+labelout+'</div>'+\
			'	<div class="col s3" id="detailspo"></div>'+\
			'	<div class="col s3" id="detailspc"></div>'+\
			'	<div class="col s3" id="detailspf"></div>'+\
			'</div>'

			rmdupl = {}
			for pobj in i['ports']['port']:
				if type(pobj) is dict:
					p = pobj
				else:
					p = i['ports']['port']

				if p['@portid'] in rmdupl:
					continue

				rmdupl[p['@portid']] = 1

				if p['state']['@state'] == 'closed':
					pc = (pc + 1)
				elif p['state']['@state'] == 'open':
					po = (po + 1)
				elif p['state']['@state'] == 'filtered':
					pf = (pf + 1)

				pel = (pel + 1)
				oshtml = ''
				if '@ostype' in p['service']:
					oshtml = '<div style="font-family:monospace;padding:6px;margin:6px;border-left:solid #666 1px;"><sup style="border-bottom:solid #ccc 1px;">Operating System</sup><br>'+html.escape(p['service']['@ostype'])+'</div>'

				so = ''
				if 'script' in p:
					if '@id' in p['script']:
						if p['script']['@id'] != 'fingerprint-strings':
							so += '<div style="word-wrap: break-word;word-break: break-all;padding:6px;margin-left:6px;border-left:solid #666 1px;max-width:300px;font-size:12px;color:#ccc;font-family:monospace;"><sup style="color:#999;border-bottom:solid #999 1px;">script output</sup><br><b>'+html.escape(p['script']['@id'])+'</b> '+html.escape(p['script']['@output'])+'</div>'
					else:
						for sosc in p['script']:
							if '@id' in sosc:
								if sosc['@id'] != 'fingerprint-strings':
									so += '<div style="word-wrap: break-word;word-break: break-all;padding:6px;margin:6px;border-left:solid #666 1px;max-width:300px;font-size:12px;color:#ccc;font-family:monospace;"><sup style="color:#999;border-bottom:solid #999 1px;">script output</sup><br><b>'+html.escape(sosc['@id'])+'</b> '+html.escape(sosc['@output'])+'</div>'

				v,z,e = '','','<i class="grey-text">N/A</i>'
				if p['state']['@state'] == 'open':
					if '@version' in p['service']:
						v = p['service']['@version']
					else:
						v = '<i class="grey-text">No Version</i>'

					if '@product' in p['service']:
						z = p['service']['@product']
					else:
						z = '<i class="grey-text">No Product</i>'

					if '@extrainfo' in p['service']:
						e = p['service']['@extrainfo']

					cpe = ''
					if 'cpe' in p['service']:
						if type(p['service']['cpe']) is list:
							for cpei in p['service']['cpe']:
								cpe += '<span class="grey-text" style="font-family:monospace;font-size:12px;">'+html.escape(cpei)+'</span><br>'
						else:
								cpe = '<span class="grey-text" style="font-family:monospace;font-size:12px;">'+html.escape(p['service']['cpe'])+'</span><br>'
							

					r['trhost'] += '<tr><td style="vertical-align:top;">'+\
					'<span style="color:#999;font-size:12px;">'+p['service']['@name']+'</span><br>'+\
					'<span class="new badge blue" data-badge-caption="">'+p['@protocol']+' / '+p['@portid']+'</span>'+\
					'</td>'+\
					'<td>'+z+' / '+v+'<br><span style="font-size:12px;color:#999;">State: '+p['state']['@state']+'<br>Reason: '+p['state']['@reason']+'</span></td>'+\
					'<td style="vertical-align:top">'+e+'<br>'+cpe+'</td>'+\
					'<td><ul id="dropdown'+str(pel)+'" class="dropdown-content" style="min-width:300px;">'+\
					'	<li><a href="#!" class="btncpy" data-clipboard-text="curl -v -A \'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1\' -k \'http://'+html.escape(address)+':'+html.escape(p['@portid'])+'\'">Copy as curl command</a></li>'+\
					'	<li><a href="#!" class="btncpy" data-clipboard-text="nikto -host \'http://'+html.escape(address)+':'+html.escape(p['@portid'])+'\'">Copy as nikto command</a></li>'+\
					'	<li><a href="#!" class="btncpy" data-clipboard-text="telnet '+html.escape(address)+' '+html.escape(p['@portid'])+'">Copy as telnet command</a></li>'+\
					'</ul><a class="dropdown-trigger btn blue right" href="#!" data-target="dropdown'+str(pel)+'"><i class="material-icons">arrow_drop_down</i></a> '+\
					'<button onclick="javascript:apiPortDetails(\''+html.escape(address)+'\',\''+html.escape(p['@portid'])+'\');" class="btn blue right"><i class="material-icons">receipt</i></button></td>'+\
					'</tr>'
				elif p['state']['@state'] == 'filtered':
					r['trhost'] += '<tr><td><span class="new badge grey" data-badge-caption="">'+p['@protocol']+' / '+p['@portid']+'</span><br>'+\
					'<span style="color:#999;font-size:12px;">'+p['service']['@name']+'</span></td>'+\
					'<td colspan="2" style="color:#999;font-size:12px;">State: filtered<br>Reason: '+p['state']['@reason']+'</td>'+\
					'<td><button onclick="javascript:apiPortDetails(\''+html.escape(address)+'\',\''+html.escape(p['@portid'])+'\');" class="btn blue right"><i class="material-icons">receipt</i></button></td></tr>'
				else:
					r['trhost'] += '<tr><td><span class="new badge grey" data-badge-caption="">'+p['@protocol']+' / '+p['@portid']+'</span><br>'+\
					'<span style="color:#999;font-size:12px;">'+p['service']['@name']+'</span></td>'+\
					'<td colspan="2" style="color:#999;font-size:12px;">State: '+p['state']['@state']+'<br>Reason: '+p['state']['@reason']+'</td>'+\
					'<td><button onclick="javascript:apiPortDetails(\''+html.escape(address)+'\',\''+html.escape(p['@portid'])+'\');" class="btn blue right"><i class="material-icons">receipt</i></button></td></tr>'

		# this fix single host report
		if type(ik) is not dict:
			break;

	notesout,notesb64,removenotes = '','',''
	if scanmd5 in noteshost:
		if addressmd5 in noteshost[scanmd5]:
			notesb64 = noteshost[scanmd5][addressmd5]
			r['table'] = '<div class="card" style="background-color:#3e3e3e;">'+\
			'	<div class="card-content"><h5>Notes</h5>'+\
			'		'+base64.b64decode(urllib.parse.unquote(notesb64)).decode('ascii')+\
			'	</div>'+\
			'</div>'

			#notesout = '<br><a id="noteshost'+str(hostindex)+'" href="#!" onclick="javascript:openNotes(\''+hashlib.md5(str(address).encode('utf-8')).hexdigest()+'\', \''+notesb64+'\');" class="small"><i class="fas fa-comment"></i> contains notes</a>'
			#removenotes = '<li><a href="#!" onclick="javascript:removeNotes(\''+addressmd5+'\', \''+str(hostindex)+'\');">Remove notes</a></li>'




	r['pretable'] = '<script> '+\
	'$(document).ready(function() { '+\
	'	$("#scantitle").html("'+html.escape(request.session['scanfile'])+'");'+\
	'	var clipboard = new ClipboardJS(".btncpy"); '+\
	'	clipboard.on("success", function(e) { '+\
	'		M.toast({html: "Copied to clipboard"}); '+\
	'	}); '+\
	'	$(".dropdown-trigger").dropdown(); '+\
	'	$("#detailspo").html(\'<center><h4><i class="fas fa-door-open green-text"></i> '+str(po)+'</h4><span class="small grey-text">OPEN PORTS</span></center>\');'+\
	'	$("#detailspc").html(\'<center><h4><i class="fas fa-door-closed red-text"></i> '+str(pc)+'</h4><span class="small grey-text">CLOSED PORTS</span></center>\');'+\
	'	$("#detailspf").html(\'<center><h4><i class="fas fa-filter grey-text"></i> '+str(pf)+'</h4><span class="small grey-text">FILTERED PORTS</span></center>\');'+\
	'}); '+\
	'</script>'

	return render(request, 'nmapreport/index.html', r)

def index(request, filterservice="", filterportid=""):
	r = {}

	if 'scanfile' in request.session:
		oo = xmltodict.parse(open('/opt/xml/'+request.session['scanfile'], 'r').read())
		r['out2'] = json.dumps(oo['nmaprun'], indent=4)
		o = json.loads(r['out2'])
	else:
		# no file selected
		xmlfiles = os.listdir('/opt/xml')


		r['table'] = '<div class="" style="border-top:solid #444 1px;"><br>'+\
		'		Put your Nmap XML files in <span class="tmlabel grey-text" style="background-color:transparent;">/opt/xml/</span> directory, example:<br><br>'+\
		'		<div class="tmlabel black grey-text" style="padding:10px;font-size:14px;">nmap -A -T4 -oX myscan.xml 192.168.1.0/24<br>'+\
		'		mv myscan.xml &lt;docker webmap xml dir&gt;<br><br>'+\
		'		# or you can copy myscan.xml to the webmap container:<br>'+\
		'		docker cp myscan.xml webmap:/opt/xml/</div>'+\
		'</div>'+\
		'<script async defer src="https://buttons.github.io/buttons.js"></script>'

		r['table'] += '<div class="row" style="margin-top:60px;">'+\
		'	<div class="col s4" style="text-align:center;">'+\
		'		<img src="/static/logo.png" style="width:300px;" /><br>'+\
		'		<span style="color:#999;">Made with <i class="fas fa-heart red-text"></i> by Andrea <b><a href="https://twitter.com/Menin_TheMiddle">theMiddle</a></b> Menin</span>'+\
		'	</div>'+\
		'	<div class="col s3" style="color:#999;"><b>GitHub:</b><br><br>'+\
		'		<a class="github-button" href="https://github.com/theMiddleBlue" data-size="large" data-show-count="true" aria-label="Follow theMiddle on GitHub">Follow theMiddle</a><br>'+\
		'		<a class="github-button" href="https://github.com/Rev3rseSecurity/WebMap/subscription" data-icon="octicon-eye" data-size="large" data-show-count="true" aria-label="Watch Rev3rseSecurity/WebMap on GitHub">Watch</a><br>'+\
		'		<a class="github-button" href="https://github.com/Rev3rseSecurity/WebMap/" data-icon="octicon-star" data-size="large" data-show-count="true" aria-label="Star Rev3rseSecurity/WebMap on GitHub">Star</a>'+\
		'	</div>'+\
		'	<div class="col s5" style="color:#999;"><b>Follow me:</b><br><br>'+\
		'		<a href="https://twitter.com/Menin_TheMiddle?ref_src=twsrc%5Etfw" class="twitter-follow-button" data-size="large" data-show-count="true">Follow @Menin_TheMiddle</a><script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script><br>'+\
		'		<script src="https://apis.google.com/js/platform.js"></script><div class="g-ytsubscribe" data-channelid="UCzvJStjySZVvOBsPl-Vgj0g" data-layout="default" data-theme="dark" data-count="default"></div>'+\
		'	</div>'+\
		'</div>'


		r['scaninfo'] = '<span class="card-title">Select a Nmap XML file</span><p>Nmap XML files: '+ str(len(xmlfiles)) +'</p>'

		r['trhost'] = ''
		r['trhead'] = '<tr><th>Filename</th><th>Scan Start Time</th><th>Hosts</th><th>&nbsp;</th></tr>'

		for i in xmlfiles:
			oo = xmltodict.parse(open('/opt/xml/'+i, 'r').read())
			r['out2'] = json.dumps(oo['nmaprun'], indent=4)
			o = json.loads(r['out2'])

			if type(o['host']) is not dict:
				hostnum = str(len(o['host']))
			else:
				hostnum = '1'

			r['trhost'] += '<tr>'+\
			'	<td style="font-family:monospace">'+html.escape(i)+'</td>'+\
			'	<td>'+html.escape(o['@startstr'])+'</td>'+\
			'	<td>'+hostnum+'</td>'+\
			'	<td><a href="/setscanfile/'+html.escape(i)+'" class="btn blue right">view</a></td>'+\
			'</tr>'

		# r['out'] = os.listdir('/opt/xml')
		return render(request, 'nmapreport/index.html', r)

	scanmd5 = hashlib.md5(str(request.session['scanfile']).encode('utf-8')).hexdigest()

	r['topcontainer'] = '<div class="fixed-action-btn">'+\
	'	<a class="btn-floating btn-large red">'+\
	'		<i class="large material-icons">mode_edit</i>'+\
	'	</a>'+\
	'	<ul>'+\
	'		<li><a class="btn-floating red tooltipped" data-position="left" data-tooltip="PDF Report" onclick="javascript:genPDF(\''+scanmd5+'\');"><i class="material-icons">insert_chart</i></a></li>'+\
	'		<li><a class="btn-floating blue darken-1 tooltipped" data-position="left" data-tooltip="Hide/Show hosts with no open ports" onclick="javascript:$(\'.zeroportopen\').fadeToggle();"><i class="material-icons">view_day</i></a></li>'+\
	'	</ul>'+\
	'</div>'

	# collect all labels in labelhost dict
	labelhost = {}
	labelfiles = os.listdir('/opt/notes')
	for lf in labelfiles:
		m = re.match('^('+scanmd5+')_([a-z0-9]{32,32})\.host\.label$', lf)
		if m is not None:
			if m.group(1) not in labelhost:
				labelhost[m.group(1)] = {}
			labelhost[m.group(1)][m.group(2)] = open('/opt/notes/'+lf, 'r').read()

	# collect all notes in noteshost dict
	noteshost = {}
	notesfiles = os.listdir('/opt/notes')
	for nf in notesfiles:
		m = re.match('^('+scanmd5+')_([a-z0-9]{32,32})\.notes$', nf)
		if m is not None:
			if m.group(1) not in noteshost:
				noteshost[m.group(1)] = {}
			noteshost[m.group(1)][m.group(2)] = open('/opt/notes/'+nf, 'r').read()

	tableout = ''
	hostsup = 0
	ports = { 'open': 0, 'closed': 0, 'filtered': 0 }
	allostypelist = {}
	sscount = {}
	picount = {}
	hostindex = 1

	r['trhost'] = ''
	r['trhead'] = '<tr><th width="260">Host</th><th>Port State</th><th width="160" style="text-align:center;">Tot Ports</th><th width="200">Services</th><th width="200">Ports</th><th>&nbsp;</th></tr>'

	for ik in o['host']:

		# this fix single host report
		if type(ik) is dict:
			i = ik
		else:
			i = o['host']

		hostname = ''

		if 'hostnames' in i and type(i['hostnames']) is dict:
			hostname += '<br><span style="color:#999;font-size:10px;">'+str(i['hostnames']['hostname']['@name'])+'</span>'

		if i['status']['@state'] == 'up':
			hostsup = (hostsup + 1)

		po,pc,pf = 0,0,0
		ss,pp,ost = {},{},{}
		lastportid = 0

		striggered = False
		if 'ports' in i and 'port' in i['ports']:
			for pobj in i['ports']['port']:
				if type(pobj) is dict:
					p = pobj
				else:
					p = i['ports']['port']

				if lastportid == p['@portid']:
					continue
				else:
					lastportid = p['@portid']

				if filterservice != "" and p['service']['@name'] == filterservice:
					striggered = True

				if filterportid != "" and p['@portid'] == filterportid:
					striggered = True

				ss[p['service']['@name']] = p['service']['@name']
				pp[p['@portid']] = p['@portid']

				if '@ostype' in p['service']:
					if p['service']['@ostype'] in allostypelist:
						allostypelist[p['service']['@ostype']] = (allostypelist[p['service']['@ostype']] +1)
					else:
						allostypelist[p['service']['@ostype']] = 1;

					ost[p['service']['@ostype']] = p['service']['@ostype']

				if p['service']['@name'] in sscount:
					sscount[p['service']['@name']] = (sscount[p['service']['@name']] + 1)
				else:
					sscount[p['service']['@name']] = 1

				if p['@portid'] in picount:
					picount[p['@portid']] = (picount[p['@portid']] + 1)
				else:
					picount[p['@portid']] = 1

					
				if p['state']['@state'] == 'closed':
					ports['closed'] = (ports['closed'] + 1)
					pc = (pc + 1)
				elif p['state']['@state'] == 'open':
					ports['open'] = (ports['open'] + 1)
					po = (po + 1)
				elif p['state']['@state'] == 'filtered':
					ports['filtered'] = (ports['filtered'] + 1)
					pf = (pf + 1)

			services = ''
			for s in ss:
				if filterservice != ss[s]:
					services += '<a href="/report/service/'+ss[s]+'/">'+ss[s]+'</a>, '
				else:
					services += '<span class="tmlabel" style="background-color:#ffcc00;color:#333;">'+ss[s]+'</span>, '

			ostype = ''
			for oty in ost:
				ostype += '<i class="'+fromOSTypeToFontAwesome(html.escape(ost[oty]))+'"></i> <span class="grey-text small">'+ost[oty].lower()+'</span> '

			tdports = ''
			for kp in pp:
				if filterportid != pp[kp]:
					tdports += '<a href="/report/portid/'+pp[kp]+'/">'+pp[kp]+'</a>, '
				else:
					tdports += '<span class="tmlabel" style="background-color:#ffcc00;color:#333;">'+pp[kp]+'</span>, '

			poclass = ''
			if po == 0:
				poclass = 'zeroportopen'

			if '@addr' in i['address']:
				address = i['address']['@addr']
			elif type(i['address']) is list:
				for ai in i['address']:
					if ai['@addrtype'] == 'ipv4':
						address = ai['@addr'] 

			addressmd5 = hashlib.md5(str(address).encode('utf-8')).hexdigest()
			labelout = '<span id="hostlabel'+str(hostindex)+'"></span>'
			if scanmd5 in labelhost:
				if addressmd5 in labelhost[scanmd5]:
					labelcolor = labelToColor(labelhost[scanmd5][addressmd5])
					labelmargin = labelToMargin(labelhost[scanmd5][addressmd5])
					labelout = '<span id="hostlabel'+str(hostindex)+'" style="margin-left:'+labelmargin+'" class="rightlabel '+labelcolor+'">'+html.escape(labelhost[scanmd5][addressmd5])+'</span>'

			notesout,notesb64,removenotes = '','',''
			if scanmd5 in noteshost:
				if addressmd5 in noteshost[scanmd5]:
					notesb64 = noteshost[scanmd5][addressmd5]
					notesout = '<br><a id="noteshost'+str(hostindex)+'" href="#!" onclick="javascript:openNotes(\''+hashlib.md5(str(address).encode('utf-8')).hexdigest()+'\', \''+notesb64+'\');" class="small"><i class="fas fa-comment"></i> contains notes</a>'
					removenotes = '<li><a href="#!" onclick="javascript:removeNotes(\''+addressmd5+'\', \''+str(hostindex)+'\');">Remove notes</a></li>'

			if (filterservice != "" and striggered is True) or (filterportid != "" and striggered is True) or (filterservice == "" and filterportid == ""):
				portstateout = '<td style="font-size:10px;color:#999;width:300px;"><div style="overflow:none;background-color:#666;" class="tooltipped" data-position="top" data-tooltip="'+str(po)+' open, '+str(pc)+' closed, '+str(pf)+' filtered">'+\
				'		<div class="perco" data-po="'+str(po)+'" style="padding-left:16px;padding-right:20px;">'+str(po)+'</div>'+\
				' </div></td>'

				if (filterservice != "" and striggered is True):
					portstateout = '<td style="font-size:10px;color:#999;width:300px;"><div style="overflow:none;background-color:#666;" class="tooltipped" data-position="top" data-tooltip="'+str(po)+' open, '+str(pc)+' closed, '+str(pf)+' filtered">'+\
					'		<div class="perco" data-po="'+str(po)+'" data-pt="'+str((po + pf + pc))+'" style="padding-left:16px;padding-right:20px;">'+str(po)+'</div>'+\
					'	</div></td>'

				r['trhost'] += '<tr class="'+poclass+'">'+\
				'	<td><span class="leftlabel" style="background-color:#4a4a4a;color:#999;">'+str(hostindex)+'</span>'+\
				'		'+ostype+'<br>'+\
				'		<b><a href="/report/'+str(address)+'">'+str(address)+'</a></b>'+hostname+''+\
				notesout+\
				'	</td>'+\
				portstateout+\
				'	<td style="font-family:monospace;text-align:center;">'+str((po + pf + pc))+'</td>'+\
				'	<td style="font-size:12px;">'+str(services[0:-2])+'</td>'+\
				'	<td style="font-size:12px;">'+str(tdports[0:-2])+'</td>'+\
				'	<td>'+\
				'		<ul id="hostdd'+str(hostindex)+'" class="dropdown-content" style="min-width:200px;">'+\
				'			<li><a href="#!" onclick="javascript:setLabel(\'host\', \'Vulnerable\', \''+hashlib.md5(str(address).encode('utf-8')).hexdigest()+'\', '+str(hostindex)+');"><span class="tmlabel red">Vulnerable</span></a></li>'+\
				'			<li><a href="#!" onclick="javascript:setLabel(\'host\', \'Critical\', \''+hashlib.md5(str(address).encode('utf-8')).hexdigest()+'\', '+str(hostindex)+');"><span class="tmlabel black">Critical</span></a></li>'+\
				'			<li><a href="#!" onclick="javascript:setLabel(\'host\', \'Warning\', \''+hashlib.md5(str(address).encode('utf-8')).hexdigest()+'\', '+str(hostindex)+');"><span class="tmlabel orange"><span class="tmlabel orange">Warning</span></a></li>'+\
				'			<li><a href="#!" onclick="javascript:setLabel(\'host\', \'Checked\', \''+hashlib.md5(str(address).encode('utf-8')).hexdigest()+'\', '+str(hostindex)+');"><span class="tmlabel blue"><span class="tmlabel blue">Checked</span></a></li>'+\
				'			<li><a href="#!" onclick="javascript:removeLabel(\'host\', \''+addressmd5+'\', '+str(hostindex)+');">Remove label</a></li>'+\
				'			<li class="divider"></li>'+\
				'			<li><a href="#!" onclick="javascript:openNotes(\''+hashlib.md5(str(address).encode('utf-8')).hexdigest()+'\', \''+notesb64+'\');">Insert notes</a></li>'+\
				'			'+removenotes+\
				'		</ul>'+\
				labelout+\
				'		<button class="btn darken-2 grey right dropdown-trigger" data-target="hostdd'+str(hostindex)+'"><i class="material-icons">arrow_drop_down</i></button>'+\
				'	</td>'+\
				'</tr>'
				hostindex = (hostindex + 1)

				# this fix single host report
				if type(ik) is not dict:
					break;

	totports = (ports['open']+ports['closed']+ports['filtered'])
	if filterservice == "" and filterportid == "":
		scaninfobox2 = '<canvas id="chart1"></canvas>'
		scaninfobox3 = '<canvas id="chart3" height="150"></canvas>'
	else:
		scaninfobox2 = ''+\
		'	Filter port / service: <b>'+html.escape(filterportid+filterservice)+'</b> <a href="/"><i class="fas fa-trash-alt"></i></a><br>'+\
		'	Total Ports: '+str(totports)+'<br>'+\
		'	Open Ports: '+str(ports['open'])+'<br>'+\
		'	Closed Ports: '+str(ports['closed'])+'<br>'+\
		'	Filtered Ports: '+str(ports['filtered'])+'<br>'
		scaninfobox3 = '<div id="detailstopports"></div>'

	r['scaninfo'] = ''+\
	'<div class="row">'+\
	'	<div class="col s4">Scan Information</div>'+\
	'	<div class="col s4">Ports Status</div>'+\
	'	<div class="col s4">Top Ports / Services</div>'+\
	'</div>'+\
	'<div class="row">'+\
	'	<div class="col s4">'+\
	'		<b class="orange-text">Start:</b> '+o['@startstr']+'<br>'+\
	'		<b class="orange-text">Scan Type:</b> '+o['scaninfo']['@type']+'<br>'+\
	'		<b class="orange-text">Scan Protocol:</b> '+o['scaninfo']['@protocol']+'<br>'+\
	'		<b class="orange-text">Nmap Command:</b> <a class="activator" href="#!">view details</a>'+\
	'	</div>'+\
	'	<div class="col s4" style="border-left:solid #999 1px;">'+\
	scaninfobox2+\
	'	</div>'+\
	'	<div class="col s4" style="border-left:solid #999 1px;">'+\
	scaninfobox3+\
	'	</div>'+\
	'</div>'

	r['scandetails'] = '<div class="code" style="word-wrap: break-word;overflow-wrap: break-word;">'+\
	'	<p>'+o['@args']+'</p>'+\
	'	<p>'+\
	'		version: '+o['@version']+'<br>'+\
	'		xmloutputversion: '+o['@xmloutputversion']+'<br>'+\
	'	</p>'+\
	'</div>'
		

	allss = ''
	allsslabels = ''
	allssdata = ''
	for i in sorted(sscount, key=sscount.__getitem__, reverse=True):
		if filterservice != i:
			allss += '<a href="/report/service/'+html.escape(i)+'/">'+html.escape(i)+'('+str(sscount[i])+')</a>, '
		else:
			allss += '<span class="tmlabel" style="background-color:#ffcc00;color:#333;">'+html.escape(i)+'</span>, '

		allsslabels += '"'+html.escape(i)+'", '
		allssdata += ''+str(sscount[i])+','

	allpilabels = ''
	allpidata = ''
	allpilinks = ''
	allpic = 1
	for i in sorted(picount, key=picount.__getitem__, reverse=True):
		allpilinks += '<a href="/report/portid/'+str(i)+'/">'+str(i)+'</a>, '
		if allpic <= 5:
			allpilabels += '"'+html.escape(i)+'", '
			allpidata += ''+str(picount[i])+','
			allpic = (allpic + 1)

	allostypelinks = ''
	for i in sorted(allostypelist, key=allostypelist.__getitem__, reverse=True):
		allostypelinks += '<a href="">'+str(i)+'</a>, '


	r['pretable'] = ''
	if filterservice == "" and filterportid == "":
		r['pretable'] += '<div class="row">'+\
		'	<div class="col s3" style="padding:1px;"><div class="card" style="text-align:center;padding:6px;background-color:#3e3e3e;"><h4><i class="fab fa-creative-commons-sampling"></i> <span class="blue-text">'+str(hostsup)+'</span></h4><span class="small grey-text">HOSTS UP</span></div></div>'+\
		'	<div class="col s3" style="padding:1px;"><div class="card" style="text-align:center;padding:6px;background-color:#3e3e3e;"><h4><i class="fas fa-door-open"></i> <span class="green-text">'+str(ports['open'])+'</span></h4><span class="small grey-text">OPEN PORTS</span></div></div>'+\
		'	<div class="col s3" style="padding:1px;"><div class="card" style="text-align:center;padding:6px;background-color:#3e3e3e;"><h4><i class="fas fa-door-closed"></i> <span class="red-text">'+str(ports['closed'])+'</span></h4><span class="small grey-text">CLOSED PORTS</span></div></div>'+\
		'	<div class="col s3" style="padding:1px;"><div class="card" style="text-align:center;padding:6px;background-color:#3e3e3e;"><h4><i class="fas fa-filter"></i> <span class="orange-text">'+str(ports['filtered'])+'</span></h4><span class="small grey-text">FILTERED PORTS</span></div></div>'+\
		'</div>'+\
		'<div class="card" style="background-color:#3e3e3e;">'+\
		'	<div class="card-content">'+\
		'		<div class="row">'+\
		'			<div class="col s4"><b>Services:</b></div><div class="col s8"><b>Services:</b></div>'+\
		'			<div class="col s4" style="border-right:solid #999 1px;margin-top:10px;min-height:410px;">'+\
		'				<span style="font-family:monospace;font-size:12px;">'+allss[0:-2]+'</span><br><br>'+\
		'				<b>Top 10 Ports:</b><br><span style="font-family:monospace;font-size:12px;">'+allpilinks[0:-2]+'</span><br><br>'+\
		'				<b>OS Type List:</b><br><span style="font-family:monospace;font-size:12px;">'+allostypelinks[0:-2]+'</span>'+\
		'			</div>'+\
		'			<div class="col s8" style="margin-top:10px;"><canvas id="chart2" height="200"></canvas></div>'+\
		'		</div>'+\
		'	</div>'+\
		'</div>'

		r['pretable'] += '<script>'+\
		'	$(document).ready(function() {'+\
		'		var ctx = document.getElementById("chart1").getContext("2d");'+\
		'		var myChart = new Chart(ctx, {'+\
		'			type: "doughnut", data: {labels:["Open", "Filtered", "Closed"], datasets: [{ data: ['+str(ports['open'])+','+str(ports['filtered'])+','+str(ports['closed'])+'], backgroundColor:["rgba(0,200,0,0.8)","rgba(255,200,0,0.8)","rgba(255,0,0,0.8)"], borderColor:"#3e3e3e" }]}, options: {legend: { position: "right", labels: { fontColor: "#cccccc" }  }}'+\
		'		});'+\
		'		var ctx = document.getElementById("chart3").getContext("2d");'+\
		'		var myChart = new Chart(ctx, {'+\
		'			type: "doughnut", data: {labels:['+allpilabels[0:-2]+'], datasets: [{ data: ['+allpidata[0:-1]+'], borderColor: "#3e3e3e",  backgroundColor:["#e6194b", "#3cb44b", "#ffe119", "#4363d8", "#f58231", "#911eb4", "#46f0f0", "#f032e6", "#bcf60c", "#fabebe", "#008080", "#e6beff", "#9a6324", "#fffac8", "#800000", "#aaffc3", "#808000", "#ffd8b1", "#000075", "#808080", "#ffffff", "#000000"] }]}, options: {legend: { position: "right", labels: { fontColor: "#cccccc" }}}'+\
		'		});'+\
		'		var ctx = document.getElementById("chart2").getContext("2d");'+\
		'		var myChart = new Chart(ctx, {'+\
		'			type: "horizontalBar", data: { labels:['+allsslabels[0:-2]+'], datasets: [{ data: ['+allssdata[0:-1]+'], backgroundColor: "rgba(0,140,220,0.8)" }]}, options: {legend: { display: false }, scales: { xAxes: [{ ticks: { beginAtZero: true, fontColor: "#cccccc" } }], yAxes: [{ ticks: { fontColor: "#cccccc" } }] }  }'+\
		'		});'+\
		'	});'+\
		'</script>'

	r['pretable'] += '<script>'+\
	'	$(document).ready(function() {'+\
	'		$("#scantitle").html("'+html.escape(request.session['scanfile'])+'");'+\
	'		$(".dropdown-trigger").dropdown();'+\
	'		$(".tooltipped").tooltip();'+\
	'		$(".perco").each(function() { '+\
	'			var pwidth = ( (($(this).attr("data-po") * 100) / '+str(totports)+') ); '+\
	'			/* console.log(pwidth); */ '+\
	'			$(this).css("width", pwidth+"%" ); '+\
	'			if($(this).attr("data-po") < 1) { $(this).html("&nbsp;"); $(this).css("background-color","#666") } '+\
	'		});'+\
	'	$("#detailstopports").html(\'<span class="small">'+str(allss[0:-2])+'</span>\');'+\
	'	});'+\
	'</script>'
	#r['pretable'] += '<button class="btn blue" onclick="javascript:$(\'.zeroportopen\').fadeToggle();">Hide/Show hosts with no open ports</button>'+\
	#'	<button class="btn red" onclick="javascript:genPDF(\''+scanmd5+'\');">PDF</button>'+\
	#'<br><br>'

	return render(request, 'nmapreport/index.html', r)


