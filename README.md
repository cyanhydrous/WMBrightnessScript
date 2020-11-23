# WMBrightnessScript
Script para cambiar el brillo de la pantalla con las teclas de brillo cuando usas un Window Manager

# Requisitos:
1. Usar un WM como i3-gaps
2. Que tu usuario sea parte del grupo "video"
3. Tener dunstify instalado
4. Saberle un poquito a los scripts de bash por si tienes problemas

# Pasos para usar el script:
1. Crear el directorio ~/.config/scripts y copiar el script setbrightness.sh ahí.

2. Asociar las teclas de brillo en el archivo de configuracion de tu WM.
p.e. en i3 sería:
bindsym XF86MonBrightnessDown exec --no-startup-id ~/.config/scripts/setbrightness.sh --down
bindsym XF86MonBrightnessUp exec --no-startup-id ~/.config/scripts/setbrightness.sh --up
Desconozco como se hace en otros WM por lo que tendrás que averiguarlo tú.

3. Agregar una regla udev para hacer que el grupo video pueda escribir al archivo "brightness"
que se encuentra en /sys/class/backlight/??/brightness donde ?? corresponde al modulo de la GPU
que estés usando. Para ello crea el archivo /etc/udev/rules.d/backlight.rules y agregale esto:
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="??", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="??", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
OJO: Edita el ?? por el modulo que tu tu kernel use para la GPU, en mi caso sería "amdgpu_bl0"
Visita https://wiki.archlinux.org/index.php/backlight para más información. En el script vienen mas ejemplos de los modulos!
Por si deseas checarlos.

4. Asegurate de que tu usuario esté dentro del grupo "video" ejecutando el comando "groups" y si no lo está ejecuta:
"sudo gpasswd -a $USER video" sin las comillas.

5. Reinicia y comprueba que las teclas de brillo funcionen.

Cualquier problema que tengas hazmelo saber por favor ya que solamente lo he probado usando el modulo AMDGPU bajo Arch Linux e
Intel i965 bajo Gentoo.
