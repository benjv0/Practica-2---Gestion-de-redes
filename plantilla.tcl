# Comienzo del fichero
# Se crea el objeto simulador
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

#Generaciòn de los nodos de la estructura dada

set n0 [$ns node] 
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node] 
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

#Generacion de los enlaces de los nodos creados previamente

$ns duplex-link $n0 $n2 5Mbps 1ms DropTail 
$ns duplex-link $n1 $n2 5Mbps 1ms DropTail 
$ns duplex-link $n2 $n3 5Mbps 1ms DropTail 
$ns duplex-link $n3 $n4 3Mbps 1ms DropTail 
$ns duplex-link $n4 $n5 5Mbps 1ms DropTail 
$ns duplex-link $n4 $n6 5Mbps 1ms DropTail 

#Creacion del canal UDP
set u_src [new Agent/UDP]  
set u_dst [new Agent/Null] 

$ns attach-agent $n0 $u_src
$ns attach-agent $n5 $u_dst
$ns connect $u_src $u_dst

#creaciòn de trafico UDP
set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 500
$cbr set rate_ 2Mbps
$cbr attach-agent $u_src

$ns at 1 "$cbr start"
$ns at 45 "$cbr stop"

#Creacion del canal TCP 
set t_src [new Agent/TCP/Newreno]
set t_dst [new Agent/TCPSink]

$ns attach-agent $n1 $t_src
$ns attach-agent $n6 $t_dst
$ns connect $t_src $t_dst


#creaciòn de trafico TCP
set ftp [new Application/FTP]

$ftp attach-agent $t_src
$ftp set dataSize_ 2000000
$ns at 5 "$ftp start"

$ns queue-limit $n3 $n4 10


$ns at 50.0 "finish"

proc finish {} {
    
# Se indica que se usaran estas variables externas al procedimiento
  global ns nf f
  $ns flush-trace
	
  # Se cierran los ficheros de trazas
  close $nf
  close $f 

  # Se indica por pantalla que se ejecutara la herramienta NAM
  puts "running NAM..."

  # Se ejecuta la herramienta NAM con el fichero out.nam generado
  exec nam out.nam &

  exit 0
}

# Se lanza la simulacion
$ns run

