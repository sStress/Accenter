#!/usr/bin/perl
use utf8;
binmode(STDOUT, ":utf8");

    
$DEBUG = 0;
$PREFIX_LEN = 3;
$HTML = 0;

if ($HTML) {
	%ACCENT = ("'" => '&#x301;', '`' => '&#x300;', '"' => '&#x303;');
} else{
	%ACCENT = ("'" => "'", '`' => '`', '"' => '"');
}

$VOC = "[аеиоуыэюяёАЕИОУЫЭЮЯЁ]";

if (!@ARGV) { print 'Usage: accent.bat <files>'; exit; }
@files = @ARGV;

%dic = ();
dic_read("accent1.dic");	# user dict
dic_read("accent.dic");	# main dict

if ($DEBUG) {
	open(OUT, ">accent.dix");
	foreach $k (sort (keys %dic)) { print OUT "$k\t$dic{$k}\n"; }
	close(OUT);
}

$time = time();
$count = 0;
foreach $file (@files) {
	print STDERR "\r\n", $file;
	print "\n";
	open(IN, "<:encoding(UTF-8)", $file);
	($newfile = $file) =~ s/\.(?=[^.]+$)/.acc./;
	open(OUT, ">:encoding(UTF-8)", "$newfile");
	while (<IN>) {
		if ($count % 1 == 0) { print "\r$count"; }
		chomp();
		@ar = split(/(<[^>]+>)/);
		foreach $a (@ar) {
			if ($a =~ /^</) { next; }
			@words = split(/([^А-яЁё]+)/, $a);
			foreach $w (@words) { $w = accentw($w); }
			$a = join('', @words);
			$count += $#words+1;
		}
		$_ = join('', @ar)."\n";
		print OUT $_;
	}
	close(IN); close(OUT);
  if (0) {
	$oldfile = $file. ".~";
	rename($file, $oldfile); rename($newfile, $file);
  }

  print "\n";
  $pppy = "python.exe pp.py";
  $inp = "$newfile";
  $command = "$pppy $inp";
  open IN, "$command |";
  @lines = <IN>;
  print "@lines";
}
$time = time() - $time;
print STDERR "\n$time secs\n";

sub dic_read() {
	my ($dic) = @_;
	open(IN, "<:encoding(UTF-8)", $dic) || die "Can't open $dic";
	print "Reading dictionary\n";
	while(<IN>) {
		chomp();
		($regex, $acc) = split(/\t/);
		($key = $regex) =~ s/\(.+$//;
		$val = "\x1$regex=$acc";
		$dic{$key} .= $val;
	}
	close(IN);
}

sub accentw() {
	my ($word) = @_;
    my (@chars) = split("",$word);
	if ($word !~ /[А-я]/) { return $word; }
	my ($key, $caps) = normalize($word);
	my $len = length($key);

	my $vals = "";
	for ($i = $len; $i >= 1; $i--) {
		my $prefix = substr($key, 0, $i);
		my $val = $dic{$prefix};
		if (!$val) { next; }
		my @ar = split(/\x1/, $val);
		foreach $v (@ar) {
			my ($re, $acc) = split(/=/, $v);
			if ($key =~ /^$re$/) { $vals = $acc; last; }
		}
	}

	if (!$vals) { return $word; }
	$lex_caps = ($vals =~ s/!//)?'!':'';
	if ($caps < $lex_caps) { return $word; }
	my @vals = split(/[,;]/, $vals);
	@vals = unique(@vals);
	$word =~ s/($VOC)/$1|/g;
	my @chars = split(/\|/, $word);
	foreach $val (@vals) {
		$val =~ /(\d+)(.*)/;
		my ($pos, $acc) = ($1, $2);
		if (($acc eq "")||($acc eq "\r")) { $acc = "'"; }
        if ($acc eq "\"\r") { $acc = "\""; }
		$acc = $ACCENT{$acc} || $acc;
		$chars[$pos-1] .= $acc;
	}
	$word = join("", @chars);
	$word =~ s/е"/ё/g; $word =~ s/Е"/Ё/g;
	return $word;
}

sub normalize() {
	my ($s) = @_;
	my $caps = ($s =~ /^[А-Я]/)?'!':'';
	$s =~ tr/А-ЯЁё/а-яее/;
	$s =~ s/&[^;]+;//g;
	return ($s, $caps);
}

sub unique() {
	my @ar = @_;
	my %h = ();
	foreach $a (@ar) { $h{$a} = 1; }
	@ar = sort keys %h;
	return @ar;
}
