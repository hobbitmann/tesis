<?php
require_once '../../models/projects.php';
require_once '../../views/api.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $Area = $db->real_escape_string($_POST['Area']);
    $Encargado = $db->real_escape_string($_POST['Encargado']);
    $FechaInicio = $db->real_escape_string($_POST['FechaInicio']);
    $FechaTermino = $db->real_escape_string($_POST['FechaTermino']);
    $Nombre = $db->real_escape_string($_POST['Nombre']);
    $usuarios_RUT = $db->real_escape_string($_POST['usuarios_RUT']);

    if (empty($Area)) {
        printJson(failure("falta enviar el Area"));
        exit();
    }
    if (empty($Encargado)) {
        printJson(failure("falta enviar el Encargado"));
        exit();
    }
    if (empty($FechaInicio)) {
        printJson(failure("falta enviar el FechaInicio"));
        exit();
    }
    if (empty($FechaTermino)) {
        printJson(failure("falta enviar el FechaTermino"));
        exit();
    }
    if (empty($Nombre)) {
        printJson(failure("falta enviar el Nombre"));
        exit();
    }
    if (empty($usuarios_RUT)) {
        printJson(failure("falta enviar el usuarios_RUT"));
        exit();
    }
    
    
    $insert_id = makeProject($Area, $Encargado, $FechaInicio, $FechaTermino, $Nombre, $usuarios_RUT);
    if(is_string($insert_id)) {
        printJson(failure($error));
        exit();
    }
    
    printJson(success([['id'=>"$insert_id"]]));
    
} else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    $id = $db->real_escape_string($_GET['id']);
    
    if (empty($id)) {
        printJson(failure("falta enviar el id"));
        exit();
    }
    
    $error = deleteProject($id);
    if($error) {
        printJson(failure($error));
        exit();
    }
    
    printJson(success([['mensaje'=>"proyecto '$id' borrado"]]));
} else {
    $rows = getProjects();

    printJson(resultFromRows($rows));
}
?>
