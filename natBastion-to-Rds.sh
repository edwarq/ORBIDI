#!/bin/bash

# Instalación de iptables-services (si no está instalado)
yum install iptables-services -y

# Habilitar y reiniciar el servicio iptables
systemctl enable iptables
systemctl restart iptables

# Habilitar el reenvío de paquetes (para NAT)
sysctl -w net.ipv4.ip_forward=1

# Dirección del host de MySQL
HOST="mydbmysqldevops.ch6ug2iiilhv.us-east-1.rds.amazonaws.com"

# Realiza la resolución DNS para obtener la IP del host
echo "Resolviendo DNS para $HOST..."
IP_DESTINO=$(nslookup $HOST | grep "Address:" | tail -n 1 | awk '{print $2}')

# Verifica si se obtuvo una IP
if [ -n "$IP_DESTINO" ]; then
    echo "Resolución exitosa de $HOST. IP destino: $IP_DESTINO."
    echo "Procediendo a configurar iptables."

    # Limpia las reglas anteriores
    iptables -F
    iptables -t nat -F
    iptables -t mangle -F
    iptables -t raw -F
    iptables -X
    iptables -t nat -X
    iptables -t mangle -X
    iptables -t raw -X

    # Elimina las cadenas personalizadas, si existen
    iptables -t nat -D PREROUTING
    iptables -t nat -D OUTPUT
    iptables -t nat -D POSTROUTING

    # Reemplaza el archivo /etc/sysconfig/iptables con las nuevas reglas
    cat <<EOF > /etc/sysconfig/iptables
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A PREROUTING -p tcp -m tcp --dport 4580 -j DNAT --to-destination $IP_DESTINO:3306
-A OUTPUT -o lo -p tcp -m tcp --dport 4580 -j DNAT --to-destination $IP_DESTINO:3306
-A POSTROUTING -d $IP_DESTINO/32 -p tcp -m tcp --dport 3306 -j MASQUERADE
COMMIT
EOF

    # Recarga las reglas de iptables
    systemctl restart iptables

    echo "Archivo /etc/sysconfig/iptables reemplazado y reglas aplicadas."
else
    echo "Error al resolver DNS de $HOST. No se configuraron las reglas de iptables."
fi
