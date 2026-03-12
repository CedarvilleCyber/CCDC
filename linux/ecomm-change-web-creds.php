<?php
// Usage: php ecomm-change-web-creds.php

require_once('/var/www/html/opencart/upload/config.php');

$user = readline("Enter username to update: ");
$pass = readline("New password for $user: ");
$hash = password_hash($pass, PASSWORD_DEFAULT); # change to PASSWORD_BCRYPT if you have issues with the default algorithm

$pdo_temp = new PDO("mysql:host=localhost;dbname=opencart", DB_USERNAME, DB_PASSWORD);
$stmt = $pdo_temp->prepare('UPDATE oc_user SET password = ? WHERE username = ?');
$stmt->execute([$hash, $user]);
echo "Updated password for user: $user\n";
?>