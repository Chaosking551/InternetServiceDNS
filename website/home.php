<?php
    session_start();
    require_once('db_config.php');
?>

<html>
    <body>
        <?php
            echo '<h3>Hallo '.$_SESSION['user_name']. "</h3><br>";


            $SQL = "SELECT * FROM user_ip WHERE user_id =".$_SESSION['user_id'].";";
            $result = mysqli_query($DB, $SQL);


            if(mysqli_num_rows($result) != 0) {
                echo "Du hast folgende IPs hinterlegt:";
                echo "<form method='post' action='removeIP.php'>";
                while ($row = mysqli_fetch_assoc($result)) {
                    echo $row['ip'] . "  <button type='submit' name='delete' value='" . $row['ip'] . "'> Entfernen </button><br>";
                }
                echo "</form>";
            }
            else
                echo 'Füge deine erste IP hinzu: ';

            echo "<br><form method='post' action='addIP.php'>
                <input type ='text' name ='IP' placeholder ='neue IP' required/><br>
                <input type ='submit' value ='Neue IP hinzufügen' onclick ='select()'/>
            </form>";

        ?>
        <br>
        <form action="logout.php" style="margin-top: 50px">
            <input type='submit' value='Abmelden' onclick='select()'/>
        </form>
        </body>
</html>
