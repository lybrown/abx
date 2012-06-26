#!/usr/bin/perl
use strict;
use warnings;

sub take {
    my ($count) = @_;
    my $value = $_ & ((1<<$count)-1);
    $_ >>= $count;
    return $value;
}

sub main {
    print "unsigned long jumptable[] = {\n    ";
    for my $key (0 .. 1023) {
        $_ = $key;
        my $hi5 = take(5) << 3;
        my $selttest = take(1);
        my $basic = take(1);
        my $osrom = take(1);
        my $rw = take(1);
        my $ref = take(1);

        my $selfrange = 0x50 <= $hi5 && $hi5 <= 0x57;
        my $basicrange = 0xa0 <= $hi5 && $hi5 <= 0xbf;
        my $hardrange = 0xd0 <= $hi5 && $hi5 <= 0xd7;
        my $osromrange = 0xc0 <= $hi5 && $hi5 <= 0xff;

        my $notram =
            $selfrange && $selttest ||
            $basicrange && $basic ||
            $hardrange ||
            $osromrange && $osrom;

        my $readram = !$notram && $rw && !$ref;
        my $writeram = !$notram && !$rw && !$ref;
        my $readhard = $hardrange && $rw && !$ref;
        my $writehard = $hardrange && !$rw && !$ref;

        use Data::Dumper;
        #print Dumper [map { $_, sprintf "%02x", eval "\$$_" } qw(selttest basic osrom hi5 rw ref)];

        my $label =
            $readram ? "READRAM" :
            $writeram ? "WRITERAM" :
            $readhard ? "READHARD" :
            $writehard ? "WRITEHARD" :
            "NOP";
        print $label;
        if (($key + 1) % 16) {
            print ", ";
        } elsif ($key == 2047) {
            print "\n";
        } else {
            print ",\n    ";
        }
    }
    print "}\n";
}

main();
