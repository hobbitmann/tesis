<?php
/*
En objeto $db quedará nuestra base de datos,
siguiendo lo que dice la documentación.
http://php.net/manual/en/mysqli.construct.php
*/

// $db = new mysqli('mysql.pt202.dreamhosters.com', 'pt202', 'wJ!*S*A6', 'pt202');
$db = new mysqli('127.0.0.1', '', '', 'test');

/* check connection */
if ($db->connect_errno) {
    printf("Connect failed: %s\n", $mysqli->connect_error);
    exit();
}

$db->set_charset("utf8");

function fetchRows($result){
    if ($result) {
        $rows = $result->fetch_all(MYSQLI_ASSOC);
        return $rows;
    } else {
        return null;
    }
}
?>
