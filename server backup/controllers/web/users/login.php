<?php 
require_once '../../models/users.php';
require_once '../../views/api.php';

$nombre   = $db->real_escape_string($_POST['nombre']);
$password = $db->real_escape_string($_POST['password']);

if (empty($nombre)) {
    printJson(failure("falta enviar el nombre"));
    exit();
}
if (empty($password)) {
    printJson(failure("falta enviar el password"));
    exit();
}
$result = getUser($nombre, $password);
if(is_string($result)) {
    printJson(failure($result));
    exit();
}

printJson(success($result));

?>
