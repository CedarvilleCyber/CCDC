<?php
# Usage: php ecomm-change-web-creds.php
# I wrote this in PHP to reduce breakable dependencies. OpenCart uses PHP and 
# the mysqli driver, meaning this script SHOULD work on the CCDC ecomm machine 
# without any changes. 

# import OpenCart config to get DB credentials (remember to harden these)
require_once('/var/www/html/opencart/upload/config.php');

$mysqli = new mysqli(DB_HOSTNAME, DB_USERNAME, DB_PASSWORD, DB_DATABASE);

if (!$mysqli) {
    echo "Database connection failed: " . mysqli_connect_error() . "\n";
    exit(1);
}

# List all users in oc_users table
echo "\n=== Users in OpenCart ===\n";
$result = $mysqli->query('SELECT user_id, username, email FROM oc_user ORDER BY user_id');

if ($result && $result->num_rows > 0) {
    printf("%-5s %-25s %-35s\n", "ID", "Username", "Email");
    echo str_repeat("-", 70) . "\n";
    while ($row = $result->fetch_assoc()) {
        printf("%-5s %-25s %-35s\n", $row['user_id'], $row['username'], $row['email']);
    }
} else {
    echo "No users found.\n";
    exit(1);
}
echo "\n";

$user = readline("Enter username to update: ");
$pass = readline("New password for $user: ");

$version = readline("Enter OpenCart major version (3 or 4): ");

if ($version == '3') {
    $salt = substr(str_shuffle('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'), 0, 9);
    $hash = sha1($salt . sha1($salt . sha1($pass)));
    $stmt = $mysqli->prepare('UPDATE oc_user SET password = ?, salt = ? WHERE username = ?');
    $stmt->execute([$hash, $salt, $user]);
}
elseif ($version == '4') {
    # change to PASSWORD_BCRYPT if you have issues with the default algorithm
    $hash = password_hash($pass, PASSWORD_DEFAULT); 
    $stmt = $mysqli->prepare('UPDATE oc_user SET password = ? WHERE username = ?');
    $stmt->execute([$hash, $user]);
}
else {
    echo "Invalid version. Please enter 3 or 4.\n";
    exit(1);
}

echo "Updated password for user: $user\n";
?>