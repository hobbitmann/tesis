<?php
require_once __DIR__.'/db.php';

function makePermission($Permisos, $Proyecto, $Usuario) {
    global $db;
    
    $sql = "INSERT INTO ProyectosUsuarios (Permisos, Proyecto, Usuario) VALUES('$Permisos', '$Proyecto', '$Usuario')";
    $respuesta = $db->query($sql);
    if(empty($respuesta)) {
        return "No se pudo agregar el proyecto. mysql reportó el siguiente error: '$db->error'";
    }
    
    return null;
}

function updatePermission($id, $Permisos, $Proyecto, $Usuario) {
    global $db;
    
    $sql = "INSERT INTO ProyectosUsuarios (id, Permisos, Proyecto, Usuario) VALUES('$id', '$Permisos', '$Proyecto', '$Usuario') ON DUPLICATE KEY UPDATE Permisos='$Permisos', Proyecto='$Proyecto', Usuario='$Usuario'";
    $respuesta = $db->query($sql);
    if(empty($respuesta)) {
        return "No se pudo editar el proyecto. mysql reportó el siguiente error: '$db->error'";
    }
    
    return null;
}

function deletePermission($id) {
    global $db;
    
    $sql = "DELETE FROM ProyectosUsuarios WHERE id='$id'";
    $respuesta = $db->query($sql);
    if (empty($respuesta)) {
        return "No se pudo ejecutar la query. mysql reportó el siguiente error: '$db->error'";
    }
    if ($db->affected_rows == 0) {
        return "No se borró ningún proyecto. mysql reportó el siguiente error: '$db->error'";
    }
    
    return null;
}

function getPermissions($Proyecto) {
    global $db;
    
    $sql = "SELECT * FROM ProyectosUsuarios WHERE Proyecto='$Proyecto'";
    return fetchRows($db->query($sql));
}
?> 
