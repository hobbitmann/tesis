<?php
require_once '../../../models/clients.php';
require_once '../../../views/api.php';

function alertPage($title, $message) {
    $back_url = "../clients.php";
    include "../../../views/alert_page.php";
    exit();
}


$rut = $db->real_escape_string($_POST['Rut']);
$clientName = $db->real_escape_string($_POST['ClientName']);
$entry = $db->real_escape_string($_POST['Entry']);

if (empty($rut)) {
    alertPage("Error", "Falta enviar el Rut");
}
if (empty($clientName)) {
    alertPage("Error", "Falta enviar el ClientName");
}
if (empty($entry)) {
    alertPage("Error", "Falta enviar el Entry");
}


$error = updateClient($rut, $clientName, $entry);
if($error) {
    alertPage("Error", $error);
}

alertPage("Exito", "Se editó el cliente exitosamente.");
?>
