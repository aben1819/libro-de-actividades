
```
EN CONSTRUCCIÓN!!!
* Curso 201617: Actividad copiada de Nagios-Debian-Windows
* Curso 201819: Se está intentando adaptadar para Icinga-OpenSUSE-Windows.
```

# 1. Preparativos

## 1.1 Preparar las máquinas

Para esta actividad vamos a necesitar los siguientes MV's:

| ID  | Hostname   | IP | SSOO |
| --- | ---------- | -- | ---- |
| MV1 | monitorXX  | 172.AA.XX.31 |[OpenSUSE](../../global/configuracion/opensuse.md)|
| MV2 | clientXXg1 | 172.AA.XX.32 |[OpenSUSE](../../global/configuracion/opensuse.md)|
| MV3 | clientXXw1 | 172.AA.XX.11 |[Windows7](../../global/configuracion/windows.md)|

* Incluir en el `/etc/hosts` todas las máquinas de la práctica.
* Incluir en el fichero `c:\Windows\System32\drivers\etc\hosts` todas las máquinas de la práctica.

> Veamos una imagen de ejemplo:
>
> ![etc-hosts](./images/nagios3-etc-hosts.png)

## 1.2 Consultar la documentación

* Leer los documentos proporcionados por el profesor.

Enlaces de interés:
* [Getting Started](https://docs.icinga.com/icinga2/latest/doc/module/icinga2/chapter/getting-started)

---

# 2. Instalar el servidor

## 2.1 Instalar el software

Buscar paquetes:
* `zypper search icinga`,

> Repositorio de paquetes openSUSE:
> * zypper ar http://packages.icinga.com/openSUSE/ICINGA-release.repo
> * zypper ref
> * zypper install icinga2

Instalar software:
* `zypper install icinga2 icingacli`
* `zypper install icingaweb2 php-Icinga`
* `zypper install vim-icinga2 nano-icinga2`
Base de datos Mysql:
* `zypper install mysql mysql-client`
* `systemctl enable mysqld`
* `systemctl start mysqld`
* `mysql -u root -p icinga < /usr/share/icinga2-ido-mysql/schema/mysql.sql`
* `zypper install icinga2-ido-mysql`
* `icinga2 feature enable ido-mysql`
Servidor Web Apache:
* `zypper install apache2`
* `systemctl enable apache2`
* `systemctl start apache2`
* `firewall-cmd --add-service=http`
* `firewall-cmd --permanent --add-service=http`
Iniciar y comprobar:
* `systemctl enable icinga2` activar el servicio Icinga2.
* `systemctl start icinga2` iniciar el servicio Icinga2.
* `icinga2`

La instalación predeterminada activará tres características básicas de Icinga:
* `checker` para ejecutar chequeos
* `notification` para enviar notificaciones
* `mainlog` para escribir el fichero `icinga2.log`
Verificar las características habilitadas o deshabilitadas.
* `icinga2 feature list`

> INFO: El directorio de instalación `/etc/icinga2` contiene los ficheros de configuración de Icinga 2.

## 2.2 Configurar Plugins (Servicios externos)

Sin los plugins, Icinga 2 no sabe cómo verificar los servicios externos. Hay una gran cantidad de plugins en `The Monitoring Plugins Project`.

> Es curioso ver como Icinga sigue usando ficheros derivados de Nagios.

Instalar los plugins (servicios externos) para SLES/OpenSUSE:
* `zypper install monitoring-plugins`, instalar los plugins.
* `systemctl reload icinga2` recargar los ficheros de configuración si hubieran cambiado.

Otros comandos de interés:

| Comando                     | Descripción |
| --------------------------- | ------------------------------ |
| `systemctl disable icinga2` | desactivar el servicio Icinga2 |
| `systemctl restart icinga2` | reiniciar el servicio Icinga2 |
| `systemctl stop icinga2`    | parar el servicio Icinga2 |
| `systemctl status icinga2`  | comprobar el servicio Icinga2 |

## 2.3 Comprobar

* `systemctl status icinga2`
* `nmap localhost`
* `lsof -i -n`
* Consultar log `var/log/icinga2.log`.
* Abrimos un navegador y ponemos el URL `http://localhost/???`.

---

# 3. Configurar el servidor

## 3.1 Panel de control

* Abrimos un navegador y ponemos el URL `http://localhost/nagios3`.
* Ponemos usuario/clave (nagiosadmin/clavesecreta), y ya podemos
interactuar con el programa de monitorización.
    * Si vamos a las opciones del menú izquierdo *"Hosts"* y *"Services"*,
    vemos que ya estamos monitorizando nuestro propio equipo *"localhost"*.

**Objetivo**

Nos vamos a plantear como objetivo monitorizar lo siguente:

| Grupo   | Hosts      | IP           | Comprobar |
| ------- | ---------- | ------------ | ----------- |
| routers | benderXX   | 172.AA.0.1   | Host activo |
| routers | caronteXX  | 192.168.1.1  | Host activo |
| servers | leelaXX    | 172.20.1.2   | Servicio HTTP y SSH |
| clients | clientXXg1 | 172.AA.XX.32 | Host activo |
| clients | clientXXw1 | 172.AA.XX.11 | Host activo |

---

## 3.2 Configuración personal

* Sea DIRNAME = `/etc/icinga2/nombre-del-alumno.d`.
* Creamos el directorio DIRNAME, para guardar nuestras configuraciones.
* Editar `/etc/icinga2/icinga2.conf` y poner
`include_recursive "nombre-del-alumo.d"`.

---

## 3.3 Hosts: Routers

* Crear el fichero `DIRNAME/routersXX.cfg` para incluir las definiciones de los hosts de tipo router.
* Los host serán miembros también de los grupos `http-servers`, `ssh-servers` que ya vienen predefinidos por defecto. Veamos un ejemplo (no sirve copiarlo):

```
define host{
  host_name       NOMBRE_DEL_HOST
  alias           NOMBRE_LARGO_DEL_HOST
  address         IP_DEL_HOST
  hostgroups      GRUPO_AL_QUE_PERTENECE, OTRO_GRUPO, OTRO_MAS
  icon_image      cook/NOMBRE_IMAGEN.png
  statusmap_image cook/NOMBRE_IMAGENrouter.png
  #parents

  check_command      check-host-alive
  check_interval     5
  retry_interval     1
  max_check_attempts 1
  check_period       24x7
}
```

object Host "my-server1" {
  address = "10.0.0.1"
  check_command = "hostalive"
}

> Fijarse en todos los parámetros anteriores y preguntar las dudas.
> * [Enlace de interés sobre los parámetros](http://itfreekzone.blogspot.com.es/2013/03/nagios-monitoreo-remoto-de-dispositivos.html)
> * host_name: Nombre del host
> * alias: Nombre largo asociado al host
> * address: Dirección IP
> * hostgroups: Grupos a los que pertenece
> * icon_image: Imagen asociada. Las imágenes PNG están en `/usr/share/nagios/htdocs/images/logos/cook`.
>   Poner a cada host una imagen que lo represente.
> * parents: Nombre del equipo padre o anterior.

* El router `caronteXX` tiene como padre(parent) a `benderXX`.
* Reiniciamos el servicio para que coja los cambios en la configuración.
    * Pista `systemctl restart...`
    * Si hay problemas, consultar log `var/log/.../icinga.log`.
* Consultar la lista de hosts monitorizados en el panel Web.

## 3.4 Hosts: Servidores

* Crear el fichero `DIRBASE/servidoresXX.cfg` para incluir las definiciones de los hosts de tipo servidor.
* Todos los host servidores deben ser miembros de `servidoresXX`, `http-servers`, `ssh-servers`.
* El equipo `leelaXX` tiene como parent a `benderXX`.
* Reiniciamos el servicio
* Consultar la lista de hosts monitorizados en el panel.

## 3.5 Hosts: Clientes

* Crear el fichero `DIRBASE/clientesXX.cfg` para incluir las definiciones de los hosts de tipo cliente. Veamos un ejemplo (no sirve copiar):

```
define host{
  use          generic-host
  host_name    NOMBRE_HOST
  alias        NOMBRE_LARGO_DEL_HOST
  address      IP_DEL_HOST
  hostgroups   GRUPO_AL_QUE_PERTENECE
}
```
> Personalizar: host_name, alias, address y hostgroups.

* Reiniciamos el servicio para que coja los cambios.
* Consultar la lista de hosts monitorizados por el panel.

---

# 4 Ver algunos ejemplos

A continuación vemos una imagen donde se muestran los hosts que estamos monitorizando.
* El verde significa OK.
* El rojo que el equipo presenta algún problema y requiere atención.

![nagios3-hosts](./images/nagios3-hosts.png)

Además podemos tener una visión completa de la red en la opción "map".

![nagios3-map](./images/nagios3-map.png)

* Consulta la lista de hosts, el mapa de Nagios.

---

# 5. Agente: Servicios Internos en el cliente GNU/Linux

## 5.1 Documentación

Por ahora el monitor, sólo puede obtener la información que los
equipos dejan ver desde el exterior. Cuando queremos obtener más información del interior los hosts, tenemos que instalar una utilidad llamada "Agente" en cada uno.

El agente es una especie de "chivato" que nos puede dar datos de:
Consumo CPU, consumo de memoria, consumo de disco, etc.

Aquí vemos un ejemplo del estado de los "servicios internos" monitorizados,
en el host "localhost". Con la instalación de los "agentes",
podremos tener esta información desde los clientes remotos.

![nagios3-details](./images/nagios3-details.png)

> Enlaces de interés:
> * [install-nagios-nrpe-client-and-plugins-in-ubuntudebian](https://viewsby.wordpress.com/2013/02/14/install-nagios-nrpe-client-and-plugins-in-ubuntudebian/)
> * [instalacion-de-nagios-como-cliente-en-windows-y-linux](http://www.nettix.com.pe/documentacion/administracion/114-instalacion-de-nagios-como-cliente-en-windows-y-linux)
> * [monitoring-linux](http://nagios.sourceforge.net/docs/3_0/monitoring-linux.html)

## 5.2 Instalar y configurar el cliente1

En el cliente:
* Debemos instalar el agente en la máquina cliente (paquete NRPE server y los plugin básicos)
* Editar el fichero `/etc/.../nrpe_local.cfg` del cliente y modificar lo siguiente:

```
 # define en qué puerto (TCP) escuchará el agente.
 # Por defecto es el 5666.
server_port=5666

 # indica en qué dirección IP escuchará el agente,                              
 # en caso que la MV posea más de una IP.
server_address=IP_DEL_CLIENTE

 # define qué IPs tienen permitido conectarse al agente en busca de datos.
 # Es un parámetro de seguridad para limitar desde qué máquinas se conectan al agente.
allowed_hosts=127.0.0.1,IP_DEL_SERVIDOR

 # Esta variable indica que NO se permite que el agente
 # reciba comandos con parámetros poe seguridad.
dont_blame_nrpe=0

 # alias check_user para obtener la cantidad de usuarios logueados
 # y alertar si hay más de 5 logueados al mismo tiempo.
command[check_users]=/usr/lib/nagios/plugins/check_users -w 5 -c 10

 # alias check_load para obtener la carga de CPU
command[check_load]=/usr/lib/nagios/plugins/check_load -w 15,10,5 -c 30,25,20

 #alias check_disk para obtener el espacio disponible en el disco /dev/sda
 # y alertar si queda menos de 20% de espacio en alguna partición.
command[check_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -x sda


command[check_procs]=...
```

* Reiniciar el servicio en el cliente (`systemctl restart nagios-nrpe-server ...`)

## 5.3 Configurar en el servidor

* Ir al servidor.
* `/usr/lib/nagios/plugins/check_nrpe -H ip-del-cliente`, comprobar desde el servidor la conexión NRPE al cliente de la siguiente forma.
* Crear el fichero `DIRBASE/servicios-gnulinuxXX.cfg`, para definir nuevos servicios a monitorizar.
* Añadir las siguientes líneas:

```
define service{
  use                  generic-service
  host_name            NOMBRE_DEL_HOST
  service_description  Espacio en disco
  check_command        check_nrpe_1arg!check_disk
}

define service{
  use                 generic-service
  host_name           NOMBRE_DEL_HOST
  service_description Usuarios actuales
  check_command       check_nrpe_1arg!check_users
}

define service{
  use                 generic-service
  host_name           NOMBRE_DEL_HOST
  service_description Procesos totales
  check_command       check_nrpe_1arg!check_procs
}

define service{
  use                 generic-service
  host_name           NOMBRE_DEL_HOST
  service_description Carga actual
  check_command       check_nrpe_1arg!check_load
}
```

* Consultar el estado de los servicios monitorizados en el panel.

---

# 6. Agente: Servicios Internos en el Cliente Windows

## 6.1 Instalar en el cliente2

* Descargar el programa Agente Windows (NSCLient++)
    * Recomendado [http://nsclient.org/nscp/downloads](http://nsclient.org/nscp/downloads).
    * [http://www.nagios.org/download/addons](http://www.nagios.org/download/addons).
* Instalar el programa nsclient.
    * Activar las opciones `common check plugins`, `nsclient server` y `NRPE server`

> * En este caso hemos elegido NRPE como protocolo de comunicación entre el agente
Windows y el servidor Nagios.
> * Si tuviéramos un fichero de instalación MSI, al ejecutarlo nos hará la
instalación del programa con las opciones por defecto sin preguntarnos.

* Servicio `Agente` en el cliente
    * Por entorno gráfico:
        * Ir a `Equipo -> Administrar -> Servicios -> Nagios -> Reiniciar`.
    * Por comandos:
        * `net start nsclient` para iniciar el servicio del agente.
        * `net stop nsclient` para parar el servicio del agente.

## 6.2 Configurar el cliente2

Toda la configuración se guarda en el archivo `C:\Program Files\NSClient++\nsclient.ini`
 (o `C:\Archivos de Programas\NSClient++\nsclient.ini`).

NSClient no utiliza el mismo formato de configuración que el visto en el host Linux.
Para empezar, la configuración se divide en secciones.
Por otra parte, los plugins se deben habilitar antes de ser utilizados.
Además los plugins se llaman con nombres de ejecutables diferentes
(CheckCpu. CheckDriveSize, etc), y los alias se definen de otra manera.

> Para estandarizar, en la configuración utilizaremos los mismos alias que en el host Linux
> Así es posible realizar grupos de hosts que incluyan tanto servidores
GNU/Linux como Windows, y ejecutar los mismos comandos en ambos.

* Enlaces de interés:
    * [Instalación y configuración del servidor Nagios, y de los agentes para Linux y Windows](http://itfreekzone.blogspot.com.es/2013/03/nagios-monitoreo-remoto-de-dispositivos.html)
* La configuración que utilizaremos será la siguiente:

```
[/settings/default]
;Desactivar el password
;password=

; permitimos el acceso al servidor Nagios para las consultas.
allowed hosts=IP_DEL_SERVIDOR

[/settings/NRPE/server]
ssl options = no-sslv2, no-sslv3
verify mode = none
insecure = true

[/modules]
; habilitamos el uso de NRPE
NRPEServer=1

; habilitamos plugins a utilizar
CheckSystem=1
CheckDisk=1
CheckExternalScripts=1

[/settings/external scripts/alias]

; alias para chequear la carga de CPU. Si sobrepasa el 80% en un intervalo de 5 minutos, nos alertará.
check_load=CheckCpu MaxWarn=80 time=5m

; alias para chequear el espacio en todos los discos del servidor
check_disk=CheckDriveSize ShowAll MinWarnFree=10% MinCritFree=5%

; alias para chequear el servicio del firewall de Windows (llamado MpsSvc).
check_firewall_service=CheckServiceState MpsSvc

```

## 6.3 Configurar en el Servidor

En el servidor Nagios:
* `/usr/lib/nagios/plugins/check_nrpe -H IP_DEL_CLIENTE2`, comprobar desde el servidor la conexión NRPE al cliente.

> [Consultar documentación](http://nagios.sourceforge.net/docs/3_0/monitoring-windows.html) sobre cómo configurar los servicios del host Windows en Nagios Master

* Crear el fichero `DIRBASE/servicios-windowsXX.cfg`, para definir servicios a monitorizar en Windows.
* Veamos un ejemplo.

```
define service {
  use                  generic-service
  host_name            NOMBRE_DEL_HOST
  service_description  Carga media
  check_command        check_nrpe_1arg!check_load
}

define service{
  use                  generic-service
  host_name            NOMBRE_DEL_HOST
  service_description  Espacio en disco
  check_command        check_nrpe_1arg!check_disk
}

define service{
  use                  generic-service
  host_name            NOMBRE_DEL_HOST
  service_description  Firewall
  check_command        check_nrpe_1arg!check_firewall_service
}

```

* Reiniciar el servicio.
* Consultar los servicios monitorizados por el panel.
