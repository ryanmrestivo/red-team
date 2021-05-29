<?php
session_start();
if(isset($_SESSION['user'])){
	header('Location: dashboard.php');
	exit;
}
$Msg = false;
$Error = true;
if(isset($_GET['noUser'])){
	$Msg = true;
	$TextMsg = 'Please enter a username!';
}
if(isset($_GET['noPass'])){
	$Msg = true;
	$TextMsg = 'Please enter a password!';
}
if(isset($_GET['noMagic'])){
	$Msg = true;
	$TextMsg = 'Please enter your Secret key!';
}
if(isset($_GET['wrongMagic'])){
	$Msg = true;
	$TextMsg = 'Invalid Secret key!';
}
if(isset($_GET['userExists'])){
	$Msg = true;
	$TextMsg = 'This username is taken!';
}
?>
<html>
    <head>
		<link href="https://fonts.googleapis.com/css?family=Krub" rel="stylesheet">
		<title>Project Plague</title>
		<link rel="shortcut icon" type="image/png" href="img/favicon.png"/>
		<link rel="stylesheet" type="text/css" href="style.css">
	</head>
    <body>
        <div class="loginbox" style="height: <?php if($Msg) echo('520'); else echo('470'); ?>px;">
        <img src="img/icon.png" class="avatar">
           <h1>Project Plague</h1>
		   <?php if($Msg) { ?>
		   <div class="<?php if($Error) echo("error"); else echo("success"); ?>">
				<p <?php if(!$Error) echo('style="color: #000000"'); echo('>' . $TextMsg); ?></p>
		   </div>
		   <div style="height: 20px;"></div> <?php } ?>
           <form action="reg.php" method="post" autocomplete="off">
               <p>Username</p>
               <input type="text" name="r_user">
               <p>Password</p>
               <input type="password" name="r_pass">
			   <p>Secret key</p>
			   <input type="text" name="magic">
               <input type="submit" name="" value="Register">
           </form>
        </div>
    </body>
</html>