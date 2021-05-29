<?php
if(!isset($_GET['id'])){
	echo('ID not set!');
	exit;
}
$ID = htmlspecialchars($_GET['id']);
$Text = "<center><br>\r\n\t<p id=\"loadLbl\">Loading detections...</p>\r\n\t<img id=\"detImg\" src=\"https://antiscan.me/images/result/$ID.png\" style=\"display: none;\">\r\n</center>\r\n<script>\r\n\t$(\"#detImg\").on(\"load\", function(){\r\n\t\t$(\"#loadLbl\").hide();\r\n\t\t$(\"#detImg\").show();\r\n\t});\r\n</script>";
file_put_contents("tabs/detections.html", $Text, LOCK_EX);
echo('Success.');
?>