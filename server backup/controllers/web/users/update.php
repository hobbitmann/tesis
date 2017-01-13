<?php
require_once '../../../models/users.php';
require_once '../../../views/api.php';

function alertPage($title, $message) {
    $back_url = "../users.php";
    include "../../../views/alert_page.php";
    exit();
}

$username = $db->real_escape_string($_POST['username']);
$password = $db->real_escape_string($_POST['password']);

if (empty($username)) {
    alertPage("Error", "Falta enviar el username");
}
if (empty($password)) {
    alertPage("Error", "Falta enviar el password");
}


$error = makeUser($username, $password);
if($error) {
    alertPage("Error", $error);
}

alertPage("Exito", "Se creó el usuario exitosamente.");
?>
