<?php 
require_once 'functions/db.php';
require_once 'functions/utils.php';

$raw_id = $_GET['id'];
if(isset($raw_id)){
    $id = $db->real_escape_string($raw_id);
    $sql = "SELECT * FROM Fases WHERE FK_IDProyectos=$id";
    $result = result($db->query($sql));
    printJson($result);
} else {
    echoError("No se mando el *id* del proyecto");
}
?>
