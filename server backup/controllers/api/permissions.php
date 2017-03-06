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
    $Permisos = $db->real_escape_string($_GET['Permisos']);
    
    if (empty($Permisos)) {
        printJson(failure("falta enviar el Permisos"));
        exit();
    }
    
    $error = deletePermission($Permisos);
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
