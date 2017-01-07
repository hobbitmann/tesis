<?php
function tableFromArrayOfAssocArrays($array, $names = null) {
    if (empty($names)) {
        $first_row = $array[0];
        $names = array_keys($first_row);
    }
    $names_row = "";
    foreach ($names as $name) {
        $names_row .= "<td>$name</td>";
    }

    $all_value_rows = "";
    foreach ($array as $row) {
        $value_row = "";
        foreach ($row as $value) {
            $value_row .= "<td>$value</td>";
        }
    
        $all_value_rows .= "<tr>$value_row</tr>";
    }
    return "<table border = '1'><tr>$names_row</tr>$all_value_rows</table>";
}
?>