<?php 
require_once '../../models/users.php';
require_once '../../views/api.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id       = $db->real_escape_string($_POST['id']);
    $username = $db->real_escape_string($_POST['username']);
    $password = $db->real_escape_string($_POST['password']);
    
    if (empty($id)) {
        printJson(failure("falta enviar el id"));
        exit();
    }
    if (empty($username)) {
        printJson(failure("falta enviar el username"));
        exit();
    }
    if (empty($password)) {
        printJson(failure("falta enviar el password"));
        exit();
    }
    
    $error = makeUser($id, $username, $password);
    if($error) {
        printJson(failure($error));
        exit();
    }
    
    //vista
    printJson(success([['mensaje'=>'funciono']]));
} else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    $id = $db->real_escape_string($_GET['id']);
    
    if (empty($id)) {
        printJson(failure("falta enviar el id"));
        exit();
    }
    
    $error = deleteUser($id);
    if($error) {
        printJson(failure($error));
        exit();
    }
    
    //vista
    printJson(success([['mensaje'=>"usuario '$id' borrado"]]));
} else {
    $rows = getUsers();

    // vista
    printJson(resultFromRows($rows));
}
?>
