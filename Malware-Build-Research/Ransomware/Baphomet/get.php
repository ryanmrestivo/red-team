<?php
   $info = $_GET['info'];
   $file = fopen("data.txt", "a");
   fwrite($file, $info."". PHP_EOL);
   fclose($file);
?>