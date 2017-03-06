<?php
require_once __DIR__.'/db.php';
require_once __DIR__.'/phases.php';
require_once __DIR__.'/tasks.php';

function makeProject($Area, $Encargado, $FechaInicio, $FechaTermino, $Nombre, $usuarios_RUT, $id_usuario) {
    global $db;
    
    $sql = "INSERT INTO Proyectos (Area, Encargado, FechaInicio, FechaTermino, Nombre, usuarios_RUT) VALUES('$Area', '$Encargado', '$FechaInicio', '$FechaTermino', '$Nombre', '$usuarios_RUT')";
    $respuesta = $db->query($sql);
    if(empty($respuesta)) {
        return "no se pudo ejecutar la query para crear el proyecto $Nombre. mysql reportó el siguiente error: '$db->error'";
    }
    
    $insert_id = $db->insert_id;
    if(empty($insert_id)) {
        return "no se pudo crear el proyecto $Nombre. mysql reportó el siguiente error: '$db->error'";
    }
    
    $id_proyecto = $insert_id;
    
    $permiso_creador = 1;
    $sql = "INSERT INTO ProyectosUsuarios (Permisos, Proyecto, Usuario) VALUES ('$permiso_creador', '$id_proyecto', '$id_usuario')";
    $respuesta = $db->query($sql);
    if(empty($respuesta)) {
        return "no se pudo ejecutar la query para agregar permisos del proyecto $Nombre al usuario #$id_usuario. mysql reportó el siguiente error: '$db->error'";
    }
    
    $insert_id = $db->insert_id;
    if(empty($insert_id)) {
        return "no se pudo agregar permisos del proyecto $Nombre al usuario #$id_usuario. mysql reportó el siguiente error: '$db->error'";
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
    
    return $id_proyecto;
}

function updateProject($IDProyectos, $Area, $Encargado, $FechaInicio, $FechaTermino, $Nombre, $usuarios_RUT) {
    global $db;
    
    $sql = "UPDATE Proyectos SET Area='$Area', Encargado='$Encargado', FechaInicio='$FechaInicio', FechaTermino='$FechaTermino', Nombre='$Nombre', usuarios_RUT='$usuarios_RUT' WHERE IDProyectos='$IDProyectos'";
    $respuesta = $db->query($sql);
    if(empty($respuesta)) {
        return "No se pudo editar el proyecto. mysql reportó el siguiente error: '$db->error'";
    }
    if ($db->affected_rows == 0) {
        return "No se editó ningún proyecto. mysql reportó el siguiente error: '$db->error'";
    }
    
    return null;
}

function deleteProject($id) {
    global $db;
    
    $sql = "DELETE FROM Proyectos WHERE IDProyectos='$id'";
    $respuesta = $db->query($sql);
    if (empty($respuesta)) {
        return "No se pudo ejecutar la query. mysql reportó el siguiente error: '$db->error'";
    }
    if ($db->affected_rows == 0) {
        return "No se borró ningún proyecto. mysql reportó el siguiente error: '$db->error'";
    }
    
    return null;
}

function getProjects($id_usuario) {
    global $db;
    
    $sql = <<<SQL
        SELECT    Proyectos.*,
                  COALESCE(MIN(task.`status`), 0) as done
        FROM      Proyectos
        LEFT JOIN phases
        ON        Proyectos.`IDProyectos` = phases.`id_proyectos`
        LEFT JOIN task 
        ON        phases.id=task.id_phase
        JOIN      ProyectosUsuarios
        ON        Proyectos.`IDProyectos` = ProyectosUsuarios.`Proyecto`
        WHERE     ProyectosUsuarios.`Usuario` = '$id_usuario'
        GROUP BY  Proyectos.`IDProyectos`
SQL;

    return fetchRows($db->query($sql));
}

function getReport($FechaInicio, $FechaTermino) {
    global $db;

    if (empty($FechaInicio)) {
        $sqlFechaInicio = '';
    } else {
        $sqlFechaInicio = "AND `FechaInicio` > '$FechaInicio'";
    }

    if (empty($FechaTermino)) {
        $sqlFechaTermino = '';
    } else {
        $sqlFechaTermino = "AND `FechaTermino` < '$FechaTermino'";
    }
    
    $sql = <<<SQL
        SELECT    Proyectos.*,
                  COALESCE(MIN(task.`status`), 0) as done
        FROM      Proyectos
        LEFT JOIN phases
        ON        Proyectos.`IDProyectos` = phases.`id_proyectos`
        LEFT JOIN task 
        ON        phases.id=task.id_phase
        WHERE 1=1 $sqlFechaInicio $sqlFechaTermino
        GROUP BY  Proyectos.`IDProyectos`
SQL;

    return fetchRows($db->query($sql));
}

?> 
