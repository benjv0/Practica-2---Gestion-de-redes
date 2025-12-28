# Comienzo del fichero
set ns [new Simulator]

# Se abre el fichero de trazas para la herramienta NAM
set nf [open out.nam w]
$ns namtrace-all $nf

# Se abre el fichero de trazas de salida
set f [open out.tr w]
$ns trace-all $f


#####################################################
#  INSERTAR AQUI LA DEFINICION DE LA RED A SIMULAR  #
#####################################################

# n0: Fuente Video (s1)
# n1: Fuente FTP (s2)
# n2: Edge Router In (e1)
# n3: Core Router
# n4: Edge Router Out (e2)
# n5: Destino Video (dest1)
# n6: Destino FTP (dest2)

set n0 [$ns node] 
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node] 
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]


# Definición de Enlaces

# Enlaces de Fuentes a Edge1
$ns duplex-link $n0 $n2 5Mbps 1ms DropTail
$ns duplex-link $n1 $n2 5Mbps 1ms DropTail

# ENLACES DEL DOMINIO DIFFSERV
# n2 (edge1) -> n3 (core)
$ns simplex-link $n2 $n3 5Mbps 1ms dsRED/edge
# n3(core) -> n2 (edge1)
$ns simplex-link $n3 $n2 5Mbps 1ms dsRED/core

# n3(core) -> n4 (edge2) 
$ns simplex-link $n3 $n4 3Mbps 1ms dsRED/core
# n4(edge2) -> n3(core)
$ns simplex-link $n4 $n3 3Mbps 1ms dsRED/edge

# Enlaces de Edge2 a Destinos
$ns duplex-link $n4 $n5 5Mbps 1ms DropTail
$ns duplex-link $n4 $n6 5Mbps 1ms DropTail


# Límite de cola entre Core y Edge2 
$ns queue-limit $n3 $n4 10

# CONFIGURACIÓN DIFFSERV

set qE1C [[$ns link $n2 $n3] queue]
set qCE2 [[$ns link $n3 $n4] queue]
set qE2C [[$ns link $n4 $n3] queue]
set qCE1 [[$ns link $n3 $n2] queue]

# Configuramos las colas físicas y virtuales para el primer enlace
# Definimos 2 colas físicas y 2 virtuales
$qE1C set numQueues_ 2
$qE1C setNumPrec 2

#Criterios Token Bucket
$qE1C addPolicyEntry [$n0 id] [$n5 id] TokenBucket 10 2500000 10000
$qE1C addPolicerEntry TokenBucket 10 11
$qE1C addPolicyEntry [$n1 id] [$n6 id] TokenBucket 20 1000000 10000
$qE1C addPolicerEntry TokenBucket 20 21

# Tráfico Video -> Cola Física 0
$qE1C addPHBEntry 10 0 0
$qE1C addPHBEntry 11 0 1

# Tráfico FTP -> Cola Física 1
$qE1C addPHBEntry 20 1 0
$qE1C addPHBEntry 21 1 1

$qE1C setSchedularMode RR
$qE1C addQueueRate 0 2500000 
$qE1C addQueueRate 1 1000000 
$qE1C meanPktSize 1000 

#PARÁMETROS RED
# Cola Video
$qE1C configQ 0 0 20 40 0.02
$qE1C configQ 0 1 10 20 0.10
# Cola FTP
$qE1C configQ 1 0 20 40 0.02
$qE1C configQ 1 1 10 20 0.10

# Configuramos las colas físicas y virtuales para el segundo enlace
# Definimos 2 colas físicas y 2 virtuales
$qCE2 set numQueues_ 2
$qCE2 setNumPrec 2

$qCE2 addPHBEntry 10 0 0
$qCE2 addPHBEntry 11 0 1
$qCE2 addPHBEntry 20 1 0
$qCE2 addPHBEntry 21 1 1

$qCE2 setSchedularMode RR
$qCE2 addQueueRate 0 2500000
$qCE2 addQueueRate 1 1000000
$qCE2 meanPktSize 1000 

#PARÁMETROS RED
# Cola Video
$qCE2 configQ 0 0 20 40 0.02
$qCE2 configQ 0 1 10 20 0.10
# Cola FTP
$qCE2 configQ 1 0 20 40 0.02
$qCE2 configQ 1 1 10 20 0.10

###########################################################
# Configuramos las colas físicas y virtuales para el tercer enlace
# Definimos 2 colas físicas y 2 virtuales
$qE2C set numQueues_ 2
$qE2C setNumPrec 2

#Criterios Token Bucket
$qE2C addPolicyEntry [$n5 id] [$n0 id] TokenBucket 10 2500000 10000
$qE2C addPolicerEntry TokenBucket 10 11
$qE2C addPolicyEntry [$n6 id] [$n1 id] TokenBucket 20 1000000 10000
$qE2C addPolicerEntry TokenBucket 20 21

# Tráfico Video -> Cola Física 0
$qE2C addPHBEntry 10 0 0
$qE2C addPHBEntry 11 0 1

# Tráfico FTP -> Cola Física 1
$qE2C addPHBEntry 20 1 0
$qE2C addPHBEntry 21 1 1

$qE2C setSchedularMode RR
$qE2C addQueueRate 0 2500000 
$qE2C addQueueRate 1 1000000 
$qE2C meanPktSize 1000 

#PARÁMETROS RED
# Cola Video
$qE2C configQ 0 0 20 40 0.02
$qE2C configQ 0 1 10 20 0.10
# Cola FTP
$qE2C configQ 1 0 20 40 0.02
$qE2C configQ 1 1 10 20 0.10

# Configuramos las colas físicas y virtuales para el cuarto enlace
# Definimos 2 colas físicas y 2 virtuales
$qCE1 set numQueues_ 2
$qCE1 setNumPrec 2

$qCE1 addPHBEntry 10 0 0
$qCE1 addPHBEntry 11 0 1
$qCE1 addPHBEntry 20 1 0
$qCE1 addPHBEntry 21 1 1

$qCE1 setSchedularMode RR
$qCE1 addQueueRate 0 2500000
$qCE1 addQueueRate 1 1000000
$qCE1 meanPktSize 1000 

#PARÁMETROS RED
# Cola Video
$qCE1 configQ 0 0 20 40 0.02
$qCE1 configQ 0 1 10 20 0.10
# Cola FTP
$qCE1 configQ 1 0 20 40 0.02
$qCE1 configQ 1 1 10 20 0.10


#Video CBR (n0 -> n5)
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0
set null0 [new Agent/Null]
$ns attach-agent $n5 $null0
$ns connect $udp0 $null0

set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set rate_ 2Mbps
$cbr0 attach-agent $udp0

#FTP TCP (n1 -> n6)
set tcp0 [new Agent/TCP/Newreno]
$ns attach-agent $n1 $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n6 $sink0
$ns connect $tcp0 $sink0

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ftp0 set type_ FTP

# Eventos de tiempo
$ns at 1.0 "$cbr0 start"
$ns at 45.0 "$cbr0 stop"
$ns at 5.0 "$ftp0 start"
$ns at 50.0 "$ftp0 stop"


$ns at 50.0 "finish"

proc finish {} {

# Se indica que se usaran estas variables externas al procedimiento
    global ns nf f
    $ns flush-trace

  # Se cierran los ficheros de trazas    
    close $nf
    close $f

  # Se indica por pantalla que se ejecutara la herramienta NAM    
    puts "Simulación DiffServ terminada. Ejecutando NAM..."
  # Se ejecuta la herramienta NAM con el fichero out.nam generado
  # exec nam out.nam &
    
    exit 0
}

# Se lanza la simulacion
$ns run
