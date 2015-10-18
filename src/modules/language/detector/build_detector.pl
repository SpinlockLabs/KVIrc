#!/usr/bin/perl -w
#=============================================================================
#
#   Creation date : Fri 25 Dec 20:16:49 2004 GMT by Szymon Stefanek
#
#   This file is part of the KVirc irc client distribution
#   Copyright (C) 2004 Szymon Stefanek (pragma at kvirc dot net)
#
#   This program is FREE software. You can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your opinion) any later version.
#
#   This program is distributed in the HOPE that it will be USEFUL,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#   See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, write to the Free Software Foundation,
#   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
#
# This code contains parts from the text_cat program
# by Gertjan van Noord.
#
#
# Original copyright notice:
# © Gertjan van Noord, 1997.
# mailto:vannoord@let.rug.nl
#
#
# Copyright (c) 1994, 1995, 1996, 1997 by Gertjan van Noord.
# This program is distributed under Gnu General Public License
# (cf. the file COPYING in distribution). Alternatively, you can use
# the program under the conditions of the Artistic License (as Perl).
#
#=============================================================================

# No text interpretation please
#no locale;
#use PerlIO;

use strict;

# INTERNAL OPTIONS
my $debug = 0;
my $saveSpace = 1;


my $non_word_characters=':\)*\(!\?,\.\-\_\"\[\]\{\}\|\;0-9\s';
#my $non_word_characters='0-9\s';

my $g_maxNGrams = 400; # number of ngrams with len > 1
my $g_inputDir = "./data"; # directory with input files
my $g_dataTypeName = "double";

my $g_outputFileName = $ARGV[0];
$g_outputFileName or die("Missing output file name!\n");

