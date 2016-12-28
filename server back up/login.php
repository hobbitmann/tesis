<?php
require_once 'functions/db.php';
require_once 'functions/utils.php';

$nombre   = $db->real_escape_string($_POST['nombre']);
$password = $db->real_escape_string($_POST['password']);
$sql = "SELECT * FROM login WHERE username='$nombre' AND password='$password'";
$rows = fetchRows($db->query($sql));

if (!empty($rows)) {
    $_SESSION['login'] = $nombre;
    $_SESSION['pass']  = $password;
    printJson(success($rows));
} else {
    printJson(failure("Nombre o password incorrecto"));
}
?>
