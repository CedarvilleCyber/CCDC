<?php
// Usage: php ecomm-change-web-creds.php

require_once('/var/www/html/opencart/upload/config.php');

$version = readline("Enter OpenCart major version (3 or 4): ");
$user = readline("Enter username to update: ");
$pass = readline("New password for $user: ");
$pass_confirm = readline("Confirm password: ");

if ($pass !== $pass_confirm) {
    echo "Passwords do not match. Try again.\n";
    exit(1);
}

if ($version == '3') {
    $salt = substr(str_shuffle('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'), 0, 9);
    $hash = sha1($salt . sha1($salt . sha1($pass)));
}
elseif ($version == '4') {
    $hash = password_hash($pass, PASSWORD_DEFAULT); # change to PASSWORD_BCRYPT if you have issues with the default algorithm
}
else {
    echo "Invalid version. Please enter 3 or 4.\n";
    exit(1);
}


$mysqli = new mysqli(DB_HOSTNAME, DB_USERNAME, DB_PASSWORD, DB_DATABASE);
$stmt = $mysqli->prepare('UPDATE oc_user SET password = ? WHERE username = ?');
$stmt->execute([$hash, $user]);
echo "Updated password for user: $user\n";
?>