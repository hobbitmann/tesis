<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">
<html>
    <head>
        <title><?php $title ?></title>
    </head>
    <body>
        <p>
            <?php echo $message; ?>
            <br>
            <button onclick="location.href='<?php echo $back_url; ?>'" type="button">Volver</button>
        </p>
    </body>
</html>
