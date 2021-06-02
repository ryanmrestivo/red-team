
<?php

$connection = new PDO('mysql:host=localhost;dbname=panel;charset=utf8', 'dbusername', 'password');
$connection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
//table name = dummy
$q = $connection->query('SELECT * FROM dummy');
?>