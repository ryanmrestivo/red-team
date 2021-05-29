<?php
include('data.php');

if(!ConnectDB('plague')){
	http_response_code(500);
	die('Failed to connect to the database.');
}

if(!isset($_POST['r_user'])){
	header('Location: register.php?noUser');
	exit;
} else $_User = htmlspecialchars($_POST['r_user']);
if(!isset($_POST['r_pass'])){
	header('Location: register.php?noPass');
	exit;
} else $_Pass = strtoupper(hash('sha256', $_POST['r_pass'] . SALT));
if(!isset($_POST['magic'])){
	header('Location: register.php?noMagic');
	exit;
} else $Magic = strtoupper(hash('sha256', $_POST['magic']));

if(!UserValid($_User, $_Pass)){
	if($Magic==MasterKey){
		RegisterUser($_User, $_Pass, 'Master');
		header('Location: index.php?regSuccess');
	} elseif($Magic==ObserverKey){
		RegisterUser($_User, $_Pass, 'Observer');
		header('Location: index.php?regSuccess');
	} else {
		header('Location: register.php?wrongMagic');
	}
} else header('Location: register.php?userExists');
?>