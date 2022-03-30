# INSTALACION DE DRUPAL EN UBUNTU
## Daniel Radomirov Yordanov

> ARCHIVOS

Para empezar con la instalación hace falta descargar Drupal 9, para ello vamos a ejecutar por Terminal: 

    ~$ wget --content-disposition https://www.drupal.org/download-latest/tar.gz

A continuación extraemos el paquete descargado directamente en la ruta que nos interesa, en este caso *"/var/www"*:

    ~$ sudo tar xf drupal-9.X.X.tar.gz -C /var/www/

Como el nombre del nuevo subdirectorio creado contiene el número de versión en su nombre, puede ser buena idea crear un enlace simbólico sin números:

    ~$ sudo ln -s /var/www/drupal-9.X.X /var/www/drupal

Como Drupal 9 necesita escribir en su propio directorio de instalación, cambiaremos la propiedad del mismo y de su contenido al usuario con el que corre el servicio web en Ubuntu: 

    ~$ sudo chown -R www-data: /var/www/drupal/

> SERVICIO WEB

Debemos activar los modulos de Apache: 

    ~$ sudo a2enmod expires headers rewrite

El uso de estos módulos se realiza a través de archivos .htaccess, que no son interpretados por defecto, ajuste que añadiremos al archivo de configuración que crearemos para hacer la aplicación navegable a través de un alias:

    ~$ sudo nano /etc/apache2/sites-available/drupal.conf

Agregamos al archivo: 

    <VirtualHost *:80>

    Alias /drupal /var/www/drupal
    ServerAdmin webmaster@miservidor.com
    ServerName drupal.miservidor.com
    DocumentRoot /var/www/drupal


    <Directory /var/www/drupal>
            AllowOverride all
    </Directory>
    </VirtualHost>

Guardamos la configuración y activamos la configuración: 

    ~$ sudo a2ensite drupal.conf

A continuación, reiniciamos el servicio web para aplicar los ajustes: 

    ~$ sudo systemctl restart apache2

> CONFIGURACIÓN BASE DE DATOS

Conectamos a __mysql__ como administrador: 

    ~$ mysql -u root -p

Creamos la base de datos de drupal: 

    > create database drupal9 charset utf8mb4 collate utf8mb4_unicode_ci;

Creamos el usuario, en mi caso identificado by 'daniel': 

    > create user drupal9@localhost identified with mysql_native_password by 'XXXXXXXX';

Concedemos los privilegios al usuario sobre la base de datos: 

    > grant all privileges on drupal9.* to drupal9@localhost;

Cerramos la conexión: 

    > exit; 

> EXTENSIONES

Para empezar deberemos instalar extensiones necesarias para el correcto funcionamiento: 

    ~$ sudo apt install -y php-apcu php-gd php-mbstring php-uploadprogress php-xml

    ~$ sudo apt install -y php-mysql

Una vez instaladas, recargamos el servicio APACHE2: 

    ~$ sudo systemctl reload apache2


> HOSTS

En mi caso, para poder acceder por navegador web tendré que modificar el archivo hosts, agregamos: 

    127.0.0.1 drupal.miservidor.com

> INSTALADOR WEB

A través de un navegador abrimos el siguiente enlace --> drupal.miservidor.com

Y a continuación, configuramos el sitio siguiendo en orden las imágenes: 

    1. InstalandoDrupal.png
    2. PerfilInstalacion.png
    3. ConfigurarSitio.png
    4. Bienvenido.png

