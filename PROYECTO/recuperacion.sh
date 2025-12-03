#!/bin/bash
#####################################
#        Nicolás García Edo y       #
#       Alberto del Olmo Barrés     #
#  Script creado para la asignatura #
#      de Seguridad Informática     #
#               de la UJI           #
#####################################
home=$HOME
ruta_a_dejar_copia=$(head -n 2 $home/.backup_config.txt | tail -n 1)
num_lineas=""
contrasena_encriptacion=$(head -n 4 $home/.backup_config.txt | tail -n 1)
mail=$(head -n 5 $home/.backup_config.txt | tail -n 1)
# Sacar un listado enumerado de todo menos los snar
echo ""
echo "Listado de archivos de copia de seguridad:"
ls -1 $ruta_a_dejar_copia | find "$ruta_a_dejar_copia" -type f ! -name "*.snar" -exec basename {} \; | cat -n 
echo""
# Guardarme el numero de lineas que saca el comando anterior
num_lineas=$(ls -1 $ruta_a_dejar_copia | find "$ruta_a_dejar_copia" -type f ! -name "*.snar" -exec basename {} \; | cat -n | wc -l)

# Pedir al usuario que me introduzca el numero de archivo que quiere que le descomprima dentro del rango num_lineas
echo "Introduzca el numero de archivo que quiere que le descomprima"
read num_archivo
# Comprobar que el numero introducido es un numero y que esta dentro del rango
if [ $num_archivo -gt 0 ] && [ $num_archivo -le $num_lineas ]; then
# Guardar el nombre del archivo que corresponde con el numero introducido
archivo_incremental=$(ls -1 $ruta_a_dejar_copia | find "$ruta_a_dejar_copia" -type f ! -name "*.snar" -exec basename {} \; | cat -n | grep -E "^ *$num_archivo" | awk '{print $2}')
else
exit 1
fi
# Si el nombre de archivo sigue el patron "weekly_* o monthly_* descomprimir el archivo completo en el home del usuario
if [ $(echo $archivo_incremental | grep -E "weekly_.*|monthly_.*" | wc -l) -eq 1 ]; then
# Descifrar y descomprimir el archivo completo en home de usuario
echo "Descomprimiendo el archivo completo en $home/recuperacion"
mkdir $home/recuperacion
openssl enc -aes-256-cbc -d -pass pass:$contrasena_encriptacion -pbkdf2 -in "$ruta_a_dejar_copia/$archivo_incremental" | tar -xzf - -C $HOME/recuperacion
else
# Busco el snar correspondiente de su semana
semana=$(echo "$archivo_incremental" | cut -d '_' -f 3 | awk -F '.' '{print $1}')
# Encontrar semana del año de la semana anterior
semana_anterior=$((semana - 1))
ano_anterior=$(date +%Y)
if [ $semana -eq 1 ]; then
semana_anterior=52
ano_anterior=$((ano_anterior - 1))
fi
# Busco el archivo correspondiente a la semana anterior
archivo_completo=$(find "$ruta_a_dejar_copia" -name "*$ano_anterior_$semana_anterior.tar.gz")
# Recupero la copia incremental
echo "Descomprimiendo el archivo en $home/recuperacion"
mkdir $HOME/recuperacion
# Descomprimir el archivo completo en directorio de recuperacion
openssl enc -aes-256-cbc -d -pass pass:$contrasena_encriptacion -pbkdf2 -in "$archivo_completo" | tar --listed-incremental=/dev/null -xzf - -C $HOME/recuperacion
# Descomprimir archivo_incremental en directorio de recuperacion
openssl enc -aes-256-cbc -d -pass pass:$contrasena_encriptacion -pbkdf2 -in "$ruta_a_dejar_copia/$archivo_incremental" | tar --listed-incremental=/dev/null  -xzf - -C $HOME/recuperacion
fi





