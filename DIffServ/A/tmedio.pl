#type: perl <script-name> <trace-file> <event-type> <to-node> <packet-name> > output file
# NOTA: Quitamos el argumento de granularidad porque ya no hace falta.

$infile=$ARGV[0];
$event=$ARGV[1];
$tonode=$ARGV[2];
$packetname=$ARGV[3];

$sum=0;
$startTime = -1;
$endTime = 0;

open (DATA,"<$infile") || die "Can't open $infile $!";

while (<DATA>) {
	@x = split(' ');

	# Actualizamos el tiempo final con cada línea leida
	$endTime = $x[1];
	if ($startTime == -1) { $startTime = $x[1]; }

	# Filtramos igual que antes
	if ($x[0] eq $event) { 
		if ($x[3] eq $tonode) { 
			if ($x[4] eq $packetname) {
    			# Acumulamos TODOS los bits (bytes * 8)
    			$sum=$sum+8*$x[5];
			}
		}
	} 
}

# CALCULO FINAL: Total bits / Tiempo total simulado
# Evitamos división por cero
$totalTime = $endTime - $startTime;
if ($totalTime > 0) {
    $throughput=$sum/$totalTime;
} else {
    $throughput=0;
}

print STDOUT "Throughput Medio para $packetname: $throughput bps\n";

close DATA;
exit(0);