# Gather available data
opendir DIR, "$g_inputDir" or die "Failed to open directory $g_inputDir: $!\n";
my @g_files = sort(grep { s/\.dat// && -r "$g_inputDir/$_.dat" } readdir(DIR));
closedir DIR;
@g_files or die "Can't find the language data files\n";

# open the output file name
open(OUTPUT,">","$g_outputFileName") || die "cannot open $g_outputFileName\n";
binmode(OUTPUT);

# spit out the header
print OUTPUT "//=============================================================================\n";
print OUTPUT "//\n";
print OUTPUT "//   A Simple statistical language/encoding detector\n";
print OUTPUT "//   This file is part of the KVirc irc client distribution\n";
print OUTPUT "//   Copyright (C) 2008 Szymon Stefanek (pragma at kvirc dot net)\n";
print OUTPUT "//\n";
print OUTPUT "//   This program is FREE software. You can redistribute it and/or\n";
print OUTPUT "//   modify it under the terms of the GNU General Public License\n";
print OUTPUT "//   as published by the Free Software Foundation; either version 2\n";
print OUTPUT "//   of the License, or (at your opinion) any later version.\n";
print OUTPUT "//\n";
print OUTPUT "//   This program is distributed in the HOPE that it will be USEFUL,\n";
print OUTPUT "//   but WITHOUT ANY WARRANTY; without even the implied warranty of\n";
print OUTPUT "//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.\n";
print OUTPUT "//   See the GNU General Public License for more details.\n";
print OUTPUT "//\n";
print OUTPUT "//   You should have received a copy of the GNU General Public License\n";
print OUTPUT "//   along with this program. If not, write to the Free Software Foundation,\n";
print OUTPUT "//   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.\n";
print OUTPUT "//\n";
print OUTPUT "//=============================================================================\n";
print OUTPUT "//\n";
print OUTPUT "// DO NOT EDIT THIS FILE: Edit detector/build_detector.pl instead!\n";
print OUTPUT "//\n";
print OUTPUT "\n";
print OUTPUT "#include <stdlib.h>\n";
print OUTPUT "#include <stdio.h>\n";
print OUTPUT "#include <string.h>\n";
print OUTPUT "#include <ctype.h>\n";
print OUTPUT "\n";
print OUTPUT "#include \"detector.h\"\n";
print OUTPUT "\n";
print OUTPUT "///////////////////////////////////////////////////////////////////////////////\n";
print OUTPUT "// CORE DEFS\n";
print OUTPUT "///////////////////////////////////////////////////////////////////////////////\n";
print OUTPUT "\n";
print OUTPUT "typedef struct _DetectorNGram\n";
print OUTPUT "{\n";
print OUTPUT "	const unsigned char * szNGram;\n";
print OUTPUT "	".$g_dataTypeName." dScore;\n";
print OUTPUT "} DetectorNGram;\n";
print OUTPUT "\n";
print OUTPUT "typedef struct _DetectorDescriptor\n";
print OUTPUT "{\n";
print OUTPUT "	const char * szLanguage;\n";
print OUTPUT "	const char * szEncoding;\n";
print OUTPUT "	".$g_dataTypeName." single_char_data[256];\n";
print OUTPUT "	DetectorNGram * ngram_hash[256];\n";
print OUTPUT "} DetectorDescriptor;\n";
print OUTPUT "\n";
print OUTPUT "static DetectorNGram X[] = { { 0, 0 } };\n";
print OUTPUT "\n";
print OUTPUT "///////////////////////////////////////////////////////////////////////////////\n";
print OUTPUT "// DEFINES THAT SAVE (A LOT OF) SPACE\n";
print OUTPUT "///////////////////////////////////////////////////////////////////////////////\n";
print OUTPUT "\n";
print OUTPUT "#define S static const unsigned char\n";
print OUTPUT "#define N static DetectorNGram\n";
print OUTPUT "#define D static DetectorDescriptor\n";
print OUTPUT "#define Z 0.000\n";
print OUTPUT "#define H {0,0}\n";
print OUTPUT "#define W -0.100\n";
print OUTPUT "#define Y -0.250\n";
print OUTPUT "#define V -0.350\n";
print OUTPUT "#define d 100\n";
print OUTPUT "#define e 101\n";
print OUTPUT "#define f 102\n";
print OUTPUT "#define g 103\n";
print OUTPUT "#define h 104\n";
print OUTPUT "#define i 105\n";
print OUTPUT "#define j 106\n";
print OUTPUT "#define k 107\n";
print OUTPUT "#define l 108\n";
print OUTPUT "#define m 109\n";
print OUTPUT "#define n 110\n";
print OUTPUT "#define o 111\n";
print OUTPUT "#define p 112\n";
print OUTPUT "#define q 113\n";
print OUTPUT "#define r 114\n";
print OUTPUT "#define s 115\n";
print OUTPUT "#define t 116\n";
print OUTPUT "#define u 117\n";
print OUTPUT "#define v 118\n";
print OUTPUT "#define w 119\n";
print OUTPUT "#define x 120\n";
print OUTPUT "#define y 121\n";
print OUTPUT "#define z 122\n";
print OUTPUT "#define a 32,0\n";

print OUTPUT "\n";
print OUTPUT "///////////////////////////////////////////////////////////////////////////////\n";
print OUTPUT "// DATA TABLES\n";
print OUTPUT "///////////////////////////////////////////////////////////////////////////////\n";
print OUTPUT "\n";
print OUTPUT "\n";

my @g_shortDigitStrings = (
	"00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "0a", "0b", "0c", "0d", "0e", "0f",
	"10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "1a", "1b", "1c", "1d", "1e", "1f",
	"g" , "21", "22", "23", "24", "25", "26", "27", "28", "29", "2a", "2b", "2c", "2d", "2e", "2f",
	"30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "3a", "3b", "3c", "3d", "3e", "3f",
	"40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "4a", "4b", "4c", "4d", "4e", "4f",
	"50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "5a", "5b", "5c", "5d", "5e", "5f",
	"60", "X" , "Y" , "Z" , "h" , "i" , "j" , "k" , "l" , "m" , "n" , "o" , "p" , "q" , "r" , "s" ,
	"t" , "u" , "v" , "w" , "x" , "y" , "z" , "_" , "78", "79", "7a", "7b", "7c", "7d", "7e", "7f",
	"80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "8a", "8b", "8c", "8d", "8e", "8f",
	"90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "9a", "9b", "9c", "9d", "9e", "9f",
	"a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "aa", "ab", "ac", "ad", "ae", "af",
	"b0", "b1", "b2", "b3", "b4", "b5", "b6", "b7", "b8", "b9", "ba", "bb", "bc", "bd", "be", "bf",
	"c0", "c1", "c2", "c3", "c4", "c5", "c6", "c7", "c8", "c9", "ca", "cb", "cc", "cd", "ce", "cf",
	"A" , "B" , "C" , "D" , "E" , "F" , "G" , "H" , "I" , "J" , "K" , "L" , "M" , "N" , "O" , "P" ,
	"Q" , "R" , "S" , "T" , "U" , "V" , "W" , "e7", "e8", "e9", "ea", "eb", "ec", "ed", "ee", "ef",
	"f0", "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "fa", "fb", "fc", "fd", "fe", "ff");


# crunch the data
my $file;
my @descriptors;
my $descriptorCnt = 0;
my $i;
my %strings_printed;

foreach $file (@g_files)
{
	my $m_language = lc($file);
	my $m_encoding = lc($file);

	$m_language =~ s/-[a-zA-Z0-9\-\._]+//g;
	$m_encoding =~ s/^[a-zA-Z_]+-//;

	print "Writing table for language ".$m_language." and encoding ".$m_encoding."\n";

	my $m_tableNamePrefix;
	if($saveSpace){ $m_tableNamePrefix = "l".$descriptorCnt; }
	else { $m_tableNamePrefix = $m_language."_".$m_encoding; }
	$m_tableNamePrefix =~ s/-//g;
	$descriptors[$descriptorCnt] = $m_tableNamePrefix."_d";
	$descriptorCnt++;

	my $data = "";
	open(LM,"$g_inputDir/$file.dat") || die "cannot open $file.dat: $!\n";
	binmode(LM);

	while(<LM>)
	{
		$_ =~ s/\r\n/ /g;
		$_ =~ s/\n/ /g;
		$_ =~ s/\./ /g;
		$_ =~ s/\;/ /g;
		$_ =~ s/\,/ /g;
		$_ =~ s/\)/ /g;
		$_ =~ s/\(/ /g;
		$_ =~ s/[0-9]+/ /g;
		$_ =~ s/\s\s[\s]*/ /g;
		$data .= lc($_);
	}

	close(LM);

	# GATHER DATA
	my %ngram = ();
	my @singleChars;
	my $totalChars = 0;
	my $word;

	for($i=0;$i<256;$i++)
	{
		$singleChars[$i] = 0;
	}

	$_ = $data;
	my $totalngrams = 0;
	foreach $word (split("[$non_word_characters]+"))
	{
		# we use " " to signal start and end of the word
		$word = " " . $word . " ";
		my $len = length($word);
		$totalngrams += $len - 2;
		my $flen=$len;
		my $i;
		for($i=0;$i<$flen;$i++)
		{
			if($len > 1)
			{
				if($len > 2)
				{
					if($len > 3)
					{
						$totalngrams++;
						$ngram{substr($word,$i,4)}++;
					}
					$totalngrams++;
					$ngram{substr($word,$i,3)}++;
				}
				$totalngrams++;
				$ngram{substr($word,$i,2)}++;
			}
			my $ord = ord substr($word,$i,1);
			if($ord > 32)
			{
				$totalChars++;
				$singleChars[$ord]++ if $ord > 32;
			}
			$len--;
		}
	}

	# sort the ngrams, and spit out the $g_maxNGrams frequent ones.
	# adding  `or $a cmp $b' in the sort block makes sorting five
	# times slower..., although it would be somewhat nicer (unique result)
	my @result = sort { $ngram{$b} <=> $ngram{$a} } keys %ngram;

	# ngrams starting char above 127 get higher scores
	# since they are characteristic of language (and we thus probably WANT
	# to include them in the hash
	# Chars above 191 get yet more

	foreach(@result)
	{
		if((ord $_) > 127)
		{
			$ngram{$_} = $ngram{$_} + ($ngram{$_} / 2);
			if((ord $_) > 191)
			{
				$ngram{$_} = $ngram{$_} + ($ngram{$_} / 2);
			}
		}
	}

	splice(@result,$g_maxNGrams) if (@result > $g_maxNGrams);

	my $results = 0;
	my $ngrams = 0;
	foreach(@result)
	{
		$ngrams++;
		$results += $ngram{$_};
	}

	my %percent = ();
	my %score = ();
	foreach(@result)
	{
		# BUILD EACH NGRAM SCORE
		$percent{$_} = ($ngram{$_} / $totalngrams) * 100.0;
		$score{$_} = $percent{$_} * length($_);
		# ngrams starting or ending with a space get their score multiplied
		# by 1.5 (characteristic of language)
		if((substr($_,0,1) eq " ") || (substr($_,length($_)-1,1) eq " "))
		{
			$score{$_} = $score{$_} * 1.5;
		}
	}

	# SPIT OUT OUTPUT

	print OUTPUT "\n";
	print OUTPUT "//\n";
	print OUTPUT "// Lng: ".$m_language."\n";
	print OUTPUT "// Enc: ".$m_encoding."\n";
	print OUTPUT "//\n";
	print OUTPUT "\n";

	# BUILD THE NGRAM TABLE DATA

	my @lists;
	my @strings = ();
	my @string_names = ();
	my $string_count = 0;

	for($i=0;$i<256;$i++)
	{
		$lists[$i] = "";
	}

	my @lenstats;
	for($i=0;$i<10;$i++)
	{
		$lenstats[$i] = 0;
	}

	foreach(@result)
	{
		my($hash,$j,$len);
		$len = length($_);
		$lenstats[$len]++;

		$hash = (ord substr($_,0,1)) * 31;
		if($len > 1)
		{
			$hash = $hash + ((ord substr($_,1,1)) * 17);
			if($len > 2)
			{
				$hash = $hash + ((ord substr($_,2,1)) * 11);
				if($len > 3)
				{
					$hash = $hash + ((ord substr($_,3,1)) * 3);
					if($len > 4)
					{
						$hash = $hash + ord substr($_,4,1);
					}
				}
			}
		}


		$hash = $hash % 256;

		# build the string
		my $tmp = "";
		my $z;
		my $string_name = "s";
		for($z = 0;$z < length($_);$z++)
		{

			if($tmp ne ""){ $tmp .= ","; };
			my $zzz1 = substr($_,$z,1);
			my $zzz2 = ord $zzz1;
			if(($zzz2 >= 100) && ($zzz2 <= 122))
			{
				$tmp .= $zzz1;
			} else {
				$tmp .= $zzz2;
			}
			$string_name .= $g_shortDigitStrings[ord substr($_,$z,1)];
		}

		$tmp .= ",0";

		$tmp =~ s/,32,0/,a/g; # really common sequence

		$strings[$string_count] = $tmp;
		$string_names[$string_count] = $string_name;
		$string_count++;

		if($lists[$hash] eq "")
		{
			$lists[$hash] =  "N ".$m_tableNamePrefix."n".$hash."[]={";
		}
		$lists[$hash] .= "{".$string_name.",";
		$lists[$hash] .= sprintf "%.3f},",$score{$_};
		$lists[$hash] =~ s/0\./\./g;
	}

	print OUTPUT "\n";

	# Print out the strings first
	for($i=0;$i<$string_count;$i++)
	{
		if(!exists($strings_printed{$string_names[$i]}))
		{
			$strings_printed{$string_names[$i]} = $strings[$i];
			print OUTPUT "S ".$string_names[$i]."[]={".$strings[$i]."};\n";
		}
	}

	print OUTPUT "\n";

	# now print the lists
	my $cnt = 0;

	for($i=0;$i<256;$i++)
	{
		if($lists[$i] ne "")
		{
			$lists[$i] .= "H";
			$lists[$i] .= "};\n";
			print OUTPUT $lists[$i];
			$cnt++;
		}
	}

	print OUTPUT "\n";
	print OUTPUT "D ".$m_tableNamePrefix."_d =\n";
	print OUTPUT "{\n";
	print OUTPUT "	\"".$m_language."\",\n";
	print OUTPUT "	\"".$m_encoding."\",\n";
	print OUTPUT "	{\n";
	for($i=0;$i<256;$i++)
	{
		my $perc;
		if($totalChars > 0)
		{
			if($singleChars[$i] > 0)
			{
				$perc = ($singleChars[$i] / $totalChars) * 2.0;
				if($i > 127){ $perc = $perc * 1.5; }
				if($i > 192){ $perc = $perc * 1.5; }
			} else {
				if($i > 192){ $perc = -0.350; }
				elsif($i > 127){ $perc = -0.250; }
				else { $perc = -0.100; }
			}
		} else {
			$perc = 0.0;
		}

		if($debug > 0){ print OUTPUT "		"; }
		else {
			if(($i % 16) == 0){ print OUTPUT "		"; }
		}

		if($perc == 0.0){ print OUTPUT "Z"; }
		elsif($perc == -0.100){ print OUTPUT "W"; }
		elsif($perc == -0.250){ print OUTPUT "Y"; }
		elsif($perc == -0.350){ print OUTPUT "V"; }
		else { printf OUTPUT "%.3f", $perc; }
		if($i < 255){ print OUTPUT ","; };
		if($debug > 0)
		{
			print OUTPUT " // ".$i;
			if($i > 31){ printf OUTPUT " (%c)",$i; };
			print OUTPUT "\n";
		} else {
			if(($i % 16) == 15){ print OUTPUT "\n"; }
		}
	}
	print OUTPUT "	},\n";
	print OUTPUT "	{\n";
	for($i=0;$i<256;$i++)
	{
		if(($i % 16) == 0){ print OUTPUT "		"; };

		if($lists[$i] ne "")
		{
			print OUTPUT "".$m_tableNamePrefix."n".$i;
		} else {
			print OUTPUT "X";
		}
		if($i < 255){ print OUTPUT ","; };
		if(($i % 16) == 15){ print OUTPUT "\n"; };
	}
	print OUTPUT "	}\n";
	print OUTPUT "};\n";

	if($debug > 0)
	{
		print OUTPUT "\n";
		print OUTPUT "//\n";
		printf OUTPUT "// NGram hash table coverage: %.3f %% (avg %.3f items per entry)\n", ($cnt / 256.0) * 100.0,$ngrams / $cnt;
		print OUTPUT "// Entry detail:\n";
		printf OUTPUT "//    Length 2: %d\n",$lenstats[2];
		printf OUTPUT "//    Length 3: %d\n",$lenstats[3];
		printf OUTPUT "//    Length 4: %d\n",$lenstats[4];
		printf OUTPUT "//    Length 5: %d\n",$lenstats[5];
		printf OUTPUT "//    Total: %d\n",$ngrams;
		printf OUTPUT "//    Total hits: %d\n",$results;
		print OUTPUT "//\n";
		print OUTPUT "//\n";
		foreach(@result)
		{
			print OUTPUT "// \"".$_."\": ";
			printf OUTPUT "count %d, percent %.3f, score %.3f \n",$ngram{$_},$percent{$_},$score{$_};
		}
		print OUTPUT "//\n";
		print OUTPUT "\n";
	}

	print OUTPUT "\n";
	print OUTPUT "\n";

#    print join("\n",map { "// $_\t $ngram{$_}" ; } @result),"\n";
}


print OUTPUT "\n";
print OUTPUT "\n";
print OUTPUT "///////////////////////////////////////////////////////////////////////////////\n";
print OUTPUT "// DETECTING FUNCTIONS\n";
print OUTPUT "///////////////////////////////////////////////////////////////////////////////\n";
print OUTPUT "\n";
print OUTPUT "\n";


print OUTPUT "\n";
print OUTPUT "static char valid_char_jump_table[256]=\n";
print OUTPUT "{\n";
if($debug > 0){ print OUTPUT "//	000 001 002 003 004 005 006 007   008 009 010 011 012 013 014 015 \n"; }
if($debug > 0){ print OUTPUT "//	NUL SOH STX ETX EOT ENQ ACK BEL   BS  HT  LF  VT  FF  CR  SO  SI\n"; }
print OUTPUT "	0  ,0  ,0  ,0  ,0  ,0  ,0  ,0    ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,\n";
if($debug > 0){ print OUTPUT "//	016 017 018 019 020 021 022 023   024 025 026 027 028 029 030 031 \n"; }
if($debug > 0){ print OUTPUT "//	DLE DC1 DC2 DC3 DC4 NAK SYN ETB   CAN EM  SUB ESC FS  GS  RS  US\n"; }
print OUTPUT "	0  ,0  ,0  ,0  ,0  ,0  ,0  ,0    ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,\n";
if($debug > 0){ print OUTPUT "//	032 033 034 035 036 037 038 039   040 041 042 043 044 045 046 047 \n"; }
if($debug > 0){ print OUTPUT "//	    !   \"   #   $   %   &   '     (   )   *   +   ,   -   .   /   \n"; }
print OUTPUT "	0  ,0  ,1  ,0  ,0  ,0  ,1  ,1    ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,\n";
if($debug > 0){ print OUTPUT "//	048 049 050 051 052 053 054 055   056 057 058 059 060 061 062 063 \n"; }
if($debug > 0){ print OUTPUT "//	0   1   2   3   4   5   6   7     8   9   :   ;   <   =   >   ?   \n"; }
print OUTPUT "	0  ,0  ,0  ,0  ,0  ,0  ,0  ,0    ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,1  ,\n";
if($debug > 0){ print OUTPUT "//	064 065 066 067 068 069 070 071   072 073 074 075 076 077 078 079 \n"; }
if($debug > 0){ print OUTPUT "//	@   A   B   C   D   E   F   G     H   I   J   K   L   M   N   O   \n"; }
print OUTPUT "	0  ,1  ,1  ,1  ,1  ,1  ,1  ,1    ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,\n";
if($debug > 0){ print OUTPUT "//	080 081 082 083 084 085 086 087   088 089 090 091 092 093 094 095 \n"; }
if($debug > 0){ print OUTPUT "//	P   Q   R   S   T   U   V   W     X   Y   Z   [   \   ]   ^   _   \n"; }
print OUTPUT "	1  ,1  ,1  ,1  ,1  ,1  ,1  ,1    ,1  ,1  ,1  ,0  ,0  ,0  ,0  ,0  ,\n";
if($debug > 0){ print OUTPUT "//	096 097 098 099 100 101 102 103   104 105 106 107 108 109 110 111 \n"; }
if($debug > 0){ print OUTPUT "//	`   a   b   c   d   e   f   g     h   i   j   k   l   m   n   o   \n"; }
print OUTPUT "	1  ,1  ,1  ,1  ,1  ,1  ,1  ,1    ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,\n";
if($debug > 0){ print OUTPUT "//	112 113 114 115 116 117 118 119   120 121 122 123 124 125 126 127 \n"; }
if($debug > 0){ print OUTPUT "//	p   q   r   s   t   u   v   w     x   y   z   {   |   }   ~      \n"; }
print OUTPUT "	1  ,1  ,1  ,1  ,1  ,1  ,1  ,1    ,1  ,1  ,1  ,0  ,0  ,0  ,1  ,1  ,\n";
if($debug > 0){ print OUTPUT "//	128 129 130 131 132 133 134 135   136 137 138 139 140 141 142 143 \n"; }
print OUTPUT "	1  ,1  ,1  ,1  ,1  ,1  ,1  ,1    ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,\n";
if($debug > 0){ print OUTPUT "//	144 145 146 147 148 149 150 151   152 153 154 155 156 157 158 159 \n"; }
print OUTPUT "	1  ,1  ,1  ,1  ,1  ,1  ,1  ,1    ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,\n";
if($debug > 0){ print OUTPUT "//	160 161 162 163 164 165 166 167   168 169 170 171 172 173 174 175 \n"; }
print OUTPUT "	1  ,1  ,1  ,1  ,1  ,1  ,1  ,1    ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,\n";
if($debug > 0){ print OUTPUT "//	176 177 178 179 180 181 182 183   184 185 186 187 188 189 190 191 \n"; }
print OUTPUT "	1  ,1  ,1  ,1  ,1  ,1  ,1  ,1    ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,\n";
if($debug > 0){ print OUTPUT "//	192 193 194 195 196 197 198 199   200 201 202 203 204 205 206 207 \n"; }
print OUTPUT "	1  ,1  ,1  ,1  ,1  ,1  ,1  ,1    ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,\n";
if($debug > 0){ print OUTPUT "//	208 209 210 211 212 213 214 215   216 217 218 219 220 221 222 223 \n"; }
print OUTPUT "	1  ,1  ,1  ,1  ,1  ,1  ,1  ,1    ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,\n";
if($debug > 0){ print OUTPUT "//	224 225 226 227 228 229 230 231   232 233 234 235 236 237 238 239 \n"; }
print OUTPUT "	1  ,1  ,1  ,1  ,1  ,1  ,1  ,1    ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,\n";
if($debug > 0){ print OUTPUT "//	240 241 242 243 244 245 246 247   248 249 250 251 252 253 254 255 \n"; }
print OUTPUT "	1  ,1  ,1  ,1  ,1  ,1  ,1  ,1    ,1  ,1  ,1  ,1  ,1  ,1  ,1  ,1\n";
print OUTPUT "};\n";

print OUTPUT "#undef p\n";
print OUTPUT "#undef d\n";
print OUTPUT "#undef g\n";
print OUTPUT "#undef x\n";
print OUTPUT "#undef z\n";
print OUTPUT "#undef r\n";
print OUTPUT "#undef i\n";
print OUTPUT "#undef j\n";
print OUTPUT "#undef k\n";
print OUTPUT "#undef f\n";

print OUTPUT "\n";
print OUTPUT "static double score_for_ngram(DetectorDescriptor * d,const unsigned char * ngram)\n";
print OUTPUT "{\n";
print OUTPUT "		const unsigned char * p = ngram;\n";
print OUTPUT "		int xhash = *p * 31;\n";
print OUTPUT "		p++;\n";
print OUTPUT "		xhash += *p * 17;\n";
print OUTPUT "		p++;\n";
print OUTPUT "		if(*p)\n";
print OUTPUT "		{\n";
print OUTPUT "			xhash += *p * 11;\n";
print OUTPUT "			p++;\n";
print OUTPUT "			if(*p)\n";
print OUTPUT "			{\n";
print OUTPUT "				xhash += *p * 3;\n";
print OUTPUT "			}\n";
print OUTPUT "		}\n";
print OUTPUT "		DetectorNGram * g = d->ngram_hash[xhash % 256];\n";
print OUTPUT "		while(g->szNGram)\n";
print OUTPUT "		{\n";
print OUTPUT "			if(strcmp((const char *)ngram,(const char *)g->szNGram) == 0){ /*printf(\"GOT NGRAM %s SCORE %f\\n\",ngram,g->dScore);*/ return g->dScore; }\n";
print OUTPUT "			g++;\n";
print OUTPUT "		}\n";
print OUTPUT "		return 0.0;\n";
print OUTPUT "}\n";
print OUTPUT "\n";

print OUTPUT "\n";
print OUTPUT "static double compute_descriptor_score(const unsigned char * data,DetectorDescriptor * d)\n";
print OUTPUT "{\n";
print OUTPUT "	double dRet = 0.0;\n";
print OUTPUT "	//unsigned char x[256];\n";
print OUTPUT "	//memset(x,0,256)\n";
print OUTPUT "	const unsigned char * p = data;\n";
print OUTPUT "	while(*p)\n";
print OUTPUT "	{\n";
print OUTPUT "		unsigned char z = (unsigned char)tolower((char)*p);\n";
print OUTPUT "		if(valid_char_jump_table[z])\n";
print OUTPUT "			dRet += d->single_char_data[z];\n";
print OUTPUT "		p++;\n";
print OUTPUT "	}\n";

print OUTPUT "	//unsigned int x[256];\n";
print OUTPUT "	//int i;\n";
print OUTPUT "	//for(i=0;i<256;i++)x[i] = 0;\n";
print OUTPUT "	//unsigned int total = 0;\n";
print OUTPUT "	//while(*p)\n";
print OUTPUT "	//{\n";
print OUTPUT "	//	unsigned char z = (unsigned char)tolower((char)*p);\n";
print OUTPUT "	//	if(valid_char_jump_table[z])\n";
print OUTPUT "	//	{\n";
print OUTPUT "	//		x[z]++;\n";
print OUTPUT "	//		total++;\n";
print OUTPUT "	//	}\n";
print OUTPUT "	//	p++;\n";
print OUTPUT "	//}\n";
print OUTPUT "	//for(i=0;i<256;i++)\n";
print OUTPUT "	//{\n";
print OUTPUT "	//	if(valid_char_jump_table[i])\n";
print OUTPUT "	//	{\n";
print OUTPUT "	//		double dPercent = ((double)x[i]) / ((double)total);\n";
print OUTPUT "	//		double dDiff = dPercent - d->single_char_data[i];\n";
print OUTPUT "	//		if(dDiff < 0.0)dDiff = -dDiff;\n";
print OUTPUT "	//		if(dPercent > d->single_char_data[i])dDiff *= d->single_char_data[i] == 0.0 ? 3.0 : 1.5;\n";
print OUTPUT "	//		if(i > 127)dDiff *= 1.5;\n";
print OUTPUT "	//		if(i > 192)dDiff *= 1.5;\n";
print OUTPUT "	//		dRet -= ((double)total) * dDiff;\n";
print OUTPUT "	//		//printf(\"CHAR %d FILE %f REF %f DIFF %f SCORE %f\\n\",i,dPercent,d->single_char_data[i],dDiff,((double)total) * dDiff);\n";
print OUTPUT "	//	}\n";
print OUTPUT "	//}\n";

print OUTPUT "	// now by hash...this is hard\n";
print OUTPUT "	p = data;\n";
print OUTPUT "	unsigned char buffer[1024]; // we handle words up to 1024 chars\n";
print OUTPUT "	buffer[0] = ' '; // we always start with a space\n";
print OUTPUT "	while(*p)\n";
print OUTPUT "	{\n";
print OUTPUT "		while(*p && !valid_char_jump_table[*p])p++;\n";
print OUTPUT "		int idx = 1;\n";
print OUTPUT "		while(valid_char_jump_table[*p] && (idx < 1022))\n";
print OUTPUT "		{\n";
print OUTPUT "			buffer[idx] = (unsigned char)tolower((char)*p);\n";
print OUTPUT "			p++;\n";
print OUTPUT "			idx++;\n";
print OUTPUT "		}\n";
print OUTPUT "		buffer[idx] = ' '; // and we always end with a space\n";
print OUTPUT "		idx++;\n";
print OUTPUT "		buffer[idx] = 0; // and we null terminate\n";
print OUTPUT "		// now run through the buffer checking the ngrams\n";
print OUTPUT "		unsigned char * r = buffer + 2;\n";
print OUTPUT "		while(*r)\n";
print OUTPUT "		{\n";
print OUTPUT "			unsigned char save = *r;\n";
print OUTPUT "			*r = 0;\n";
print OUTPUT "			// 4 letters ngram\n";
print OUTPUT "			unsigned char * begin = r-4;\n";
print OUTPUT "			if(begin >= buffer)\n";
print OUTPUT "				dRet += score_for_ngram(d,begin);\n";
print OUTPUT "			// 3 letters ngram\n";
print OUTPUT "			begin++;\n";
print OUTPUT "			if(begin >= buffer)\n";
print OUTPUT "				dRet += score_for_ngram(d,begin);\n";
print OUTPUT "			// 2 letters ngram\n";
print OUTPUT "			begin++;\n";
print OUTPUT "			dRet += score_for_ngram(d,begin);\n";
print OUTPUT "			*r = save;\n";
print OUTPUT "			r++;\n";
print OUTPUT "		}\n";
print OUTPUT "	}\n";
print OUTPUT "	return dRet;\n";
print OUTPUT "}\n";
print OUTPUT "\n";


print OUTPUT "#define NUM_DESCRIPTORS ".$descriptorCnt."\n";

print OUTPUT "\n";
print OUTPUT "static DetectorDescriptor * all_descriptors[NUM_DESCRIPTORS]=\n";
print OUTPUT "{\n";
for($i=0;$i<$descriptorCnt;$i++)
{
	if(($i % 10) == 0){ print OUTPUT "	"; }
	print OUTPUT "&".$descriptors[$i];
	if($i < ($descriptorCnt - 1)){ print OUTPUT ","; }
	if(($i % 10) == 9){ print OUTPUT "\n"; }
}
print OUTPUT "};\n";
print OUTPUT "\n";


print OUTPUT "\n";
print OUTPUT "#define NEED_ONE_CHAR p++; if(*p < 0x80){ score--; return score; /* error */ }\n";
print OUTPUT "\n";
print OUTPUT "\n";
print OUTPUT "static int utf8score(const unsigned char * p)\n";
print OUTPUT "{\n";
print OUTPUT "	int score = 0;\n";
print OUTPUT "	int highchars = 0;\n";
print OUTPUT "	while(*p)\n";
print OUTPUT "	{\n";
print OUTPUT "		if(*p < 0x80)\n";
print OUTPUT "		{\n";
print OUTPUT "			p++;\n";
print OUTPUT "		} else if((*p & 0xe0) == 0xc0)\n";
print OUTPUT "		{\n";
print OUTPUT "			// 2 bytes encoding\n";
print OUTPUT "			NEED_ONE_CHAR\n";
print OUTPUT "			p++;\n";
print OUTPUT "			highchars++;\n";
print OUTPUT "		} else if((*p & 0xf0) == 0xe0)\n";
print OUTPUT "		{\n";
print OUTPUT "			// 3 bytes encoding\n";
print OUTPUT "			NEED_ONE_CHAR\n";
print OUTPUT "			NEED_ONE_CHAR\n";
print OUTPUT "			p++;\n";
print OUTPUT "			highchars++;\n";
print OUTPUT "		} else if((*p & 0xf8) == 0xf0)\n";
print OUTPUT "		{\n";
print OUTPUT "			// 4 bytes encoding\n";
print OUTPUT "			NEED_ONE_CHAR\n";
print OUTPUT "			NEED_ONE_CHAR\n";
print OUTPUT "			NEED_ONE_CHAR\n";
print OUTPUT "			p++;\n";
print OUTPUT "			highchars++;\n";
print OUTPUT "		} else {\n";
if($debug > 0)
{
	print OUTPUT "			printf(\"utf8 error char %c (%d)\\n\",*p,*p);\n";
}
print OUTPUT "			score--;\n";
print OUTPUT "			if(score < -50)return score;\n";
print OUTPUT "			p++;\n";
print OUTPUT "		}\n";
print OUTPUT "	}\n";
print OUTPUT "	if(score >= 0)\n";
print OUTPUT "	{\n";
print OUTPUT "		score = highchars / 10;\n";
print OUTPUT "		if(score > 50)score = 50;\n";
print OUTPUT "	}\n";
print OUTPUT "	return score;\n";
print OUTPUT "}\n";
print OUTPUT "\n";


print OUTPUT "\n";
print OUTPUT "static const char * unknown_string = \"?\";\n";
print OUTPUT "\n";
print OUTPUT "void detect_language_and_encoding(const char * data,LanguageAndEncodingResult * retBuffer,int iFlags = 0)\n";
print OUTPUT "{\n";
print OUTPUT "	int i;\n";
print OUTPUT "	DetectorDescriptor * match[DLE_NUM_BEST_MATCHES];\n";
print OUTPUT "	for(i=0;i<DLE_NUM_BEST_MATCHES;i++)\n";
print OUTPUT "	{\n";
print OUTPUT "		retBuffer->match[i].szLanguage = 0;\n";
print OUTPUT "		retBuffer->match[i].szEncoding = 0;\n";
print OUTPUT "		retBuffer->match[i].dScore = -99999999999.9;\n";
print OUTPUT "		match[i] = 0;\n";
print OUTPUT "	}\n";
print OUTPUT "	retBuffer->dAccuracy = 0.0;\n";
print OUTPUT "	\n";
print OUTPUT "	int utf8 = utf8score((const unsigned char *)data);\n";
if($debug > 0)
{
	print OUTPUT "	printf(\"UTF8 score: %d\\n\",utf8);\n";
}
print OUTPUT "	i=0;\n";
print OUTPUT "	while(i<NUM_DESCRIPTORS)\n";
print OUTPUT "	{\n";
print OUTPUT "		bool bIsUtf8 = ((strcmp(all_descriptors[i]->szEncoding,\"utf8\") == 0) || (strcmp(all_descriptors[i]->szEncoding,\"utf-8\") == 0));\n";
print OUTPUT "		if((!bIsUtf8) || (!(iFlags & DLE_STRICT_UTF8_CHECKING)))\n";
print OUTPUT "		{\n";
print OUTPUT "			double dThis = compute_descriptor_score((const unsigned char *)data,all_descriptors[i]);\n";
if($debug > 0)
{
	print OUTPUT "			double dSave = dThis;\n";
}
print OUTPUT "			if(bIsUtf8)\n";
print OUTPUT "			{\n";
print OUTPUT "				dThis *= 1.0 + (((double)utf8) * 0.01);\n";
print OUTPUT "			} else {\n";
print OUTPUT "				if(utf8 < 0)dThis *= 1.1; // probably it is not utf8...\n";
print OUTPUT "				else if(utf8 > 10)dThis *= 0.95; // might be utf8...privilege it\n";
print OUTPUT "			}\n";
if($debug > 0)
{
	print OUTPUT "			printf(\"Descriptor %s-%s: %f (orig %f)\\n\",all_descriptors[i]->szLanguage,all_descriptors[i]->szEncoding,dThis,dSave);\n";
}

print OUTPUT "			// update best matches\n";
print OUTPUT "			for(int j=0;j<DLE_NUM_BEST_MATCHES;j++)\n";
print OUTPUT "			{\n";
print OUTPUT "				if(dThis > retBuffer->match[j].dScore)\n";
print OUTPUT "				{\n";
print OUTPUT "					for(int k=DLE_NUM_BEST_MATCHES-1;k>j;k--)\n";
print OUTPUT "					{\n";
print OUTPUT "						retBuffer->match[k].dScore = retBuffer->match[k-1].dScore;\n";
print OUTPUT "						match[k] = match[k-1];\n";
print OUTPUT "					}\n";
print OUTPUT "					retBuffer->match[j].dScore = dThis;\n";
print OUTPUT "					match[j] = all_descriptors[i];\n";
print OUTPUT "					j = DLE_NUM_BEST_MATCHES; // stop looping\n";
print OUTPUT "				}\n";
print OUTPUT "			}\n";
print OUTPUT "		}\n";
print OUTPUT "		i++;\n";
print OUTPUT "	}\n";
print OUTPUT "	// compute accuracy and adjust language and encoding names\n";
print OUTPUT "	double dScoreDiff = 0.0;\n";
print OUTPUT "	double dTheoricMax = 0.0;\n";
print OUTPUT "	for(i=0;i<DLE_NUM_BEST_MATCHES;i++)\n";
print OUTPUT "	{\n";
print OUTPUT "		if(i > 0)\n";
print OUTPUT "		{\n";
print OUTPUT "			dScoreDiff += (retBuffer->match[0].dScore - retBuffer->match[i].dScore) / ((double)i);\n";
print OUTPUT "			dTheoricMax += retBuffer->match[0].dScore / ((double)i);\n";
print OUTPUT "		}\n";
print OUTPUT "		retBuffer->match[i].szLanguage = match[i] ? match[i]->szLanguage : unknown_string;\n";
print OUTPUT "		retBuffer->match[i].szEncoding = match[i] ? match[i]->szEncoding : unknown_string;\n";
print OUTPUT "	}\n";
print OUTPUT "	if(dTheoricMax > 0.0001)retBuffer->dAccuracy = 100.0 * dScoreDiff / dTheoricMax;\n";
print OUTPUT "	else retBuffer->dAccuracy = 0.0;\n";
print OUTPUT "}\n";
print OUTPUT "\n";

print OUTPUT "/*\n";
print OUTPUT " * this file can be compiled also as a standalone app for testing\n";
print OUTPUT "int main(int argc,char ** argv)\n";
print OUTPUT "{\n";
print OUTPUT "	FILE * f = fopen(argv[1],\"r\");\n";
print OUTPUT "	if(!f){ printf(\"Can't open file\\n\"); return -1; };\n";
print OUTPUT "	char buffer[4096];\n";
print OUTPUT "	memset(buffer,0,4096);\n";
print OUTPUT "	fread(buffer,1,4095,f);\n";
print OUTPUT "	fclose(f);\n";
print OUTPUT "	LanguageAndEncodingResult r;\n";
print OUTPUT "	detect_language_and_encoding(buffer,&r,0);\n";
print OUTPUT "	for(int i=0;i<DLE_NUM_BEST_MATCHES;i++)\n";
print OUTPUT "		printf(\"LANGUAGE %s, ENCODING %s, SCORE: %f\\n\",r.match[i].szLanguage,r.match[i].szEncoding,r.match[i].dScore);\n";
print OUTPUT "	printf(\"Accuracy: %f\\n\",r.dAccuracy);\n";
print OUTPUT "	return 0;\n";
print OUTPUT "}\n";
print OUTPUT "*/\n";
print OUTPUT "\n";

close(OUTPUT);
