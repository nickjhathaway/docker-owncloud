<?php
/*
 * A small autoconfig script that heavily uses environment variables
 */
$AUTOCONFIG = array(
  "directory" => "/owncloud-data/data",
  "dbtype" => getenv("DB_TYPE"),
  "dbname" => getenv("DB_NAME"),
  "dbtableprefix" =>  getenv("DB_TABLE_PREFIX") ? getenv("DB_TABLE_PREFIX") : "",
  "adminlogin" => getenv("ADMIN_LOGIN"),
  "adminpass" => getenv("ADMIN_PASS")
);

if (getenv("DB_TYPE") != "sqlite"){
  if (getenv("DB_TYPE") != "mysql" && getenv("DB_TYPE") != "pgsql"){
    echo "this?";
  	echo getenv("DB_TYPE");
  	echo getenv("DB_NAME");
  	echo "that";
    echo "!! Invalid DB selection: ".getenv("DB_TYPE")." - autoconfig not possible !!";
    unset($AUTOCONFIG);
    exit();
  } else {
    
    if (!getenv("DB_USER") || !getenv("DB_PASS")){
      echo "!! Invalid DB configuration. DB_USER and DB_PASS must be defined - autoconfig not possible !!";
      unset($AUTOCONFIG);
      exit();
    } else {
      $AUTOCONFIG["dbuser"] = getenv("DB_USER");
      $AUTOCONFIG["dbpass"] = getenv("DB_PASS");
      $AUTOCONFIG["dbhost"] = getenv("DB_HOST");
    }
  }
}

/*
 * A series of simple variables that can be pre-set in the auto-config using environment
 * varaibles. This can be easily extended by just adding entries.
 */
$OPTIONAL_SIMPLE_VARS = array(
  "LANGUAGE" => "default_language",
  "PROXY" => "proxy",
  "PROXY_USER_PASSWORD" => "proxyuserpwd"
);

foreach ($OPTIONAL_SIMPLE_VARS as $envVar => $autoConfigVar){
  if (getenv($envVar)){
    $AUTOCONFIG[$autoConfigVar] = getenv($envVar);
  }
}
unset($OPTIONAL_SIMPLE_VARS);