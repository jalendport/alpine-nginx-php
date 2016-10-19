<?php
/**
 * General Configuration
 *
 * All of your system's general configuration settings go in here.
 * You can see a list of the default settings in craft/app/etc/config/defaults/general.php
 */
define('BASEPATH', '/app/public');
$devMode = isset($_ENV['CRAFT_ENV']) && $_ENV['CRAFT_ENV'] != 'production' ? true : false;

return array(
  'omitScriptNameInUrls'     => true,
  'allowAutoUpdates'         => false,
  'addTrailingSlashesToUrls' => true,
  'devMode'                  => $devMode,
  'siteUrl'                  => $_ENV['BASEURL'],

  'environmentVariables'     => array(
    'basePath'               => BASEPATH,
    'baseUrl'                => $_ENV['BASEURL']
  )
);
