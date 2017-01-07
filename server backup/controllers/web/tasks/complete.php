<?php
require_once '../../../models/tasks.php';
require_once '../../../views/api.php';

function alertPage($title, $message, $id_project) {
    $back_url = "../project.php?id=$id_project";
    include "../../../views/alert_page.php";
    exit();
}

$id = $db->real_escape_string($_POST['id']);
$id_project = $db->real_escape_string($_POST['id_project']);

if (empty($id)) {
    alertPage("Error", "Falta enviar el id", $id_project);
}

if (empty($id_project)) {
    alertPage("Error", "Falta enviar el id_project", $id_project);
}

$error = completeTask($id);
if($error) {
    alertPage("Error", $error, $id_project);
}

alertPage("Exito", "Se completó la tarea exitosamente.", $id_project);
?>
