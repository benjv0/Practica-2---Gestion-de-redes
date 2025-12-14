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

# Mapeo:
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
$ns simplex-link $n2 $n3 5Mbps 1ms dsRED/Edge
# n3(core) -> n2 (edge1)
$ns simplex-link $n3 $n2 5Mbps 1ms dsRED/Core

# n3(core) -> n4 (edge2) 
$ns simplex-link $n3 $n4 3Mbps 1ms dsRED/Core
# n4(edge2) -> n3(core)
$ns simplex-link $n4 $n3 3Mbps 1ms dsRED/Edge

# Enlaces de Edge2 a Destinos
$ns duplex-link $n4 $n5 5Mbps 1ms DropTail
$ns duplex-link $n4 $n6 5Mbps 1ms DropTail


# Límite de cola entre Core y Edge2 
$ns queue-limit $n3 $n4 10

# CONFIGURACIÓN DIFFSERV

set qE1C [[$ns link $n2 $n3] queue]
set qCE2 [[$ns link $n3 $n4] queue]

# Configuramos las colas físicas y virtuales para el primer enlace
# Definimos 2 colas físicas y 2 virtuales (precedencias)
$qE1C set numQueues_ 2
$qE1C setNumPrec 2
$qCE2 set numQueues_ 2
$qCE2 setNumPrec 2




# --- Video CBR (n0 -> n5) ---
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0
set null0 [new Agent/Null]
$ns attach-agent $n5 $null0
$ns connect $udp0 $null0

set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set rate_ 2Mbps
$cbr0 attach-agent $udp0

# --- FTP TCP (n1 -> n6) ---
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
    exec nam out.nam &
    
    exit 0
}

# Se lanza la simulacion
$ns run
