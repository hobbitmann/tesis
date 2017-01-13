<?php
require_once '../../models/projects.php';
require_once '../../views/web.php';

$titulos_tabla = ["ID", "Nombre", "Fecha Inicio", "Fecha Término", "Area", "Encargado", "Rut"];
$proyectos = getProjects();
foreach ($proyectos as $indice => $proyecto) {
    $id_proyecto = $proyecto["IDProyectos"];
    $proyectos[$indice]["boton_ver"] = "<button onclick=\"location.href='project.php?id=$id_proyecto'\" type='button'>Ver</button>";
}
$tabla_de_proyectos = tableFromArrayOfAssocArrays($proyectos, $titulos_tabla);


?>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Proyectos</title>
    </head>
    <body>
        <h1>Proyectos</h1>
        <?php echo $tabla_de_proyectos; ?>
        <!-- <form action='UpdateProject.php' method="post" name="form">
            <table width="200" borderph="0">
                <tr>
                    <td colspan="2">Ingresar datos de Proyecto a Editar</td>
                </tr>
                <tr>
                    <td>IDProyectos</td>
                    <td><input type="text" name="IDPROYECTOS"></td>
                    <td>Nombre</td>
                    <td><input type="text" name="NOMBRE"></td>
                    <td>FechaInicio</td>
                    <td><input type="date" name="FECHAINICIO"></td>
                    <td>FechaTermino</td>
                    <td><input type="date" name="FECHATERMINO"></td>
                </tr>
                <tr>
                    <td>Area</td>
                    <td><input type="text" name="AREA"></td>
                    <td>Encargado</td>
                    <td><input type="text" name="ENCARGADO"></td>
                    <td>usuarios_RUT</td>
                    <td><input type="text" name="USUARIOS_RUT"></td>
                </tr>
            </table>
            <input type="submit" value="edit" class="editbutton" id="btnedit" />
        </form> -->
        <form action='projects/delete.php' method="post" border="1">
            <fieldset style="display: inline-block;">
                <legend>Borrar Proyecto:</legend>
                <table width="200">
                    <tr>
                        <td>ID</td>
                        <td><input type="text" name="id"></td>
                    </tr>
                </table>
                <input type="submit" value="Borrar"/>
            </fieldset>
        </form>
        <form action='projects/create.php' method="post">
            <fieldset style="display: inline-block;">
                <legend>Crear Proyecto:</legend>
                <table width="200" borderph="0">
                    <tr>
                        <td>Nombre</td>
                        <td><input type="text" name="Nombre" placeholder="Juan Perez"></td>
                        <td>Fecha&nbspInicio</td>
                        <td><input type="date" name="FechaInicio" placeholder="yyyy-mm-dd"></td>
                        <td>Fecha&nbspTérmino</td>
                        <td><input type="date" name="FechaTermino" placeholder="yyyy-mm-dd"></td>
                    </tr>
                    <tr>
                        <td>Area</td>
                        <td><input type="text" name="Area" placeholder="Villa Alemana"></td>
                        <td>Encargado</td>
                        <td><input type="text" name="Encargado" placeholder="Don Ramón Valdés"></td>
                        <td>Rut</td>
                        <td><input type="text" name="usuarios_RUT" placeholder="12.345.678-K"></td>
                    </tr>
                </table>
                <input type="submit" value="Crear"/>
            </fieldset>
        </form>
        <form action='projects/update.php' method="post">
            <fieldset style="display: inline-block;">
                <legend>Editar Proyecto:</legend>
                <table width="200" borderph="0">
                    <tr>
                        <td>ID</td>
                        <td><input type="text" name="IDProyectos" placeholder="42"></td>
                    </tr>
                    <tr>
                        <td>Nombre</td>
                        <td><input type="text" name="Nombre" placeholder="Juan Perez"></td>
                        <td>Fecha&nbspInicio</td>
                        <td><input type="date" name="FechaInicio" placeholder="yyyy-mm-dd"></td>
                        <td>Fecha&nbspTérmino</td>
                        <td><input type="date" name="FechaTermino" placeholder="yyyy-mm-dd"></td>
                    </tr>
                    <tr>
                        <td>Area</td>
                        <td><input type="text" name="Area" placeholder="Villa Alemana"></td>
                        <td>Encargado</td>
                        <td><input type="text" name="Encargado" placeholder="Don Ramón Valdés"></td>
                        <td>Rut</td>
                        <td><input type="text" name="usuarios_RUT" placeholder="12.345.678-K"></td>
                    </tr>
                </table>
                <input type="submit" value="Editar"/>
            </fieldset>
        </form>
    </body>
</html>