# DESPLIEGUE CON GUNICORN

Gunicorn es un servidor web que permite ejecutar una aplicación en un proceso independiente. Usamos los servidores web como proxies inversos que envían la petición python al servidor WSGI que estemos utilizando

## CONFIGURACIÓN DE VAGRANT

```vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"

  config.vm.network "forwarded_port", guest: 80, host: 8000, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"
end
```

## INSTALAR NECESARIAS

```bash
apt install -y apache2 
apt install -y python3
apt install -y python3.8-venv
```

## CREAMOS EL ENTORNO ENV DE PYTHON  DESDE TERMINAL

Dentro del home del usuario vagrant

```bash
python3 -m venv env
```

Se activa la carpeta `env` :

```bash
source /env/bin/activate
```

Descargamos el proyecto en `/home/vagrant/vagrant`

```bash
git clone `{enlace}`
```

A continuación se revisan los requisitos de la aplicación indicados en `requirements.txt`

```bash
cat requirements.txt
```

Se instala lo necesario `flask` `lxml`

```bash
pip install flask lxml
```

Se instala también `gunicorn`

```bash
pip install gunicorn
```

*OPCIONAL*
---

---
Se puede poner en marcha la aplicación para comprobar que funciona correctamente, OJO SIN APACHE!

```bash
gunicorn app:app -b :8080
```

Explicación del comando:

* `-b`: Indica que se modifica el puerto por el que servirá
* `:8080`: Indica la IP y el puerto

---

### DESPLIEGUE DE UNA APLICACIÓN FLASK CON GUNICORN

Empezamos habilitando los módulos de Apache2 `proxy` y `proxy_http`

```bash
sudo a2enmod proxy proxy_http
```

Se crea un nuevo site-available para la aplicaicón, dentro de `/etc/apache2/sites-available`

```bash
nano temperaturas.conf
```

```temperaturas.conf
<VirtualHost *:80>
        ServerName www.temperaturas.com
        ServerAdmin webmaster@localhost
        DocumentRoot /vagrant/flask_temperaturas/

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        ProxyPass / http://localhost:8080/
</VirtualHost>
```

**IMPORTANTE:** `ProxyPass` se encarga de hacer del proxy 

---

Habilitamos `temperaturas.conf`

```bash
sudo a2ensite temperaturas.conf
```

```bash
sudo systemctl reload apache2
```

A continuación, dentro de la carpeta raíz de la aplicación crearemos `run.sh`

```bash
nano run.sh
```

Dentro se deberemos poner el comando de `gunicorn` para lanzar la aplicación

```run.sh
gunicorn app:app -b :8080
```

Apagamos la máquina virutal y quitamos el puerto `8080` de `VAGRANTFILE` para que el usuario no pueda acceder directamente a *gunicorn*

```vagrantfile
#config.vm.network :forwarded_port, guest: 8080, host: 8080, host_ip: "127.0.0.1"
```

Levantamos de nuevo la máquina virtual, y todas las conexiones irán por *apache*

Se vuelve a activarel entorno `env`

```bash
source env/bin/activate
```
Ponemos en marcha `run.sh`

```bash
sh run.sh
```

### CAMBIAR SERVIDOR DE ESTATICOS

**GUNICORN** no es un servidor especializado en estáticos, por lo que es interesante que los estáticos los cargue **APACHE2**

Accedemos al archivo de configuración del sitio `etc/apache2/sites-available/temperaturas.conf`

```bash
sudo nano temperaturas.conf
```

* Añadimos la línea `ProxyPass /static/ !` para indicar que los estáticos no los cargue el proxy(gunicorn en este caso).
* Agregamos también `Alias /static/ {ruta de los datos estáticos}`.
* Agregamos permisos al directorio estático

```temperaturas.conf
<VirtualHost *:80>
        ServerName www.temperaturas.com
        ServerAdmin webmaster@localhost
        DocumentRoot /vagrant/flask_temperaturas/

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        ProxyPass /static/ !
        ProxyPass / http://localhost:8080/
        Alias /static/ /vagrant/flask_temperaturas/static/

        <Directory /vagrant/flask_temperaturas/static>
            Require all granted
        </Directory>
```

* Reiniciamos apache2

```bash
sudo systemctl restart apache2
```

Con las opciones de desarrollador del navegador, en el apartado de `network` podemos obtener información de que servicio está cargando los estáticos

### GENERAR SERVICIO DE GUNICORN

Comprobamos el estado de la navegación de `www.temperaturas.com` desde el cliente

```cmd
curl -I www.temperaturas.com:8000
```

Copiamos la carpeta del proyecto en `/home/vagrant`

```bash
cp ./flask_temperaturas . 
```

A continuación, creamos el archivo del servicio para el proyecto "flask_temperaturas"

```bash
sudo nano /etc/systemd/system/temperaturas.service
```

```temperaturas.service
Description=gunicorn daemon

[Service]
User=vagrant
Group=vagrant
WorkingDirectory=/home/vagrant/flask_temperaturas/

ExecStart=/home/vagrant/env/bin/gunicorn \
    --workers=4 \
    --bind=127.0.0.1:8000 \
    --log-file=/home/vagrant/flask_temperaturas/gunicorn.log \
    app:app

[Install]
WantedBy=multi-user.target
```

Una vez preparado el servicio, tenemos que habilitarlo

```bash
sudo systemctl enable temperaturas
```

Comprobamos que funcione, lanzandolo

```bash
sudo systemctl start temperaturas
```

Finalmente comprobamos desde el navegador del cliente.
