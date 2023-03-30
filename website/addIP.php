<?php
    session_start();
    require_once('db_config.php');

    $ipToAdd = $_POST['IP'];
    $user = $_SESSION['user_id'];

    $SQL = "INSERT INTO user_ip (user_id, ip) VALUES (".$user.", '".$ipToAdd."');";
    mysqli_query($DB, $SQL);

    header("Location: home.php")
?>