<?php
require_once '../../models/tasks.php';
require_once '../../views/api.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id_task = $db->real_escape_string($_POST['id_task']);
    if (empty($id_task)) {
        printJson(failure("falta enviar el id_task"));
        exit();
    }
    
    $error = completeTask($id_task);
    if($error) {
        printJson(failure("No se pudo completar la tarea"));
        exit();
    }
    
    printJson(success([['mensaje'=>'Se completó la tarea exitosamente']]));
} else {
    $id_proyecto = $db->real_escape_string($_GET['id_proyecto']);
    if (empty($id_proyecto)) {
        printJson(failure("falta enviar el id_proyecto"));
        exit();
    }

    $rows = getTasks($id_proyecto);
    printJson(resultFromRows($rows));
}
?>
