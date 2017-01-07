<?php
require_once '../../../models/clients.php';
require_once '../../../views/api.php';

function alertPage($title, $message) {
    $back_url = "../clients.php";
    include "../../../views/alert_page.php";
    exit();
}

$rut = $db->real_escape_string($_POST['Rut']);

if (empty($rut)) {
    alertPage("Error", "Falta enviar el Rut.");
}

$error = deleteClient($rut);
if($error) {
    alertPage("Error", $error);
}

alertPage("Exito", "Se borró el cliente exitosamente.");
?>
