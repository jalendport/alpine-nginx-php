<?php
/**
 * Database Configuration
 *
 * All of your system's database configuration settings go in here.
 * You can see a list of the default settings in craft/app/etc/config/defaults/db.php
 */
return array(
  'server'      => $_ENV['DB_HOST'],
  'port'        => $_ENV['DB_PORT'],
  'user'        => $_ENV['DB_USER'],
  'password'    => $_ENV['DB_PASS'],
  'database'    => $_ENV['DB_NAME'],
  'tablePrefix' => 'craft',
);
