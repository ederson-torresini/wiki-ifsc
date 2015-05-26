<?php

if ( !defined( 'MEDIAWIKI' ) ) {
	exit;
}

$wgSitename = "Wiki Institucional";
$wgMetaNamespace = "Wiki_Institucional";
$wgScriptPath = "/wiki";
$wgArticlePath = "/wiki/$1";
$wgUsePathInfo = true;
$wgScriptExtension = ".php";
$wgServer = "https://www.openstack.sj.ifsc.edu.br";
$wgStylePath = "$wgScriptPath/skins";
$wgLogo = "$wgScriptPath/resources/assets/wiki.png";
$wgEnableEmail = true;
$wgEnableUserEmail = false; # UPO
$wgEmergencyContact = "webmaster@openstack.sj.ifsc.edu.br";
$wgPasswordSender = "webmaster@openstack.sj.ifsc.edu.br";
$wgEnotifUserTalk = false; # UPO
$wgEnotifWatchlist = false; # UPO
$wgEmailAuthentication = false;

$wgDBtype = "mysql";
$wgDBserver = "mysql:13306";
$wgDBname = "mediawiki";
$wgDBuser = "mediawiki";
$wgDBpassword = "mediawiki";
$wgDBprefix = "";
$wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=binary";
$wgDBmysql5 = true;

$wgMainCacheType = CACHE_MEMCACHED;
$wgMemCachedServers = array( 'wiki0:11211\r\nwiki1:11211' );
$wgUseGzip = true;
$wgEnableSidebarCache = true;

$wgEnableUploads = true;
$wgFileExtensions = array('gif','png','jpg','jpeg','svg','xls','doc','odt','pdf','ods','ppt','dia','odp','swf','exe','html','wmv','flv','mwv','zip','rar','jar','txt', 'sb', 'ogv', 'ogg', 'oga', 'sprite', 'm', 'qar');
$wgFileBlacklist = array('html', 'htm', 'js', 'jsb', 'php', 'phtml', 'php3', 'php4', 'php5', 'phps', 'shtml', 'jhtml', 'pl', 'py', 'cgi', 'scr', 'dll', 'msi', 'vbs', 'bat', 'com', 'pif', 'cmd', 'vxd', 'cpl');

$wgShellLocale = "C.UTF-8";
$wgLanguageCode = "pt-br";
$wgLocaltimezone = "America/Sao_Paulo";

$wgSecretKey = "8a3eeb546c648fe23143da01ddb7f497ae462130b91ddc0eb75d531abcfaaf7b";
$wgUpgradeKey = "e8e9c1bb1e551901";

$wgUseInstantCommons = true;
$wgRightsPage = "";
$wgRightsUrl = "http://creativecommons.org/licenses/by-nc-sa/3.0/";
$wgRightsText = "Creative Commons - Atribuição - Uso Não Comercial - Partilha nos Mesmos Termos";
$wgRightsIcon = "{$wgScriptPath}/resources/assets/licenses/cc-by-nc-sa.png";

$wgDiff3 = "/usr/bin/diff3";

$wgGroupPermissions['*']['createaccount'] = false;
$wgGroupPermissions['*']['edit'] = false;

require_once "$IP/skins/Vector/Vector.php";

# SimpleSAMLphp
$wgSessionName = "PHPSESSID";
require_once "$IP/extensions/SimpleSamlAuth/SimpleSamlAuth.php";
$wgSamlRequirement = SAML_LOGIN_ONLY;
$wgSamlCreateUser = true;
$wgSamlConfirmMail = false;
$wgSamlUsernameAttr = "urn:oid:0.9.2342.19200300.100.1.1";
$wgSamlRealnameAttr = "urn:oid:2.5.4.3";
$wgSamlMailAttr = "urn:oid:0.9.2342.19200300.100.1.3";
$wgSamlSspRoot = "/usr/share/simplesamlphp";
$wgSamlAuthSource = "idpcafe.ifsc.edu.br";
$wgSamlPostLogoutRedirect = null;

# RFC 1918
$wgUseSquid = true;
$wgUsePrivateIPs = true;
