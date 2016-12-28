<?php 
require_once 'functions/db.php';
require_once 'functions/utils.php';

$sql = "SELECT * FROM Proyectos";
$result = result($db->query($sql));
printJson($result);
?>
