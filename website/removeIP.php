<?php
    session_start();
    require_once('db_config.php');

    $ipToDelete = $_POST['delete'];

    $SQL = "DELETE FROM user_ip WHERE ip = '".$ipToDelete."';";
    mysqli_query($DB, $SQL);

    header("Location: home.php")
?>
