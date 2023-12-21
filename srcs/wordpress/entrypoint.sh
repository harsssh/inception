#!/bin/sh
set -ex

setup_wordpress() {
  if su-exec www-data wp core is-installed --path="$WORDPRESS_DIR"; then
    echo "wordpress already installed"
    return
  fi

  echo "Setting up wordpress..."
  su-exec www-data wp config create --path="$WORDPRESS_DIR" \
      --dbhost="${WORDPRESS_DB_HOST:-mysql}" \
      --dbname="${WORDPRESS_DB_NAME:-wordpress}" \
      --dbuser="${WORDPRESS_DB_USER:-wordpress}" \
      --dbpass="${WORDPRESS_DB_PASSWORD:?}" \
      --force
  su-exec www-data wp core install --path="$WORDPRESS_DIR" \
    --url="${WORDPRESS_URL:?}" \
    --title="${WORDPRESS_TITLE:-"Wordpress"}" \
    --admin_user="${WORDPRESS_ADMIN_USER:-"admin"}" \
    --admin_password="${WORDPRESS_ADMIN_PASSWORD:?}" \
    --admin_email="${WORDPRESS_ADMIN_EMAIL:-"info@example.com"}"
  echo "wordpress setup successfully"
}

main() {
  setup_wordpress

  # Start php-fpm82
  exec php-fpm82 -F
}

main
