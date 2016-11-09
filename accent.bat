c:\corpora\exe\perl -x %0 %1 %2 %3 %4
:pause
exit
#!usr/bin/perl
$DEBUG = 0;
$PREFIX_LEN = 3;
$HTML = 0;

if ($HTML) {
	%ACCENT = ("'" => '&#x301;', '`' => '&#x300;', '"' => '&#x303;');
} else{
	%ACCENT = ("'" => "'", '`' => '`', '"' => '"');
}

$VOC = "[àåèîóûışÿ¸ÀÅÈÎÓÛİŞß¨]";

if (!@ARGV) { print 'Usage: accent.bat <files>'; exit; }
@files = @ARGV;

%dic = ();
dic_read("$0/../accent1.dic");	# user dict
dic_read("$0/../accent.dic");	# main dict

if ($DEBUG) {
	open(OUT, ">accent.dix");
	foreach $k (sort (keys %dic)) { print OUT "$k\t$dic{$k}\n"; }
	close(OUT);
}

$time = time();
$count = 0;
foreach $file (@files) {
	print STDERR "\r", $file;
	open(IN, $file);
	($newfile = $file) =~ s/\.(?=[^.]+$)/.acc./;
	open(OUT, ">$newfile");
	while (<IN>) {
		if ($count % 1 == 0) { print "\r$count"; }
		chomp();
		@ar = split(/(<[^>]+>)/);
		foreach $a (@ar) {
			if ($a =~ /^</) { next; }
			@words = split(/([^À-ÿ¨¸]+)/, $a);
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
}
$time = time() - $time;
print STDERR "\n$time secs\n";

sub dic_read() {
	my ($dic) = @_;
	open(IN, $dic) || die "Can't open $dic";
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
	if ($word !~ /[À-ÿ]/) { return $word; }
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
		if ($acc eq "") { $acc = "'"; }
		$acc = $ACCENT{$acc} || $acc;
		$chars[$pos-1] .= $acc;
	}
	$word = join("", @chars);
	$word =~ s/å"/¸/g; $word =~ s/Å"/¨/g;
	return $word;
}

sub normalize() {
	my ($s) = @_;
	my $caps = ($s =~ /^[À-ß]/)?'!':'';
	$s =~ tr/À-ß¨¸/à-ÿåå/;
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
