<?php
require_once __DIR__.'/db.php';

function makeClient($rut, $clientName, $entry) {
    global $db;
    
    $sql = "INSERT INTO Clientes (Rut, ClientName, Entry) VALUES('$rut', '$clientName', '$entry') ON DUPLICATE KEY UPDATE Rut='$rut', ClientName='$clientName', Entry='$entry'";
    $respuesta = $db->query($sql);
    
    if(is_null($respuesta)) {
        return "No se pudo agregar el cliente";
    }
    
    return null;
}

function deleteClient($rut) {
    global $db;
    
    $sql = "DELETE FROM Clientes WHERE Rut='$rut'";
    $respuesta = $db->query($sql);
    if (is_null($respuesta)) {
        return "No se pudo ejecutar la query";
    }
    if ($db->affected_rows == 0) {
        return "No se borró ningún cliente";
    }
    
    return null;
}

function getClients() {
    global $db;
    
    $sql = "SELECT * FROM Clientes";
    return fetchRows($db->query($sql));
}

?> 
