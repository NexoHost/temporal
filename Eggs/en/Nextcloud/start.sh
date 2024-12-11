#!/bin/ash
rm -rf /home/container/tmp/*
echo "⚙️ Script Version: 1.9"
echo "🛠 Starting PHP-FPM..."
/usr/sbin/php-fpm --fpm-config /home/container/php-fpm/php-fpm.conf --daemonize

echo "🛠 Starting Nginx..."
echo "✅ Successful startup of the EGG by NexoHost.cloud"

# Arte ASCII para mostrar al final del inicio exitoso

echo " _   _                _   _           _         _                 _ "
echo "| \ | |              | | | |         | |       | |               | |"
echo "|  \| | _____  _____ | |_| | ___  ___| |_   ___| | ___  _   _  __| |"
echo "| . ` |/ _ \ \/ / _ \|  _  |/ _ \/ __| __| / __| |/ _ \| | | |/ _` |"
echo "| |\  |  __/>  < (_) | | | | (_) \__ \ |_ | (__| | (_) | |_| | (_| |"
echo "\_| \_/\___/_/\_\___/\_| |_/\___/|___/\__(_)___|_|\___/ \__,_|\__,_|"