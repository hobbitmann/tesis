<?php
require_once __DIR__.'/db.php';
require_once __DIR__.'/phases.php';
require_once __DIR__.'/tasks.php';

function makeProject($Area, $Encargado, $FechaInicio, $FechaTermino, $Nombre, $usuarios_RUT) {
    global $db;
    
    $sql = "INSERT INTO Proyectos (Area, Encargado, FechaInicio, FechaTermino, Nombre, usuarios_RUT) VALUES('$Area', '$Encargado', '$FechaInicio', '$FechaTermino', '$Nombre', '$usuarios_RUT')";
    $respuesta = $db->query($sql);
    if(is_null($respuesta)) {
        return "no se pudo ejecutar la query para crear el proyecto $Nombre";
    }
    
    $insert_id = $db->insert_id;
    if(empty($insert_id)) {
        return "no se pudo crear el proyecto $Nombre. mysql reportó el siguiente error: '$db->error'";
    }
    
    $fases_con_tareas = [
        "Venta" => [
            "Busqueda",
            "Firma",
            "Fin etapa"
        ],
        "Ingeniería" => [
            "Ajuste",
            "Desarrollo",
            "Fin Etapa"
        ],
        "Obra" => [
            "Firma",
            "Desarrollo",
            "Fabrica equipo",
            "Instalacion",
            "Fin Etapa"
        ],
        "Cierre" => [
            "Entrega",
            "Pruebas",
            "Capacitacion",
            "Fin Etapa"
        ],
    ];
    
    $id_proyecto = $insert_id;
    foreach ($fases_con_tareas as $nombre_fase => $tareas) {
        $id_phase = makePhase($id_proyecto, $nombre_fase);
        if (is_string($id_phase)) {
            return $id_phase;
        }
        
        foreach ($tareas as $nombre_tarea) {
            $status = 0;
            $id_task = makeTask($id_phase, $nombre_tarea, $status);
            if (is_string($id_task)) {
                return $id_task;
            }
        }
    }
    
    return $insert_id;
}

function deleteProject($id) {
    global $db;
    
    $sql = "DELETE FROM Proyectos WHERE IDProyectos='$id'";
    $respuesta = $db->query($sql);
    if (is_null($respuesta)) {
        return "No se pudo ejecutar la query";
    }
    if ($db->affected_rows == 0) {
        return "No se borró ningún proyecto";
    }
    
    return null;
}

function getProjects() {
    global $db;
    
    $sql = "SELECT * FROM Proyectos";
    return fetchRows($db->query($sql));
}
?> 
