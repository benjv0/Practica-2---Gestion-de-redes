#type: perl <script-name> <trace-file> <event-type> <to-node> <packet-name> <granularity> > output file

$infile=$ARGV[0];
$event=$ARGV[1];
$tonode=$ARGV[2];
$packetname=$ARGV[3];
$granularity=$ARGV[4];

#we compute how many bytes were transmitted during time interval specified
#by granularity parameter in seconds
$sum=0;
$clock=0;

      open (DATA,"<$infile")
        || die "Can't open $infile $!";

while (<DATA>) {

	@x = split(' ');

	#checking the event type
	if ($x[0] eq $event) 
	{ 
	#checking the destination
		if ($x[3] eq $tonode) 
		{ 
		#checking the packet name
			if ($x[4] eq $packetname) 
			{
    			$sum=$sum+8*$x[5];
			}
		}
	}

	if ($x[1]-$clock > $granularity)
	{
    	$throughput=$sum/($x[1]-$clock);
    	print STDOUT "$x[1] $throughput\n";
    	$clock=$clock+$granularity;
    	$sum=0;
	}   
}

    $throughput=$sum/($x[1]-$clock);
    print STDOUT "$x[1] $throughput\n";
    $clock=$clock+$granularity;
    $sum=0;

    close DATA;
exit(0);

