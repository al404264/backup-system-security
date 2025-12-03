#!/bin/bash
#####################################
#        Nicolás García Edo y       #
#       Alberto del Olmo Barrés     #
#  Script creado para la asignatura #
#      de Seguridad Informática     #
#               de la UJI           #
#####################################
# Pedir al usuario los parametros y guaradarlos en un archivo oculto en el dir /home al que solo tiene acceso el usuario que invoca el script
home=$HOME
ruta_dir_a_copiar=""
ruta_a_dejar_copia=""
num=""
contrasena_encriptacion=""
mail=""
echo "Has invocado al script de copias de seguridad"
echo "Por favor, introduce los parametros que te pediremos a continuacion"
# Bucle para pedir la ruta hasta que exista
while [ ! -e "$ruta_dir_a_copiar" ]; do
    # Pedir la ruta al usuario
    read -p "Introduce la ruta del directorio a copiar: " ruta_dir_a_copiar
    # Comprobar si la ruta existe
    if [ ! -e "$ruta_dir_a_copiar" ]; then
        echo "La ruta $ruta_dir_a_copiar no existe. Introduce una ruta válida."
    fi
done
# Bucle para pedir la ruta hasta que exista y sea distinta a la anterior y esté vacío
# Comprobar si el directorio está vacío
echo ""
while  [ ! -e "$ruta_a_dejar_copia" ] || [ "$ruta_dir_a_copiar" == "$ruta_a_dejar_copia" ] || [ -n "$(ls -A "$ruta_a_dejar_copia")" ]; do
    # Pedir la ruta al usuario
    read -p "Introduce la ruta donde quieras guardar la copia de seguridad, tiene que ser directorio vacío, y distinto al anterior: " ruta_a_dejar_copia
    # Comprobar si la ruta existe
    if [ ! -e "$ruta_a_dejar_copia" ]; then
        echo "La ruta $ruta_a_dejar_copia no existe. Introduce una ruta válida."
    fi
    # Comprobar si la ruta es distinta a la anterior
    if [ "$ruta_dir_a_copiar" == "$ruta_a_dejar_copia" ]; then
        echo "La ruta $ruta_a_dejar_copia es la misma que la ruta del directorio a copiar. Introduce una ruta válida."
    fi
    # Comprobar si el directorio no está vacío
    if [ -n "$(ls -A "$ruta_a_dejar_copia")" ]; then
        echo "El directorio $ruta_a_dejar_copia no está vacío. Introduce una ruta válida."
    fi
done
echo ""
# Comprobar si el espacio es un numero
while ! [[ $num =~ ^-?[0-9]+$ ]]; do
  read -p "Introduce el espacio maximo disponible en el directorio (en KB) donde guardaremos las copias de seguridad: " num
  if ! [[ $num =~ ^-?[0-9]+$ ]]; then
    echo "$num no es un entero válido"
  fi
done
echo ""
# Pedir la contraseña de encriptación
read -s -p "Indique la contraseña de cifrado que desea utilizar para las copias: " contrasena_encriptacion
# Pedir el mail
echo ""
echo ""
read -p "Indique el mail donde desea recibir los avisos de espacio de almacenamiento: " mail
touch $home/.backup_config.txt
chmod 600 $home/.backup_config.txt
chmod +x $home/backup.sh

# Guardar todo dentro de un fichero oculto en el home del usuario
echo $ruta_dir_a_copiar > $home/.backup_config.txt
echo $ruta_a_dejar_copia >> $home/.backup_config.txt
echo $num >> $home/.backup_config.txt
echo $contrasena_encriptacion >> $home/.backup_config.txt
echo $mail >> $home/.backup_config.txt

# Configurar el crontab automáticamente para que se active a las 2 de la mañana
(crontab -l ; echo "0 2 * * * bash $home/backup.sh") | crontab -

# Copia de seguridad del primer dia completa (problema del primer día)
# Si es domingo
# Hago el snar de la semana actual
if [ "$(date +%u)" -eq 7 ]; then
    tar --listed-incremental="$ruta_a_dejar_copia/weekly_$(date +%V).snar" -czf - "$ruta_dir_a_copiar" 2> /dev/null | openssl enc -aes-256-cbc -e -pass pass:$contrasena_encriptacion -pbkdf2 -out "$ruta_a_dejar_copia/monthly_$(date +%Y)_$(date +%V).tar.gz" 
    # Copia unicamente de un directorio

else
# Hago el snar con nombre de la semana pasada 
    tar --listed-incremental="$ruta_a_dejar_copia/weekly_$(date -d 'last sunday' +%V).snar" -czf - "$ruta_dir_a_copiar" 2> /dev/null | openssl enc -aes-256-cbc -e -pass pass:$contrasena_encriptacion -pbkdf2 -out "$ruta_a_dejar_copia/monthly_$(date -d 'last sunday' +%Y)_$(date -d 'last sunday' +%V).tar.gz" 
fi





