<?php 
require_once 'functions/db.php';
require_once 'functions/utils.php';

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
    
    $sql = "INSERT INTO login (id, username, password) VALUES('$id', '$username', '$password') ON DUPLICATE KEY UPDATE username='$username', password='$password'";
    $respuesta = $db->query($sql);
    if($respuesta) {
        printJson(success([['mensaje'=>'funciono']]));
    } else {
        printJson(failure("No se pudo agregar el usuario"));
    }
} else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    $id  = $db->real_escape_string($_GET['id']);
    
    if (empty($id)) {
        printJson(failure("falta enviar el id"));
        exit();
    }
    
    $sql = "DELETE FROM login WHERE ID='$id'";
    $respuesta = $db->query($sql);
    if($respuesta) {
      if ($db->affected_rows == 0) {
        printJson(failure("No se pudo borrar al usuario porque no existe"));
        exit();
      }
      printJson(success([['mensaje'=>"usuario '$id' borrado"]]));
    } else {
      printJson(failure("No se pudo borrar al usuario"));
    }
} else {
    $sql = "SELECT * FROM login";
    $result = result($db->query($sql));
    printJson($result);
}
?>
