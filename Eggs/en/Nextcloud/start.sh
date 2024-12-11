#!/bin/ash
rm -rf /home/container/tmp/*
echo "⚙️ Script Version: 1.9"
echo "🛠 Starting PHP-FPM..."
/usr/sbin/php-fpm --fpm-config /home/container/php-fpm/php-fpm.conf --daemonize

echo "🛠 Starting Nginx..."
echo "✅ Successful startup of the EGG by NexoHost.cloud"

# Arte ASCII para mostrar al final del inicio exitoso
