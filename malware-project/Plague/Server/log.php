<?php
function LogStr($Str){
	$FileName = "logs/Log_" . date("Y-m-d") . ".txt";
	file_put_contents($FileName, "[" . date("Y-m-d H:i:s") . "] " . $Str . "\n", FILE_APPEND | LOCK_EX);
}
?>