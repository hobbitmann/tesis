<?php
require_once '../../models/users.php';
require_once '../../views/web.php';

$showLoginErrorMessage = false;
if (isset($_POST['NOMBRE'])) {
    $nombre = $_POST['NOMBRE'];
    $password = $_POST['PASSWORD'];
    
    $error = getUser($nombre, $password);
    if(is_string($error)) {
        $showLoginErrorMessage = true;
    } else {
        echo "<script> location.href='home.php'; </script>";
    }
}
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">
<html>
   <head>
      <meta charset="UTF-8">
      <title>Datos</title>
   </head>
   <body>
      <h2>Bienvenido a Billund</h2>
      <fieldset style="display: inline-block;">
          <legend>Login:</legend>
          <form action='index.php' method="post" name="form">
             <?php if($showLoginErrorMessage){ echo "</br>Error en login</br>$error</br>"; } ?>
             <table width="200" border="0">
                <tr>
                   <td>Nombre</td>
                   <td><input type="text" name="NOMBRE"></td>
                </tr>
                <tr>
                   <td>Password</td>
                   <td><input type="password" name="PASSWORD"></td>
                </tr>
             </table>
             <button>ENVIAR</button>
          </form>
      </fieldset>
   </body>
</html>
