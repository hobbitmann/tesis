<?php
require_once '../../../models/users.php';
require_once '../../../views/api.php';

function alertPage($title, $message) {
    $back_url = "../users.php";
    include "../../../views/alert_page.php";
    exit();
}

$id = $db->real_escape_string($_POST['id']);

if (empty($id)) {
    "falta enviar el id";
    alertPage("Error", "Falta enviar el id.");
}

$error = deleteUser($id);
if($error) {
    alertPage("Error", $error);
}

alertPage("Exito", "Se borró el usuario exitosamente.");
?>
