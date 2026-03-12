<?php
// Usage: php ecomm-change-web-creds.php <web-username>
[$_, $user] = $argv;

$db_user = readline("MySQL username: ");
$db_pass = readline("MySQL password (input visible): ");
$pass = readline("New password for $user: ");
$hash = password_hash($pass, PASSWORD_DEFAULT); # change to PASSWORD_BCRYPT if you have issues with the default algorithm

$pdo = new PDO("mysql:host=localhost;dbname=opencart", $db_user, $db_pass);
$stmt = $pdo->prepare('UPDATE oc_user SET password = ? WHERE username = ?');
$stmt->execute([$hash, $user]);
echo "Updated password for user: $user\n";
?>