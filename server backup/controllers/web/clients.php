<?php 
require_once '../../models/clients.php';
require_once '../../views/web.php';

$titulos_tabla = ["Rut", "Nombre Cliente", "Entry"];
$clientes = getClients();
$tabla_de_clientes = tableFromArrayOfAssocArrays($clientes, $titulos_tabla);

?>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Clientes</title>
    </head>
    <body>
        <h1>Clientes</h1>
        <?php echo $tabla_de_clientes; ?>
        <form action='clients/delete.php' method="post" border="1">
            <fieldset style="display: inline-block;">
                <legend>Borrar Cliente:</legend>
                <table width="200">
                    <tr>
                        <td>Rut</td>
                        <td><input type="text" name="Rut"></td>
                    </tr>
                </table>
                <input type="submit" value="Borrar"/>
            </fieldset>
        </form>
        <form action='clients/create.php' method="post">
            <fieldset style="display: inline-block;">
                <legend>Crear Cliente:</legend>
                <table width="200" borderph="0">
                    <tr>
                        <td>Rut</td>
                        <td><input type="text" name="Rut" placeholder="6.118.995-5"></td>
                    </tr>
                    <tr>
                        <td>Nombre Cliente</td>
                        <td><input type="text" name="ClientName" placeholder="Salmonfood"></td>
                    </tr>
                    <tr>
                        <td>Entry</td>
                        <td><input type="text" name="Entry" placeholder="Fishing"></td>
                    </tr>
                </table>
                <input type="submit" value="Crear"/>
            </fieldset>
        </form>
        <form action='clients/update.php' method="post">
            <fieldset style="display: inline-block;">
                <legend>Editar Cliente:</legend>
                <table width="200" borderph="0">
                    <tr>
                        <td>Rut</td>
                        <td><input type="text" name="Rut" placeholder="6.118.995-5"></td>
                    </tr>
                    <tr>
                        <td>Nombre Cliente</td>
                        <td><input type="text" name="ClientName" placeholder="Salmonfood"></td>
                    </tr>
                    <tr>
                        <td>Entry</td>
                        <td><input type="text" name="Entry" placeholder="Fishing"></td>
                    </tr>
                </table>
                <input type="submit" value="Editar"/>
            </fieldset>
        </form>
    </body>
</html>