<?php
    require_once('db_config.php');
?>

<?php
    $username = strtolower($_POST['username']);
    $password = hash('sha256', $_POST['password']);

    $SQL = "SELECT * FROM user_data WHERE user_name = '" . $username . "';";
    $result = mysqli_query($DB, $SQL);
    $num_rows = mysqli_num_rows($result);
    if ($num_rows == 0) {
        $SQL = "INSERT INTO user_data (user_name, password) VALUES ('" . $username . "', '" . $password . "');";
        mysqli_query($DB, $SQL);
        header('Location: index.php');
    } else {
        echo "User existiert bereits!
                    <form action = 'Index.php'>
                        <input type='submit' value='Zurück' onclick='select()'/>
                    </form>
                ";
    }
?>

