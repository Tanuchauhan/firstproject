#usr/bin/perl
use strict;
use warnings;
use WWW::Mechanize;
use Data::Dumper;
my $inputFile = $ARGV[0];

&main();

my %visitedPage;
my %emails;
my %numbers;

sub main
{
    my $websiteLinksRef = &getInputWebsiteLink();
    my $contactUrl = &fetchContactUrl($websiteLinksRef);

}

sub getInputWebsiteLink
{
    my @websiteLinks;
    open(my $fh, '<:encoding(UTF-8)', $inputFile)
    or die "Could not open file '$inputFile' $!";

    while (my $row = <$fh>) {
        chomp($row);
        $row =~ s/\s+$//g;
        push (@websiteLinks , $row);
    }
    return \@websiteLinks ;
}

sub fetchContactUrl
{
    my ($websiteLinksRef) = @_ ;
    foreach my $websiteLink (@$websiteLinksRef) {
        my @email = ();
        my @phone = ();
        %emails = ();
        %numbers = ();
        my $response;
        print "Fetching $websiteLink \n";
        my $content = getContent($websiteLink,0);
        foreach my $key (keys(%emails)) {
                push @email ,$key;
         }
        foreach my $key (keys(%numbers)) {
                push @phone, $key;
         }
        if(scalar @email != 0 || scalar @phone != 0){
        while (@email || @phone){
                  my $v1= shift @email || "";
                  my $v2= shift @phone || "";

                  print "$websiteLink,$v1,$v2\n";
                                 }
        }
        else
        {
         print "$websiteLink,,,\n";
        }

    }
}

sub getContent
{
     my ($websiteLink, $depth) = @_;
     my $cont = 1;
     my $mech = WWW::Mechanize->new(autocheck => 0, ssl_opts => { verify_hostname => 0 });
     #sleep 2;
     my $response = "";
     my $result = eval {
         $mech->get($websiteLink);
     };
     unless($result) {
            print $@;

     }
     else {

     $mech->get($websiteLink);
     my $content = $mech->content;
     &fetchInfo($content);
     if ($depth < $cont) {
     my @internalLinks = $mech->find_all_links(url_abs_regex => qr/^\Q$websiteLink\E/, tag => 'a' );
     my @links = do { my %seen; grep { !$seen{$_}++ } @internalLinks };
     foreach my $linkList(@links) {
          my $link = $linkList->url_abs();
          if(!$visitedPage{$link}){
          $visitedPage{$link} = 1;
          &getContent($link, $depth+1 );
          }
     }
     }
     }
return 1;
}

sub fetchInfo
{

     my ($content) = @_;
     my @data = split "\n", $content;
     my $email="";
     my $phone="";
     foreach my $line (@data) {
        chomp($line);
        if ($line =~ /(([\+|\(]\d{2}\)?\s*\-?\d?\-?\s*\d{4}\-?\s*\d{4})|((\d{2}|\d{4})\s+\d{2,4}\s+\d{2,4}))/ig){
            my $val = $1;
            my $count = () = $val =~ /\d/g;
            if ($count >= 10){
                    #$val =~ s/^\+61\s*\d/\0/;
                    #$val =~ s/\D//g;
                $numbers{$val}=1;
            }

        }
        if ($line =~ /mailto\s*\:|email\:/ig) {
             if ($line =~ /([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)/gi) {
                $emails{$1}=1;
             }
          }

     }

 }
