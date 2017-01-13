<?php 
require_once '../../models/users.php';
require_once '../../views/web.php';

$titulos_tabla = ["ID", "Nombre Usuario", "Password"];
$usuarios = getUsers();
$tabla_de_usuarios = tableFromArrayOfAssocArrays($usuarios, $titulos_tabla);


?>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Usuarios</title>
    </head>
    <body>
        <h1>Usuarios</h1>
        <?php echo $tabla_de_usuarios; ?>
        <form action='users/delete.php' method="post" border="1">
            <fieldset style="display: inline-block;">
                <legend>Borrar Usuario:</legend>
                <table width="200">
                    <tr>
                        <td>ID</td>
                        <td><input type="text" name="id"></td>
                    </tr>
                </table>
                <input type="submit" value="Borrar"/>
            </fieldset>
        </form>
        <form action='users/create.php' method="post">
            <fieldset style="display: inline-block;">
                <legend>Crear Usuario:</legend>
                <table width="200" borderph="0">
                    <tr>
                        <td>Nombre</td>
                        <td><input type="text" name="username" placeholder="Juan Perez"></td>
                    </tr>
                    <tr>
                        <td>Password</td>
                        <td><input type="text" name="password" placeholder="••••••••••"></td>
                    </tr>
                </table>
                <input type="submit" value="Crear"/>
            </fieldset>
        </form>
        <form action='users/update.php' method="post">
            <fieldset style="display: inline-block;">
                <legend>Editar Usuario:</legend>
                <table width="200" borderph="0">
                    <tr>
                        <td>ID</td>
                        <td><input type="text" name="id" placeholder="42"></td>
                    </tr>
                    <tr>
                        <td>Nombre</td>
                        <td><input type="text" name="username" placeholder="Juan Perez"></td>
                    </tr>
                    <tr>
                        <td>Password</td>
                        <td><input type="text" name="password" placeholder="••••••••••"></td>
                    </tr>
                </table>
                <input type="submit" value="Editar"/>
            </fieldset>
        </form>
    </body>
</html>