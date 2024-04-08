#!/usr/bin/perl
# sample script to query ccminer API

#   FAJL="api.pl";cd ~/;rm -f $FAJL;wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL;chmod +x $FAJL

use strict;
use warnings;
use Getopt::Long qw(GetOptions);
my $command = "summary";
my $address = "127.0.0.1";
my $port = "4086";
GetOptions('cmd=s' => \$command,
           'address=s' => \$address,
           'port=s' => \$port,
) or die "Usage: $0 --cmd COMMAND --address ADDRESS --port PORT\n";
use Socket;
use IO::Socket::INET;
my $sock = new IO::Socket::INET (
    PeerAddr => $address,
    PeerPort => $port,
    Proto => 'tcp',
    ReuseAddr => 1,
    Timeout => 2,
);
if ($sock) {
    print $sock $command;
    my $res = "";
    while(<$sock>) {
        $res .= $_;
    }
    close($sock);
    print("$res\n");
} else {
    print("No Connection\n");
}
