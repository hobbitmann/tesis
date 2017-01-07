<?php
require_once __DIR__.'/db.php';

function makePhase($id_proyecto, $nombre) {
    global $db;
    
    if (empty($id_proyecto)) {
        return "falta enviar el id_proyectos";
    }
    if (empty($nombre)) {
        return "falta enviar el nombre";
    }
    
    $sql = "INSERT INTO phases (id_proyectos, nombre) VALUES('$id_proyecto', '$nombre')";
    $respuesta = $db->query($sql);
    if(is_null($respuesta)) {
        return "no se pudo ejecutar la query para crear la fase $nombre";
    }
    
    $insert_id = $db->insert_id;
    if(empty($insert_id)) {
        return "no se pudo crear la fase $nombre. mysql reportó el siguiente error: '$db->error'";
    }
    
    return $insert_id;
}

function getPhases($id_project) {
    global $db;
    
    $sql = "SELECT * FROM phases WHERE id_proyectos='$id_project'";
    return fetchRows($db->query($sql));
}
?> 
