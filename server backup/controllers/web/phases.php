<?php
require_once '../../models/phases.php';
require_once '../../views/api.php';

$id_project = $db->real_escape_string($_GET['id_project']);
if (empty($id_project)) {
    printJson(failure("falta enviar el id_project"));
    exit();
}

$rows = getPhases($id_project);

printJson(resultFromRows($rows));
?>
