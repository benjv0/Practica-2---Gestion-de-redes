#type: perl <script-name> <trace-file> <to-node> <packet-name> <granularity> > output file

$infile=$ARGV[0];
$tonode=$ARGV[1];
$packetname=$ARGV[2];
$granularity=$ARGV[3];

# We compute packets received and lost during the time interval specified by granularity
$received = 0;
$discarded = 0;
$clock = 0;

open (DATA, "<$infile")
	|| die "Can't open $infile $!";
while (<DATA>) {
	@x = split(' ');
	# Checking if the event is a packet received 
	if ($x[0] eq 'r') {
		# Check if the packet is for the destination node and matches the packet type
		if ($x[3] eq $tonode && $x[4] eq $packetname) {
			$received++; # Increment the received packet count
		}
	}
	# Checking if the event is a packet discarded and the type of packet fits the input argument
	elsif ($x[0] eq 'd' && $x[4] eq $packetname) {
			$discarded++; # Increment the discarded packet count

	}
	# When the time reaches the granularity, calculate and print the loss rate
	if ($x[1] - $clock > $granularity) {
		$total = $received + $discarded; #COMPLETAR - Compute total number of packets 
		if ($total > 0) {
			$loss_rate = $discarded / $total; # COMPLETAR - Calculate loss rate

		} else {
			$loss_rate = 0; # No packets received or discarded, so loss rate is 0
		}
		print STDOUT "$x[1] $loss_rate\n"; # Print the time and loss rate
		$clock = $clock + $granularity; # Move the clock forward by granularity
		$received = 0; # Reset received packets counter
		$discarded = 0; # Reset discarded packets counter
		}
	}
# Final print for the last time interval
$total = $received + $discarded; #COMPLETAR - Compute total number of packets 
if ($total > 0) {
	$loss_rate = $discarded / $total # COMPLETAR - Calculate loss rate
} else {
	$loss_rate = 0;
}
print STDOUT "$x[1] $loss_rate\n"; # Print the last loss rate
close DATA;
exit(0);
