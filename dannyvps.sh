#!/bin/bash

# Definir la ruta del archivo JSON
config_file="/root/udp/config.json"

# Función para agregar una contraseña
function add_password() {
  # Leer las nuevas contraseñas desde el usuario
  echo "Ingrese las nuevas contraseñas separadas por comas: "
  read new_passwords

  # Convertir las contraseñas a un array
  IFS=',' read -ra passwords_arr <<< "$new_passwords"

  # Leer las contraseñas existentes desde el archivo JSON
  existing_passwords=$(jq -r '.auth.pass | join(",")' "$config_file")

  # Concatenar las contraseñas existentes con las nuevas
  updated_passwords="$existing_passwords,${passwords_arr[@]}"

  # Actualizar el archivo JSON con las nuevas contraseñas
  jq ".auth.pass = [\"$(echo $updated_passwords | sed 's/,/", "/g')\"]" "$config_file" > tmp.json && mv tmp.json "$config_file"

  # Confirmar que se actualizaron las contraseñas correctamente
  if [ "$?" -eq 0 ]; then
    echo "Contraseñas actualizadas correctamente."
  else
    echo "No se pudo actualizar las contraseñas."
  fi

  # Recargar el daemon de systemd y reiniciar el servicio
  sudo systemctl daemon-reload
  sudo systemctl restart udp-custom
}

# Función para eliminar una contraseña
function delete_password() {
  # Leer las contraseñas existentes desde el archivo JSON
  existing_passwords=$(jq -r '.auth.pass | join(",")' "$config_file")

  # Leer la contraseña que se quiere eliminar desde el usuario
  echo "Ingrese la contraseña que desea eliminar: "
  read password_to_delete

  # Eliminar la contraseña del array de contraseñas
  updated_passwords=$(echo "$existing_passwords" | sed "s/$password_to_delete//g;s/,,/,/g;s/^,//;s/,$//")

  # Actualizar el archivo JSON con las nuevas contraseñas
  jq ".auth.pass = [\"$(echo $updated_passwords | sed 's/,/", "/g')\"]" "$config_file" > tmp.json && mv tmp.json "$config_file"

  # Confirmar que se eliminó la contraseña correctamente
  if [ "$?" -eq 0 ]; then
    echo "Contraseña eliminada correctamente."
  else
    echo "No se pudo eliminar la contraseña."
  fi

  # Recargar el daemon de systemd y reiniciar el servicio
  sudo systemctl daemon-reload
  sudo systemctl restart udp-custom
}

# Loop para mostrar el menú de opciones
while true; do
  echo "Seleccione una opción:"
  echo "1. Agregar una contraseña"
  echo "2. Eliminar una contraseña"
  echo "3. Salir"

  # Leer la opción seleccionada desde el usuario
  read option

  # Evaluar la opción seleccionada
  case $option in
    1) add_password ;;
    2) delete_password ;;
    3) exit ;;
    *) echo "Opción inválida" ;;
  esac
done

# Descargar e instalar UDP
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1CCEp3uoQ5E4LxkydfzcM7yD6elos6Ufh' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1CCEp3uoQ5E4LxkydfzcM7yD6elos6Ufh" -O install-udp && rm -rf /tmp/cookies.txt && chmod +x install-udp && ./install-udp [optional port exclude separated by coma, ex. 7300,1194]