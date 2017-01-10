<?php 
require_once '../../models/clients.php';
require_once '../../views/api.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $rut       = $db->real_escape_string($_POST['Rut']);
    $clientName = $db->real_escape_string($_POST['ClientName']);
    $entry = $db->real_escape_string($_POST['Entry']);
    
    if (empty($rut)) {
        printJson(failure("falta enviar el Rut"));
        exit();
    }
    if (empty($clientName)) {
        printJson(failure("falta enviar el ClientName"));
        exit();
    }
    if (empty($entry)) {
        printJson(failure("falta enviar el Entry"));
        exit();
    }
    
    $error = makeClient($rut, $clientName, $entry);
    if($error) {
        printJson(failure($error));
        exit();
    }
    
    //vista
    printJson(success([['mensaje'=>'funciono']]));
} else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    $rut = $db->real_escape_string($_GET['Rut']);
    
    if (empty($rut)) {
        printJson(failure("falta enviar el Rut"));
        exit();
    }
    
    $error = deleteClient($rut);
    if($error) {
        printJson(failure($error));
        exit();
    }
    
    //vista
    printJson(success([['mensaje'=>"cliente '$rut' borrado"]]));
} else {
    $rows = getClients();

    // vista
    printJson(resultFromRows($rows));
}
?>
