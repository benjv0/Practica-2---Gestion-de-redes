#type: perl <script-name> <trace-file> <to-node> <packet-name> > output file

$infile=$ARGV[0];
$tonode=$ARGV[1];
$packetname=$ARGV[2];

$received = 0;
$discarded = 0;

open (DATA, "<$infile") 
	|| die "Can't open $infile $!";

while (<DATA>) {
	@x = split(' ');

	# Si es recibido en el destino correcto
	if ($x[0] eq 'r') {
		if ($x[3] eq $tonode && $x[4] eq $packetname) {
			$received++; 
		}
	}
	# Si es descartado (solo comprobamos tipo de paquete)
	elsif ($x[0] eq 'd' && $x[4] eq $packetname) {
			$discarded++; 
	}
}

# CALCULO FINAL AGREGADO
$total = $received + $discarded;

if ($total > 0) {
	$loss_rate = $discarded / $total;
} else {
	$loss_rate = 0;
}

print STDOUT "Tasa de Perdidas Media para $packetname: $loss_rate\n";

close DATA;
exit(0);
