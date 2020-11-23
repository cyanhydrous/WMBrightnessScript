#!/bin/bash

# Este script requiere que tengas permisos de escritura en el archivo de brillo
# Puedes agregar una regla udev para ello. Solo crea un archivo en el directorio /etc/udev/rules.d/backlight.rules y agrega lo siguiente
# ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="acpi_video0", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
# ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="acpi_video0", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
# No pongas los "#" obviamente
# OJO: Reemplaza la linea de acpi_video0 con el nombre de la grafica que tengas en el direcotio /sys/class/backlight/
# Mas info aquí https://wiki.archlinux.org/index.php/backlight#Udev_rule

# OJO: si tienes multiples directorios en esta carpeta esto no va a funcionar
# Tendrás que averiguar manualmente el directorio y poner el correspondiente
# Solo reemplaza la linea de abajo con una de las siguientes segun corresponda:
# grafica="radeon_bl0"
# grafica="amdgpu_bl0"
# grafica="intel_backlight"
# grafica="acpi_video0"

grafica=$(ls /sys/class/backlight)

# Aquí se obtiene el valor actual del archivo del brillo del kernel
# También se establece el valor del incremento y el brillo máximo
# En mi caso el brillo máximo es de 255 por lo que escogí usar 17 como incremento
# Puesto que 255/17=15 lo cual es perfecto porque tengo exactamente 15 incrementos
# Esta es una manera muy perezosa de hacer las cosas sinceramente puesto que estos valores son fijos y no dinamicos
# Hay que tomar en cuenta que mi gráfica funciona de esta manera y puede que no corresponda a como funciona la tuya
# Sientete libre de editarlo a tu gusto pues desconozco como funcionen otras graficas y por favor hazmelo saber

archivobrillo="/sys/class/backlight/$grafica/brightness"
brilloactual="$(cat $archivobrillo)"
brillonuevo=0
brillomax=255
incremento=17

# El msgId es para poder reemplazar la notificacion de brillo cuando este vuelva a cambiar
# Sin esto, tu demonio de notificacion va a poner una notificacion por cada vez que cambies el brillo
# Lo que será muy molesto

msgId="991049"

# En esta funcion se aumenta el brillo
# Una vez obtenido el valor del brillo nuevo se escribe el brillo al archivo de brillo

function masBrillo {
echo "Brillo Anterior = $brilloactual"
brillonuevo=$((incremento+brilloactual))
escribirBrillo
}

# Lo mismo que la anterior pero logicamente reduce el brillo en vez de aumentarlo

function menosBrillo {
echo "Brillo Anterior = $brilloactual"
brillonuevo=$((brilloactual-incremento))
escribirBrillo
}

# Esta funcion se encarga de obtener el emoji correspondiente al nivel del brillo actual
# No es necesaria para el funcionamiento, es simplemente una decoración y la puedes eliminar
# Ten encuenta que tendrás que editar la parte de abajo primero si deseas removerlo

function obtenerIcono () {

if [ $1 -lt 25 ] || [ $1 -eq 25 ]
then
    icono="🔅"
elif [ $1 -lt 50 ] || [ $1 -eq 50 ]
then
    icono="🔆"
elif [ $1 -lt 75 ] || [ $1 -eq 75 ]
then
    icono="☀️"
elif [ $1 -lt 100 ] || [ $1 -eq 100 ]
then
    icono="☀️❗"
fi
}

# Esta funcion es la responsable de escribir el brillo nuevo al archivo de brillo y de mandar la notificacion
# La notificacion que despliega es el porcentaje del brillo actual así como el icono correspondiente
# Solo lo hace si el brillo no está en el valor maximo o minimo dependiendo de la acción usada
# OJO: se necesita dunstify para poder mandar la notificacion
# Se puede hacer con notify-send pero no encontré la manera de reemplazar la notificacion con msgId
# Por eso opté por hacerlo con dunstify, además de que esto viene incluido con dunst de todas maneras

function escribirBrillo {
if [ $brillonuevo -gt $brillomax ]
then
    echo "El brillo ya está en el valor máximo"
    dunstify -r "$msgId" \ "Brillo máximo"
elif [ $brillonuevo -lt 0 ]
then
    echo "El brillo ya está en el valor mínimo"
    dunstify -r "$msgId" \ "Brillo mínimo"
else
  echo $brillonuevo > $archivobrillo
  echo "Brillo Nuevo = $brillonuevo"
  brilloactual="$(cat $archivobrillo)"
  porcentaje=$(printf "%.0f" $(echo "$brilloactual * 100/$brillomax" | bc -l ))
  
# Si no deseas desplegar el icono, elimina la linea de abajo o comentala (la de "obtenerIcono $porcentaje")
# Y a la linea de dunstify reemplazala con esto:
# dunstify -r "$msgId" \ "Brillo: ${porcentaje}%"

  obtenerIcono $porcentaje
  dunstify -r "$msgId" \ "Brillo: ${porcentaje}% ${icono}"
fi
}

# Finalmente esta porcion del script se encarga de determinar qué hacer cuando se le llama
# Con el parametro "--up" se incrementa y por lógica el "--down" lo reduce
# Si se recibe cualquier otro parametro o ninguno, el script solo imprime el valor del brillo actual en la consola
# Por lo que no será visible en la notificacion

case "$1" in
    --up)
        masBrillo
        ;;
    --down)
        menosBrillo
        ;;
    *)
        echo "Brillo Actual = $brilloactual"
        ;;    
esac
