<?php
session_start();
if(isset($_SESSION['user'])){
	header('Location: dashboard.php');
	exit;
}
$Msg = false;
$Error = false;
if(isset($_GET['wrong'])){
	$Msg = true;
	$Error = true;
	$TextMsg = 'Check your info!';
}
if(isset($_GET['regSuccess'])){
	$Msg = true;
	$TextMsg = 'Registration successful!';
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
        <div class="loginbox" <?php if($Msg) echo(' style="height: 470px;"'); ?>>
        <img src="img/icon.png" class="avatar">
           <h1>Project Plague</h1>
		   <?php if($Msg) { ?>
		   <div class="<?php if($Error) echo("error"); else echo("success"); ?>">
				<p <?php if(!$Error) echo('style="color: #000000"'); echo('>' . $TextMsg); ?></p>
		   </div>
		   <div style="height: 20px;"></div> <?php } ?>
           <form action="login.php" method="post">
               <p>Username</p>
               <input type="text" name="user">
               <p>Password</p>
               <input type="password" name="pass">
               <input type="submit" name="" value="Login">
           <br>
		   <a href="register.php">Register</a><br>
           </form>
        </div>
    </body>
</html>