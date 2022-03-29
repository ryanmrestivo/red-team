#						SNMP check. New worker. v1.1

## How to add new worker

### How does it work

When you click in browser at frontend url, cgi script  show the form using html-tempalate and  with ip, group, 
all_ipasolink (subgroup, inop, ucon, umng ) fields ( deppends of config.ini variable `iplistdb`) and any 
additional fields you need for selected snmp tools.  
When you press the button 'Send', script will check a parameters and if all ok and you confirm new task, then add new 
task into tasks table. Now you can see your new task in 'Tasks list' page with 'added' status.  
By crontab, special tool ( tool/task_starter.pl) check new added tasks, prepare special JSON file with parameters 
and start worker ( 'worker_with_threads.pl' script ). The status in 'Tasks list' changes from 'added' to 'started'.  
Worker get the parameters from JSON file, prepare IP list and begin runing special 'worker_body.sh' script by all IPs.   
'worker_body.sh' script get the ip and extendend parameters of device, and then communicates with a network entity 
using SNMP GET/SET requests, and write result in to temporary result file. All additional logic also realised in 'worker_body.sh' script.  
Worker prepare special JSON file with status, percent of executed IPs and  descriptions.   
When you refresh 'Tasks list', the status of task will changed to 'running'.   
When worker finish process of IPs, then task status will change to 'finished', combine all temporary result files in to full report file and open the link to report file. Now you can download the report file.  
If worked failed or frosen by any reason then 'task updater' wait any new JSON files during 1 hour. After it change 
the status of the task to 'failed'.  

When worker running:
any logs writing in ($$ - mean task id)
```
data/log/snmpcheck.log
data/log/worker.$$.log
```

JSON input and output files
```
data/json/$$.param.json
data/json/$$.out.json
```
report files:
```
html/report/*_$$_log.csv
```


### Prepare files for new worker.
Go to SNMPCHECK base dir. There are 3 files in skel directory. 
```
$ find data/skel/
data/skel/
data/skel/sample_template.htm
data/skel/sample_frontend.cgi
data/skel/sample_worker.pl_body.sh
```
For example you need to add new checking tool aaa.
Copy skel files to appropriate dirs with new filenames:
```
cp data/skel/sample_worker.pl_body.sh worker/body/aaa_worker.pl_body.sh
cp data/skel/sample_template.htm data/template/aaa.htm
cp data/skel/sample_frontend.cgi html/cgi-bin/aaa.cgi
chmod +x html/cgi-bin/aaa.cgi worker/body/aaa_worker.pl_body.sh
```


By default, frontend cgi-script use html-template file with form and by pressing button get the the next variable:
-	$Param->{ip}
-	$Param->{desc}
-	$Param->{group}
-	$Param->{subgroup}
-	$Param->{all_ipasolink}
-	$Param->{inop}
-	$Param->{ucon}
-	$Param->{umng}
-	$Param->{task_start_type}

By this variable frontend prepare JSON file for worker. If you need additional data for snmp tools, you can add fields into
template, and handler into frontend and worker for additional data. All parameters will be added into JSON automatically.


### Edit the html template
Edit html-template file if you need add new parameters to your worker. For example in `data/skel/sample_template.htm` you 
can see the variable _sample_variable_.


### Edit the frontend file
Add the new name `aaa` to variable _approved_application_for_no_authentication_ or _approved_application_for_authentication_ in your config.ini file.
```approved_application_for_authentication=ntp,tzauth,aaa```

Open file `html/cgi-bin/aaa.cgi` with any editor and edit the strings in comments string 'CHANGE_ME'. For example:
```
##############################################  
########### CHANGE_ME  
$sname="aaa";   # see approved_application_for_no_authentication and approved_application_for_authentication in config.ini  
$template = HTML::Template->new(filename => 'aaa.htm', die_on_bad_params=>0 );  
$title="AAA Application";  
########### END of CHANGE_ME  
##############################################  
```
To check and process any addiditional variable you need edit two other sections  with keyword  'CHANGE_ME'.
  
### Edit the worker_body.sh

All logic, SNMP requests and output you can change beetwen the sections '########### CHANGE ME' and '########### END OF CHANGE ME'.  
Also you can use any file in `worker/body/*.sh` as template for your new `worker_body.sh` file.


### Add your worker in database.
 - You cannot use new worker before add new record into snmpworker table.
 - Open url http://YOU_IP/cgi-bin/snmpworker.cgi
 - Click to link 'add new record' and add new record:
 - - name - select name 'aaa' from list ( this name you added into config.ini file !)
 - - desc - description	
 - - CGI script 	- select 'aaa.cgi' from list
 - - worker script - select 'worker_with_threads.pl' from list
 - - Worker body script 	- type 'aaa_worker.pl_body.sh' or absolute path to your body script. For example '/opt/snmp/newbody/aaa_worker.pl_body.sh'.
 - - Export params 	- there you need add additional parameters, divided by space. For example: `sample_variable one_more_var variable3`.
 - - Table header - there you add header of report table. For example: `NE name,IP,NE type,Result`.

## How to check the worker executed 
- Add link to your frontend into html/index.html file;
- Click to frontend url and insert parameters, confirm you add the task;
- Check status of your task in 'Tasks list'.
- If stautus do not changed from 'added' to 'started' or to 'running' during 3 minuts, please, check log files 
	`data/log/snmpcheck.log` and `data/log/worker.$$.log`. May be you faced with any errors.

	
## Old workers
If you wish to make own worker with parsing IP and external parameters or rewrite all logic of worker in perl
you can see in dir `worker/old_workers` previrouse verion of workers.
For execute any of them you need move worker from `worker/old_workers` to `worker` and in 
http://YOU_IP/cgi-bin/snmpworker.cgi select prefferd worker in `worker` field.

	
	
	  Licensing
  ---------
	GNU

  Contacts
  --------

     o korolev-ia [at] yandex.ru
     o http://www.unixpin.com

