    MAC_ACLs_evasion (Testeada en Kali Linux)
    
    
   Script para evadir el filtrado MAC de cualquier punto de acceso WIFI y saltar Portales Cautivos.
    
  * Para el correcto funcionamiento del script el punto de acceso objetivo no debe contar con Client Isolation.



¿Qué es el filtrado MAC?

El filtrado MAC funciona dando instrucciones al router para que permita conectarse a los dispositivos cuyo MAC aparezca en un lista de control de acceso. Cualquier otro terminal cuyo identificador de red no se encuentre en esta lista no podrá acceder a dicha red.







    Requisitos:


 * Tarjeta de red inalámbrica compatible con modo monitor
e inyección de paquetes.

 * Suite Aircrack-ng 
 
 
       Modo de uso:



 1- Otorgarle permisos de ejecución al script.

* chmod +x MAC_ACLs_evasion.sh 

 2- Ejecutar el script y seguir las indicaciones 
mostradas en pantalla. 

* ./MAC_ACLs_evasion.sh
