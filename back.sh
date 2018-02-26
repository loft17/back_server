#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: backupserver
# version: 3.1.7
# autor: joseRomera <web@joseromera.net>
# web: http://www.joseromera.net
# Copyright (C) 2016-2018
#----------------------------------------------------------------------------------------------------------------
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#----------------------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Variables
#----------------------------------------------------------------------------------------------------------------

# Variables fecha
DATE=$(date +"%Y%m%d")

# Variables otros
PASS7ZP="7ZIP_PASSWORD"

# Variables DDBB
SQLHOST=localhost
SQLUSER=SQL_USER
SQLPASS="SQL_PASSWORD"
SQLDDBB=BASE_DATOS

# Variables rutas
PATHTMP=/tmp/bcktmp
PATHNGX=/etc/nginx
PATHWWW=CARPETA_WEB
PATHBCK=CARPETA_BACKUP_DIARIA
PATHGLC=CARPETA_BACKUP_SEMANAL


#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Funciones
#----------------------------------------------------------------------------------------------------------------

# Creamos la carpeta temporal
mkdir $PATHTMP/server_$DATE -p

# Paramos servicios
/etc/init.d/nginx stop && /etc/init.d/php7.0-fpm stop 

# Limpiamos caches y temporales
rm $PATHWWW/cache/* -R && rm /etc/nginx/cache/* -R

# copia carpeta nginx // # copia carpeta www
cp -R $PATHNGX $PATHTMP/server_$DATE && cp -R $PATHWWW $PATHTMP/server_$DATE

# copia de la bbdd
mysqldump --user=$SQLUSER --password=$SQLPASS $SQLDDBB --host=$SQLHOST > $PATHTMP/server_$DATE/$SQLDDBB_$DATE.sql

# Iniciamos los servicios
/etc/init.d/php7.0-fpm start && /etc/init.d/nginx start

# Comprimimos y encriptamos los ficheros
7z a -p$PASS7ZP -mx=9 -mhe -t7z $PATHBCK/server_$DATE.7z $PATHTMP/*

# Si es sabado, copiamos el backup en GLACE
if [ $(date +%A) = "lunes" ]
then
	# Copiamos el backup en GLACE
	cp $PATHBCK/server_$DATE.7z $PATHGLC
else
	# Eliminamos de GLACE las copias con mas de 360 días
	find $PATHGLC/server_* -mtime +360 -exec rm {} \;
fi

# Eliminamos copias con mas de 30 días
find $PATHBCK/server_* -mtime +30 -exec rm {} \;

# Eliminamos temporales
rm -R $PATHTMP && cd /


#----------------------------------------------------------------------------------------------------------------
#                                                                                                             FIN
#----------------------------------------------------------------------------------------------------------------
