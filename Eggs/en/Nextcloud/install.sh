#!/bin/ash

# Validar que los directorios necesarios existen y que no están en solo lectura
if [ ! -w "/mnt/server" ]; then
    echo "Error: /mnt/server está montado como solo lectura o no tiene permisos de escritura."
    exit 1
fi

# Crear directorios necesarios si no existen
mkdir -p /mnt/server/logs /mnt/server/php-fpm/conf.d /mnt/server/tmp

if [ -f "./logs/installed" ]; then
    if [ "${OCC}" = "1" ]; then 
        php ./nextcloud/occ "${COMMANDO_OCC}"
        exit
    else
        echo "✓ Updating install.sh script"
        curl -sSL https://raw.githubusercontent.com/NexoHost/yolks-software/main/Eggs/en/Nextcloud/install.sh -o install.sh
        chmod a+x ./install.sh
        echo "✓ Updating start.sh script"
        curl -sSL https://raw.githubusercontent.com/NexoHost/yolks-software/main/Eggs/en/Nextcloud/start.sh -o start.sh
        chmod a+x ./start.sh
        ./start.sh
    fi
else
    cd /mnt/server/ || exit
    echo "**** Downloading Nextcloud ****"
    rm -rf nextcloud/
    if [ "${NEXTCLOUD_RELEASE}" = "latest" ]; then
        DOWNLOAD_LINK="latest.zip"
    else
        DOWNLOAD_LINK="nextcloud-${NEXTCLOUD_RELEASE}.zip"
    fi
fi

echo "✓ Updating install.sh script"
curl -sSL https://raw.githubusercontent.com/NexoHost/yolks-software/main/Eggs/en/Nextcloud/install.sh -o install.sh

# Clonar repositorio de nginx y copiar configuraciones
git clone https://github.com/finnie2006/ptero-nginx ./temp
cp -r ./temp/nginx /mnt/server/
cp -r ./temp/php-fpm /mnt/server/
rm -rf ./temp
rm -rf /mnt/server/webroot/*

# Crear el directorio de logs si no existe
mkdir -p /mnt/server/logs

# Descargar archivo de configuración para nginx
rm -f /mnt/server/nginx/conf.d/default.conf
curl -sSL https://raw.githubusercontent.com/NexoHost/yolks-software/main/Eggs/en/Nextcloud/default.sh -o /mnt/server/nginx/conf.d/default.sh

cd /mnt/server || exit
cat <<EOF >./logs/install_log.txt
Version: $NEXTCLOUD_RELEASE
Link: https://download.nextcloud.com/server/releases/${DOWNLOAD_LINK}
File: ${DOWNLOAD_LINK}
EOF

# Descargar y extraer Nextcloud
wget -q https://download.nextcloud.com/server/releases/${DOWNLOAD_LINK} -O ${DOWNLOAD_LINK}
if [ $? -ne 0 ]; then
    echo "Error: No se pudo descargar ${DOWNLOAD_LINK}."
    exit 1
fi

unzip -q ${DOWNLOAD_LINK}
rm -f ${DOWNLOAD_LINK}

# Cambiar permisos de los archivos descargados
if id "nginx" &>/dev/null; then
    chown -R nginx:nginx nextcloud
else
    echo "Advertencia: Usuario 'nginx' no existe, se omite cambio de propietario."
fi
chmod -R 755 nextcloud

echo "**** Cleaning up ****"
touch ./logs/installed
rm -rf /tmp/*

# Configurar PHP y Nginx para Nextcloud
echo "**** Configuring PHP and Nginx for Nextcloud ****"
echo "extension=smbclient.so" > /mnt/server/php-fpm/conf.d/00_smbclient.ini
echo 'apc.enable_cli=1' >> /mnt/server/php-fpm/conf.d/apcu.ini

sed -i \
-e 's/;opcache.enable.*=.*/opcache.enable=1/g' \
-e 's/;opcache.interned_strings_buffer.*=.*/opcache.interned_strings_buffer=16/g' \
-e 's/;opcache.max_accelerated_files.*=.*/opcache.max_accelerated_files=10000/g' \
-e 's/;opcache.memory_consumption.*=.*/opcache.memory_consumption=128/g' \
-e 's/;opcache.save_comments.*=.*/opcache.save_comments=1/g' \
-e 's/;opcache.revalidate_freq.*=.*/opcache.revalidate_freq=1/g' \
-e 's/;always_populate_raw_post_data.*=.*/always_populate_raw_post_data=-1/g' \
-e 's/memory_limit.*=.*128M/memory_limit=512M/g' \
-e 's/max_execution_time.*=.*30/max_execution_time=120/g' \
-e 's/upload_max_filesize.*=.*2M/upload_max_filesize=1024M/g' \
-e 's/post_max_size.*=.*8M/post_max_size=1024M/g' \
-e 's/output_buffering.*=.*/output_buffering=0/g' \
/mnt/server/php-fpm/php.ini

sed -i '/opcache.enable=1/a opcache.enable_cli=1' /mnt/server/php-fpm/php.ini

echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /mnt/server/php-fpm/php-fpm.conf

mkdir -p /mnt/server/tmp
