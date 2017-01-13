<?php
require_once '../../../models/projects.php';
require_once '../../../views/api.php';

function alertPage($title, $message) {
    $back_url = "../projects.php";
    include "../../../views/alert_page.php";
    exit();
}

$IDProyectos = $db->real_escape_string($_POST['IDProyectos']);
$Area = $db->real_escape_string($_POST['Area']);
$Encargado = $db->real_escape_string($_POST['Encargado']);
$FechaInicio = $db->real_escape_string($_POST['FechaInicio']);
$FechaTermino = $db->real_escape_string($_POST['FechaTermino']);
$Nombre = $db->real_escape_string($_POST['Nombre']);
$usuarios_RUT = $db->real_escape_string($_POST['usuarios_RUT']);

if (empty($IDProyectos)) {
    alertPage("Error", "Falta enviar el IDProyectos");
}
if (empty($Area)) {
    alertPage("Error", "Falta enviar el Area");
}
if (empty($Encargado)) {
    alertPage("Error", "Falta enviar el Encargado");
}
if (empty($FechaInicio)) {
    alertPage("Error", "Falta enviar el FechaInicio");
}
if (empty($FechaTermino)) {
    alertPage("Error", "Falta enviar el FechaTermino");
}
if (empty($Nombre)) {
    alertPage("Error", "Falta enviar el Nombre");
}
if (empty($usuarios_RUT)) {
    alertPage("Error", "Falta enviar el usuarios_RUT");
}


$error = updateProject($IDProyectos, $Area, $Encargado, $FechaInicio, $FechaTermino, $Nombre, $usuarios_RUT);
if($error) {
    alertPage("Error", $error);
}

alertPage("Exito", "Se editó el proyecto exitosamente.");
?>
