#!/usr/bin/perl

use Cwd;
my $dir = cwd();
#Trim off 'perl' if that is the last thing
$dir =~ s/\/perl\/?$//i;
$dir =~ s/^.*\/([^\/]+)$/$1/;

$VERSION="0.0";
if ($dir =~ /-([\d\.]+)$/) {$VERSION=$1;}
if ($dir =~ /^(.+)-[\d\.]+$/) {$ModName="$1";}
else
 {$ModName=$dir;}

#My script files
opendir D, 'bin';
my ($A,$b,@_Scripts)=readdir D;
closedir D;
my @Scripts;
foreach my $I (@_Scripts)
{
  if ($I=~/,v$/i || $I eq 'makefile') {next;}
  push @Scripts, "bin/$I";
}

use ExtUtils::MakeMaker;
#see lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'    => $ModName,
    'dist'    => {COMPRESS=> 'gzip -9f', SUFFIX=>'gz', 
                  POSTOP => 'mv $(DISTNAME)-$(VERSION).tar.gz ../'
                  },
    'linkext' => {LINKTYPE => '' }, 
    'clean'   => {FILES => "*% *.html *~ www-* .htp* .htg*"},
    VERSION => $VERSION,
    'EXE_FILES' => [@Scripts],
    'MAN1PODS'  => {map {my $a=$_; s/^bin\//.\/blib\/man1\//; $a,"$_.\$(MAN1EXT)";} @Scripts},
);
