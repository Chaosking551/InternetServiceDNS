<?php
    session_start();
    if(isset($_SESSION['logged_in'])){
        header("Location: home.php");
    }
?>
<html>
    <body>
        <div>
            <h2>Login</h2>
            <form method="post" action="login.php" >
                <input type="text" name="username" placeholder="Username"/><br>
                <input type="password" name="password" placeholder="Password"/><br>
                <input type="submit" value="Submit" onclick="select()"/>
            </form>
        </div>
        <div>
            <h2>Registrierung</h2>
            <form method="post" action="register.php" >
                <input type="text" name="username" placeholder="Username"/><br>
                <input type="password" name="password" placeholder="Password"/><br>
                <input type="submit" value="Submit" onclick="select()"/>
            </form>
        </div>
    </body>
</html>