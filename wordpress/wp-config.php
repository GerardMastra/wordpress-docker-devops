<?php
define( 'WP_CACHE', true );





//Begin Really Simple SSL session cookie settings
@ini_set('session.cookie_httponly', true);
@ini_set('session.cookie_secure', true);
@ini_set('session.use_only_cookies', true);
//END Really Simple SSL

/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** MySQL database username */
define( 'DB_USER', 'wpuser' );

/** MySQL database password */
define( 'DB_PASSWORD', 'wppass' );

/** MySQL hostname */
define( 'DB_HOST', 'mysql:3306' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',          'w|M!k128wpE>)Jh@S{c0^KC/fJnr]]x0a6WN0?6Y&/xzyHr<ho|f&&_5 )o@6FFp' );
define( 'SECURE_AUTH_KEY',   'w&k4D%RuCPy:X$(ec-k%XXN;s:}ceWtzdv{M+?ulc#*X[pUtSa^uBil24Qbl{kZI' );
define( 'LOGGED_IN_KEY',     'q&o{Lp)&#pHn{f`.ik_Zh0O^T%lP~uhBu:TI:,FvP,10>yjNe/sdVbz9RFM{>> J' );
define( 'NONCE_KEY',         'WfR#(-&d(0,?v5$3=+vl^G0;j}3/n>Ch1HMh3NqG oTkqV)9q(S=wz6;N,Ogknb-' );
define( 'AUTH_SALT',         'KWGFk0wp)N%+MjS~~>$ldm?!pCRd%s`@ccN2g`<_hrCfYiwmPN3.)3=Sl%3|[!Z*' );
define( 'SECURE_AUTH_SALT',  'xrg#45?T&k73VG@BBa]5zh?Ig.+:3`gi=46:_~)0W&Fc4n$3Lix/~B&Cv[%Hi7&9' );
define( 'LOGGED_IN_SALT',    'I|I#!}U[rB89C-_m/:wWKoaQQxVo:>~]8hQ}1{tcj>m~FN{gm~V#qIcT,m(V;O&?' );
define( 'NONCE_SALT',        'F{ ];=zAraFuBS&WP&{76E4nD(ME8*[#U|@plol9223nWn<Q-ma;$em)8(|O(Q1@' );
define( 'WP_CACHE_KEY_SALT', 'S5[$4(|X+O<OU|Bf1blSNAHU@M7dWhv];Ost`6mtnHcm2dJBnL*E=p8@/{-:4{hw' );

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';




define( 'WP_AUTO_UPDATE_CORE', true );
define( 'FS_METHOD', 'direct' );
/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
