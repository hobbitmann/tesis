<?php
require_once '../../models/tasks.php';
require_once '../../views/api.php';

$id_phase = $db->real_escape_string($_GET['id_phase']);
if (empty($id_phase)) {
    printJson(failure("falta enviar el id_phase"));
    exit();
}

$rows = getTasks($id_phase);

printJson(resultFromRows($rows));
?>
