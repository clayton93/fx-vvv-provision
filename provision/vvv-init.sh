#!/usr/bin/env bash

# Add the site name to the hosts file
echo "127.0.0.1 ${VVV_SITE_NAME}.local # vvv-auto" >> "/etc/hosts"

# Make a database, if we don't already have one
echo -e "\nCreating database '${VVV_SITE_NAME}' (if it's not already there)"
mysql -u root --password=root -e 'CREATE DATABASE IF NOT EXISTS \`${VVV_SITE_NAME}\`;'
echo "Created database, now giving permissions"
mysql -u root --password=root -e 'GRANT ALL PRIVILEGES ON \`${VVV_SITE_NAME}\`.* TO wp@localhost IDENTIFIED BY "wp";'
echo -e "\n DB operations done.\n\n"

# Nginx Logs
mkdir -p ${VVV_PATH_TO_SITE}/log
touch ${VVV_PATH_TO_SITE}/log/error.log
touch ${VVV_PATH_TO_SITE}/log/access.log

# Install and configure the latest stable version of WordPress
cd ${VVV_PATH_TO_SITE}
if ! $(wp core is-installed --allow-root); then
  wp core download --path="${VVV_PATH_TO_SITE}" --allow-root
  wp core config --dbname="${VVV_SITE_NAME}" --dbuser=wp --dbpass=wp --quiet --allow-root
  wp core multisite-install --url="${VVV_SITE_NAME}.local" --quiet --title="${VVV_SITE_NAME}" --admin_name=admin --admin_email="clayton@wearefx.co.uk" --admin_password="password" --allow-root



  wp theme install https://bitbucket.org/clayton93/fx-framework-2.0/get/HEAD.zip

  cd $(wp theme path)
  mv clayton93-fx-framework* ${VVV_SITE_NAME}
  wp theme activate ${VVV_SITE_NAME}

else
  wp core update --allow-root
fi