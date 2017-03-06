<?php
require_once '../../models/projects.php';
require_once '../../views/api.php';

$FechaInicio = $db->real_escape_string($_GET['FechaInicio']);
$FechaTermino = $db->real_escape_string($_GET['FechaTermino']);

$rows = getReport($FechaInicio, $FechaTermino);
printJson(resultFromRows($rows));

?>
