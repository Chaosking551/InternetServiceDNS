<?php
// Setup Connection use $DB after including this file
$databaseHost = 'ipvar';
$databaseUsername = 'dns_user';
$databasePassword = 'dns';
$databaseName = 'dns_db';

global $DB;

$DB = mysqli_connect($databaseHost, $databaseUsername, $databasePassword, $databaseName);
if(!$DB) die('Connect: Could not connect: '.mysqli_error());

?>