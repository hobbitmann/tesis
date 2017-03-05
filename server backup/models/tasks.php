<?php
require_once __DIR__.'/db.php';

function makeTask($id_phase, $name, $status) {
    global $db;
    
    if (empty($id_phase)) {
        return "falta enviar el id_phase";
    }
    if (empty($name)) {
        return "falta enviar el name";
    }
    
    $sql = "INSERT INTO task (id_phase, name, status) VALUES('$id_phase', '$name', '$status')";
    $respuesta = $db->query($sql);
    if(empty($respuesta)) {
        return "no se pudo ejecutar la query para crear la tarea '$name'. mysql reportó el siguiente error: '$db->error'";
    }
    
    $insert_id = $db->insert_id;
    if(empty($insert_id)) {
        return "no se pudo crear la tarea $name. mysql reportó el siguiente error: '$db->error'";
    }
    
    return $insert_id;
}

function getTasks($id_proyecto) {
    global $db;
    $sql = <<<SQL
        SELECT   phases.id, 
                 phases.nombre,
                 Concat('[', Group_concat(
                            '{"id":', task.id,
                            ',"name":"', task.NAME, '"',
                            ',"status":', task.status,
                            '}'),
                        ']') AS tasks_json 
        FROM     task 
        JOIN     phases 
        where    id_proyectos='$id_proyecto' and phases.id=task.id_phase
        GROUP BY phases.id
SQL;
    $rows = fetchRows($db->query($sql));
    
    foreach ($rows as $index => $phase) {
        $rows[$index]["tasks"] = json_decode($phase["tasks_json"], true);
        unset($rows[$index]["tasks_json"]);
    }
    return $rows;
}

function completeTask($id) {
    global $db;
    $sql = "UPDATE task SET status=1 WHERE id='$id'";
    $result = $db->query($sql);
    
    if(empty($db->affected_rows)) {
        return "no se pudo completar la tarea. mysql reportó el siguiente error: '$db->error'";
    }
    return null;
}
?> 
