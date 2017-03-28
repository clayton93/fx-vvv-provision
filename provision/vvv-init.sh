#!/usr/bin/env bash

# Add the site name to the hosts file
echo "127.0.0.1 ${VVV_SITE_NAME}.local # vvv-auto" >> "/etc/hosts"

# Make a database, if we don't already have one
echo -e "\nCreating database '${VVV_SITE_NAME}' (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS \`${VVV_SITE_NAME}\`;"
echo "Created database, now giving permissions"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON \`${VVV_SITE_NAME}\`.* TO wp@localhost IDENTIFIED BY 'wp';"
echo -e "\n DB operations done.\n\n"

# Nginx Logs
mkdir -p ${VVV_PATH_TO_SITE}/log
touch ${VVV_PATH_TO_SITE}/log/error.log
touch ${VVV_PATH_TO_SITE}/log/access.log

# Install and configure the latest stable version of WordPress
echo 'going to path to site'
cd ${VVV_PATH_TO_SITE}
echo 'at path to site. now checking if wp installed'


echo "================================================================="
echo "Enter WordPress Installation Details!!"
echo "================================================================="
# accept user input for the db prefix
echo "Database Prefix (e.g. 'wp_'): "
read -e dbprefix

# accept the name of our website
echo "Site Name: "
read -e sitename

# accept the wp username
echo "WP Admin username: "
read -e wpuser

# accept the wp email
echo "WP Admin email: "
read -e wpemail



wp core download --path="${VVV_PATH_TO_SITE}" --quiet --allow-root
echo "downloaded core"

# wp core config --dbname="${VVV_SITE_NAME}" --dbuser=wp --dbpass=wp --dbprefix="$dbprefix" --quiet --allow-root --extra-php <<PHP
wp core config --dbname="${VVV_SITE_NAME}" --dbuser=wp --dbpass=wp --dbprefix="wp_" --quiet --allow-root --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'DISALLOW_FILE_EDIT', true );
PHP
echo "made config"


# generate password
# password=$(date | md5 -r)
# copy password to clipboard
# echo $password | pbcopy


# get primery host
echo 'before finding primary host'
primary_host=`cat ${VVV_CONFIG} | shyaml get-value sites.\"${SITE_ESCAPED}\".hosts.0 2> /dev/null`
echo 'just primary host start'
echo $primary_host
echo 'just primary host end'
echo 'after finding primary host'
$primary_host = ${primary_host:-$1}
echo 'after setting primary host'


# wp core install --url="${VVV_SITE_NAME}.dev" --quiet --title="$sitename" --admin_name="$wpuser" --admin_email="$wpemail" --admin_password="$password" --quiet --allow-root
wp core install --url="$primary_host" --quiet --title="${VVV_SITE_NAME}" --admin_name="admin" --admin_email="clayton@wearefx.co.uk" --admin_password="password" --quiet --allow-root
echo "installed core"




wp theme install https://bitbucket.org/clayton93/fx-framework-2.0/get/HEAD.zip --quiet --allow-root
echo "got theme"

cd $(wp theme path)
mkdir iamhere
echo "at theme path"

mv "clayton93-fx-framework"* ${VVV_SITE_NAME}
echo "renamed theme folder"

wp theme activate ${VVV_SITE_NAME} --quiet --allow-root
echo "activated theme"


echo "================================================================="
echo "Installation is complete. Your username/password is listed below."
echo ""
echo "Username: $wpuser"
echo "Password: $password"
echo ""
echo "================================================================="