<?php
function fetchRows($result){
    if ($result) {
        $rows = $result->fetch_all(MYSQLI_ASSOC);
        return $rows;
    } else {
        return null;
    }
}

function result($result){
    if ($rows = fetchRows($result)) {
        return success($rows);
    } else {
        return failure("No se pudo ejecutar la query");
    }
}

function success($data) {
    return [
        'status' => 'success',
        'data' => $data,
        'error' => ''
    ];
}

function failure($error) {
    return [
        'status' => 'failure',
        'data' => [],
        'error' => $error
    ];
}

function printJson($associativeArray) {
    echo json_encode($associativeArray, JSON_PRETTY_PRINT);
}
?>