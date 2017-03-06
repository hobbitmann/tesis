<?php 
require_once '../../models/permissions.php';
require_once '../../views/api.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $Permisos = $db->real_escape_string($_POST['Permisos']);
    $Proyecto = $db->real_escape_string($_POST['Proyecto']);
    $Usuario  = $db->real_escape_string($_POST['Usuario']);
    
    if (empty($Permisos)) {
        printJson(failure("falta enviar el Permisos"));
        exit();
    }
    if (empty($Proyecto)) {
        printJson(failure("falta enviar el Proyecto"));
        exit();
    }
    if (empty($Usuario)) {
        printJson(failure("falta enviar el Usuario"));
        exit();
    }
    
    $error = makePermission($Permisos, $Proyecto, $Usuario);
    if($error) {
        printJson(failure($error));
        exit();
    }
    
    //vista
    printJson(success([['mensaje'=>'funciono']]));
} else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    $id = $db->real_escape_string($_GET['id']);
    
    if (empty($id)) {
        printJson(failure("falta enviar el id"));
        exit();
    }
    
    $error = deletePermission($id);
    if($error) {
        printJson(failure($error));
        exit();
    }
    
    //vista
    printJson(success([['mensaje'=>"proyecto '$Permisos' borrado"]]));
} else {
    $Proyecto = $db->real_escape_string($_GET['Proyecto']);
    if (empty($Proyecto)) {
        printJson(failure("falta enviar el Proyecto"));
        exit();
    }
    
    $rows = getPermissions($Proyecto);

    // vista
    printJson(resultFromRows($rows));
}
?>
