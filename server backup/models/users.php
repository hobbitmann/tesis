<?php
require_once __DIR__.'/db.php';

function makeUser($username, $password) {
    global $db;
    
    $sql = "INSERT INTO login (username, password) VALUES('$username', '$password')";
    $respuesta = $db->query($sql);
    if(is_null($respuesta)) {
        return "No se pudo agregar el usuario";
    }
    
    return null;
}

function updateUser($id, $username, $password) {
    global $db;
    
    $sql = "INSERT INTO login (id, username, password) VALUES('$id', '$username', '$password') ON DUPLICATE KEY UPDATE username='$username', password='$password'";
    $respuesta = $db->query($sql);
    if(is_null($respuesta)) {
        return "No se pudo editar el usuario";
    }
    
    return null;
}

function deleteUser($id) {
    global $db;
    
    $sql = "DELETE FROM login WHERE id='$id'";
    $respuesta = $db->query($sql);
    if (is_null($respuesta)) {
        return "No se pudo ejecutar la query";
    }
    if ($db->affected_rows == 0) {
        return "No se borró ningún usuario";
    }
    
    return null;
}

function getUsers() {
    global $db;
    
    $sql = "SELECT * FROM login";
    return fetchRows($db->query($sql));
}

function getUser($username, $password) {
    global $db;
    
    $sql = "SELECT * FROM login WHERE username='$username' AND password='$password'";
    $respuesta = $db->query($sql);
    $rows = fetchRows($db->query($sql));
    
    if (empty($rows)) {
        return "Nombre o password incorrecto";
    }
    
    return $rows;
}
?> 
