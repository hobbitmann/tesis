<?php
function resultFromRows($rows){
    if (is_null($rows)) {
        return failure("No se pudo ejecutar la query");
    }

    return success($rows);
}

function result($result){
    $rows = fetchRows($result);
    return resultFromRows($rows);
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