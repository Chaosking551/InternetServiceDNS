<?php
    session_start();
    require_once('db_config.php');

    $username = strtolower($_POST['username']);
    $password = hash('sha256', $_POST['password']);

    $SQL = "SELECT * FROM user_data WHERE user_name = '".$username."' AND password = '".$password."';";
    $result = mysqli_query($DB, $SQL);
    $num_rows = mysqli_num_rows($result);
    $row = mysqli_fetch_assoc($result);

    if($num_rows == 1){
        $_SESSION['user_id'] = $row['user_id'];
        $_SESSION['user_name'] = $row['user_name'];
        $_SESSION['logged_in'] = true;
        header('Location: home.php');
    }
    else{
        echo "Falsche Einlogdaten!
                    <form action = 'Index.php'>
                        <input type='submit' value='Zurück' onclick='select()'/>
                    </form>
                ";
    }
?>
