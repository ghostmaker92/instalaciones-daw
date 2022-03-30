# INSTALACION DE DRUPAL EN UBUNTU
## Daniel Radomirov Yordanov

Para empezar con la instalación hace falta descargar Drupal 9, para ello vamos a ejecutar por Terminal: 

    ~$ wget --content-disposition https://www.drupal.org/download-latest/tar.gz

A continuación extraemos el paquete descargado directamente en la ruta que nos interesa, en este caso *"/var/www"*:

    ~$ sudo tar xf drupal-9.X.X.tar.gz -C /var/www/

Como el nombre del nuevo subdirectorio creado contiene el número de versión en su nombre, puede ser buena idea crear un enlace simbólico sin números:

    ~$ sudo ln -s /var/www/drupal-9.X.X /var/www/drupal

