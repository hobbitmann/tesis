<?php
/*
En objeto $db quedará nuestra base de datos,
siguiendo lo que dice la documentación.
http://php.net/manual/en/mysqli.construct.php
*/

$db = new mysqli('mysql.pt202.dreamhosters.com', 'pt202', 'wJ!*S*A6', 'pt202');

/* check connection */
if ($db->connect_errno) {
    printf("Connect failed: %s\n", $mysqli->connect_error);
    exit();
}
?>
