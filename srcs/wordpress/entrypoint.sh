#!/bin/sh
set -ex

setup_wordpress() {
  if su-exec www-data wp core is-installed --path="$WP_DIR"; then
    echo "wordpress already installed"
    return
  fi

  echo "Setting up wordpress..."
  su-exec www-data wp config create --path="$WP_DIR" \
      --dbhost="${WP_DB_HOST:-mysql}" \
      --dbname="${WP_DB_NAME:-wordpress}" \
      --dbuser="${WP_DB_USER:-wordpress}" \
      --dbpass="${WP_DB_PASSWORD:?}" \
      --force
  su-exec www-data wp core install --path="$WP_DIR" \
    --url="${WP_URL:?}" \
    --title="${WP_TITLE:-"Wordpress"}" \
    --admin_user="${WP_ADMIN_USER:-"admin"}" \
    --admin_password="${WP_ADMIN_PASSWORD:?}" \
    --admin_email="${WP_ADMIN_EMAIL:-"info@example.com"}"
  echo "wordpress setup successfully"
}

main() {
  setup_wordpress

  # Start php-fpm82
  exec php-fpm82 -F
}

main
