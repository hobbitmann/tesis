<?php
require_once '../../models/projects.php';
require_once '../../views/web.php';
require_once '../../models/tasks.php';

function alertPage($title, $message) {
    $back_url = "projects.php";
    include "../../views/alert_page.php";
    exit();
}

$id = $_GET['id'];
if (empty($id)) {
    alertPage("Error", "falta enviar el id");
}
$proyecto = null;
foreach (getProjects() as $p) {
    if ($p["IDProyectos"] == $id) {
        $proyecto = $p;
        break;
    }
}
if (empty($proyecto)) {
    alertPage("Error", "lo sentimos, ese proyecto ya no existe");
}

$titulos_tabla = ["ID", "Nombre", "Fecha Inicio", "Fecha Término", "Area", "Encargado", "Rut"];
$tabla_de_proyectos = tableFromArrayOfAssocArrays([$proyecto], $titulos_tabla);

$fases = getTasks($proyecto["IDProyectos"]);
$html_fases = "";
$last_task = null;
$id_project = $id;
foreach ($fases as $fase) {
    $nombre = $fase["nombre"];
    $id = $fase["id"];
    
    $tasks_with_buttons = [];
    foreach ($fase["tasks"] as $task) {
        $task_with_button = $task;
        $task_with_button["status"] = taskStatus($task, $last_task, $id_project);
        $last_task = $task;
        $tasks_with_buttons[] = $task_with_button;
    }
    
    $titulos = ["ID", "Nombre Tarea"];
    $tasks_table = tableFromArrayOfAssocArrays($tasks_with_buttons, $titulos);
    $html_fases .=  <<<HTML
        <fieldset style="display: inline-block;">
            <legend>$nombre (id_phase: $id)</legend>
            $tasks_table
        </fieldset style="display: inline-block;">
        <br/>
HTML;
}

function taskStatus($task, $last_task, $id_project) {
    $id_task = $task["id"];
    $task_is_uncompleted = $task["status"] == 0;
    $last_task_status = $last_task["status"];
    $last_task_was_completed = $last_task_status == 1;
    $is_first_uncompleted_task = $task_is_uncompleted && ($last_task_was_completed || is_null($last_task_status));
    
    if ($is_first_uncompleted_task) {
        return <<<HTML
            <form action='tasks/complete.php' method="post">
                <input type="hidden" value="$id_task" name="id" />
                <input type="hidden" value="$id_project" name="id_project" />
                <input type="submit" value="Completar"/>
            </form>
HTML;
    } else {
        $checked = $task_is_uncompleted ? "" : "checked";
        return "<input type='checkbox' $checked disabled/>";
    }
}
?>


<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title><?php echo $proyecto["Nombre"]; ?></title>
    </head>
    <body>
        <h1>Proyecto: <?php echo $proyecto["Nombre"]; ?></h1>
        <?php echo $tabla_de_proyectos; ?>
        <h2>Fases:</h2>
        <?php echo $html_fases; ?>
    </body>
    </head>
</html>
