#!/bin/bash
#####################################
#        Nicolás García Edo y       #
#       Alberto del Olmo Barrés     #
#  Script creado para la asignatura #
#      de Seguridad Informática     #
#               de la UJI           #
#####################################
# Vamos a leer el archivo de configuración 
home=$HOME
ruta_dir_a_copiar=$(head -n 1 $home/.backup_config.txt)
ruta_a_dejar_copia=$(head -n 2 $home/.backup_config.txt | tail -n 1)
num=$(head -n 3 $home/.backup_config.txt | tail -n 1)
contrasena_encriptacion=$(head -n 4 $home/.backup_config.txt | tail -n 1)


# Si no es domingo hacemos una copia diferencial
if [ $(date +%u) -ne 7 ]; then
# Busco el fichero snar mas reciente
snar_copia_incremental=$(find "$ruta_a_dejar_copia" -name "weekly_*.snar" -printf '%T+ %p\n' | sort | tail -n 1 | cut -d ' ' -f 2-)
# Hacer una copia del archivo de snar
cp "$snar_copia_incremental" "$ruta_a_dejar_copia/weekly_snar_copia.snar"
# Hago copia incremental con el snar mas reciente
tar --listed-incremental="$ruta_a_dejar_copia/weekly_snar_copia.snar" -czf - "$ruta_dir_a_copiar" 2> /dev/null | openssl enc -aes-256-cbc -e -pass pass:$contrasena_encriptacion -pbkdf2 -out "$ruta_a_dejar_copia/daily_$(date +%Y)_$(date +%V)_$(date +%u).tar.gz" 
# Borro el snar copiado
rm "$ruta_a_dejar_copia/weekly_snar_copia.snar"
# Hago borrado de las diarias
# Si tengo mas de 6 diarias borro la mas vieja
if [ $(find "$ruta_a_dejar_copia" -name "daily_*.tar.gz" | wc -l) -gt 6 ]; then
# Borro la mas antigua
find "$ruta_a_dejar_copia" -name "daily_*.tar.gz" -printf '%T+ %p\n' | sort | head -n 1 | cut -d ' ' -f 2- | xargs rm
fi
fi


# Si es domingo
# Tengo que ver como está el directorio de copias de seguridad
if [ $(date +%u) -eq 7 ]; then
# Si la ultima copia mensual tiene mas de 21 dias
ultima_mesual=$(find "$ruta_a_dejar_copia" -name "monthly_*" -printf '%T+ %p\n' | sort | tail -n 1 | cut -d ' ' -f 2-)
# Si ultima_mensual tiene mas de 21 dias
if [ $(find "$ultima_mesual" -mtime +21 | wc -l) -gt 0 ]; then


# Hago copia mensual
tar --listed-incremental="$ruta_a_dejar_copia/weekly_snar_$(date +%V).snar" -czf - "$ruta_dir_a_copiar" 2> /dev/null | openssl enc -aes-256-cbc -e -pass pass:$contrasena_encriptacion -pbkdf2 -out "$ruta_a_dejar_copia/monthly_$(date +%Y)_$(date +%V).tar.gz" 
# Hago borrado de las mensuales
# Si en el directorio hay mas de 12 que se llaman monthly_*.tar.gz
if [ $(find "$ruta_a_dejar_copia" -name "monthly_*.tar.gz" | wc -l) -gt 13 ]; then
# Borro la mas antiguas
find "$ruta_a_dejar_copia" -name "monthly_*.tar.gz" -printf '%T+ %p\n' | sort | head -n 1 | cut -d ' ' -f 2- | xargs rm
fi
else
# Hago copia semanal
tar --listed-incremental="$ruta_a_dejar_copia/weekly_snar_$(date +%V).snar" -czf - "$ruta_dir_a_copiar" 2> /dev/null | openssl enc -aes-256-cbc -e -pass pass:$contrasena_encriptacion -pbkdf2 -out "$ruta_a_dejar_copia/weekly_$(date +%Y)_$(date +%V).tar.gz" 
# Hago borrado de las semanales
# Si en el directorio hay mas de 3 que se llaman weekly_*.tar.gz
if [ $(find "$ruta_a_dejar_copia" -name "weekly_*.tar.gz" | wc -l) -gt 3 ]; then
# Borro la mas antiguas
find "$ruta_a_dejar_copia" -name "weekly_*.tar.gz" -printf '%T+ %p\n' | sort | head -n 1 | cut -d ' ' -f 2- | xargs rm
fi
fi
fi

# Controlo el borrado de los snar
# Mantengo los 2 últimos snar solamente de cara a la recuperación
if [ $(find "$ruta_a_dejar_copia" -name "weekly_*.snar" | wc -l) -gt 2 ]; then
# Borro la mas antigua
find "$ruta_a_dejar_copia" -name "weekly_*.snar" -printf '%T+ %p\n' | sort | head -n 1 | cut -d ' ' -f 2- | xargs rm
fi

# Controlo que el espacio de almacenamiento no supere el 90% de num
# Si supera el 90% mando un mail al usuario
# Si no supera el 90% no hago nada
# Calculo el espacio ocupado (en KB)
espacio_ocupado=$(du -s "$ruta_a_dejar_copia" | cut -f 1) 
# Calculo el espacio maximo
# Calculo el porcentaje
porcentaje=$(echo "scale=2; $espacio_ocupado/$num*100" | bc)
# Si el porcentaje es mayor que 90
if [ $(echo "$porcentaje > 90" | bc) -eq 1 ]; then
# Mando un mail al usuario
echo "El espacio de almacenamiento de las copias de seguridad ha superado el 90% del espacio disponible" | mail -s "Espacio de almacenamiento de copias de seguridad" $mail
fi





