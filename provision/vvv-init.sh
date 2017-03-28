#!/usr/bin/env bash

# Add the site name to the hosts file
echo "127.0.0.1 ${VVV_SITE_NAME}.local # vvv-auto" >> "/etc/hosts"

# Make a database, if we don't already have one
echo -e "\nCreating database '${VVV_SITE_NAME}' (if it's not already there)"
mysql -u root --password=root -e 'CREATE DATABASE IF NOT EXISTS \`${VVV_SITE_NAME}\`;'
echo "Created database, now giving permissions"
mysql -u root --password=root -e 'GRANT ALL PRIVILEGES ON \`${VVV_SITE_NAME}\`.* TO wp@localhost IDENTIFIED BY "wp";'
echo -e "\n DB operations done.\n\n"



# Install and configure the latest stable version of WordPress
echo 'going to path to site'
cd ${VVV_PATH_TO_SITE}
echo 'at path to site. now checking if wp installed'
if ! $(wp core is-ins.talled --allow-root); then
  wp core download --path="${VVV_PATH_TO_SITE}" --quiet --allow-root
  wp core config --dbname="${VVV_SITE_NAME}" --dbuser=wp --dbpass=wp --quiet --allow-root
  wp core multisite-install --url="${VVV_SITE_NAME}.local" --quiet --title="${VVV_SITE_NAME}" --admin_name=admin --admin_email="clayton@wearefx.co.uk" --admin_password="password" --quiet --allow-root



  wp theme install https://bitbucket.org/clayton93/fx-framework-2.0/get/HEAD.zip --quiet --allow-root

  cd $(wp theme path)
  mv clayton93-fx-framework* ${VVV_SITE_NAME}
  wp theme activate ${VVV_SITE_NAME} --quiet --allow-root

else
  wp core update --quiet --allow-root


# Nginx Logs
mkdir -p ${VVV_PATH_TO_SITE}/log
touch ${VVV_PATH_TO_SITE}/log/error.log
touch ${VVV_PATH_TO_SITE}/log/access.log


fi