--- CHANGES	1998/02/10 21:32:04	1.3
+++ CHANGES	1998/02/10 21:41:09
@@ -26,6 +26,7 @@
 	When calculating junk inside subs, divide by refcount.
 0.84:
 	Indented output.
+
 0.85:
 	By Gisle Aas: format SvPVX, print magic (but not unrefcounted mg_obj);
 	A lot of new fields stolen from sv_dump();
@@ -37,3 +38,5 @@
 	   - Don't print IV for hashes as KEY is the same field
 	   - Tag GvSTASH as "GvSTASH" in order to not confuse it with
 	     the other STASH field, e.g.  Dump(bless \*foo, "bar")
+
+0.8601: hook into Apache/mod_perl environment instead of stderr [dougm]
--- MANIFEST	1998/02/10 21:32:04	1.3
+++ MANIFEST	1998/02/10 21:32:27
@@ -5,3 +5,4 @@
 Makefile.PL
 test.pl
 README
+Apache.pat
--- Makefile.PL	1998/02/10 21:32:04	1.3
+++ Makefile.PL	1998/02/10 21:32:27
@@ -1,11 +1,39 @@
 use ExtUtils::MakeMaker;
 # See lib/ExtUtils/MakeMaker.pm for details of how to influence
 # the contents of the Makefile that is written.
+
+my $inc = "";
+my $define = "";
+my $mod_perl = 1;
+
+if ($mod_perl) {
+    eval {
+	use mod_perl 1.07_03;
+	require Apache::src;
+	my $src = Apache::src->new;
+
+	unless (-d $src->dir) {
+	    for my $path ($src->find) {
+		my $ans = prompt("Configure with $path ?", "y");
+		next unless $ans =~ /^y$/i;
+		$src->dir($path);
+		last;
+	    }
+	}
+
+	$inc = $src->inc if -d $src->dir;
+    };
+
+    die "Please edit Makefile.PL's \$inc\n" unless $inc;
+
+    $define = "-DMOD_PERL";
+}
+
 WriteMakefile(
-    'NAME'	=> 'Devel::Peek',
+    'NAME'	=> 'Apache::Peek',
     'VERSION_FROM'	=> 'Peek.pm',
     'LIBS'	=> [''],   # e.g., '-lm' 
-    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
-    'INC'	=> '',     # e.g., '-I/usr/include/other' 
+    'DEFINE'	=> $define,     # e.g., '-DHAVE_SOMETHING' 
+    'INC'	=> $inc,     # e.g., '-I/usr/include/other' 
     'dist' => {COMPRESS=>'gzip -9f', SUFFIX=>'gz'},
 );
--- Peek.pm	1998/02/10 21:32:04	1.3
+++ Peek.pm	1998/02/10 21:32:59
@@ -1,12 +1,12 @@
-package Devel::Peek;
+package Apache::Peek;
 
 =head1 NAME
 
-Devel::Peek - A data debugging tool for the XS programmer
+Apache::Peek - A data debugging tool for the XS programmer
 
 =head1 SYNOPSIS
 
-        use Devel::Peek;
+        use Apache::Peek;
         Dump( $a );
         Dump( $a, 5 );
         DumpArray( 5, $a, $b, ... );
@@ -14,7 +14,7 @@
 
 =head1 DESCRIPTION
 
-Devel::Peek contains functions which allows raw Perl datatypes to be
+Apache::Peek contains functions which allows raw Perl datatypes to be
 manipulated from a Perl script.  This is used by those who do XS programming
 to check that the data they are sending from C to Perl looks as they think
 it should look.  The trick, then, is to know what the raw datatype is
@@ -25,11 +25,11 @@
 to the casual reader.  The reader is expected to understand the material in
 the first few sections of L<perlguts>.
 
-Devel::Peek supplies a C<Dump()> function which can dump a raw Perl
+Apache::Peek supplies a C<Dump()> function which can dump a raw Perl
 datatype, and C<mstat("marker")> function to report on memory usage
 (if perl is compiled with corresponding option).  The function
 DeadCode() provides statistics on the data "frozen" into inactive
-C<CV>.  Devel::Peek also supplies C<SvREFCNT()>, C<SvREFCNT_inc()>, and
+C<CV>.  Apache::Peek also supplies C<SvREFCNT()>, C<SvREFCNT_inc()>, and
 C<SvREFCNT_dec()> which can query, increment, and decrement reference
 counts on SVs.  This document will take a passive, and safe, approach
 to data debugging and for that it will describe only the C<Dump()>
@@ -59,7 +59,7 @@
 
 Let's begin by looking a simple scalar which is holding a string.
 
-        use Devel::Peek 'Dump';
+        use Apache::Peek 'Dump';
         $a = "hello";
         Dump $a;
 
@@ -88,7 +88,7 @@
 
 If the scalar contains a number the raw SV will be leaner.
 
-        use Devel::Peek 'Dump';
+        use Apache::Peek 'Dump';
         $a = 42;
         Dump $a;
 
@@ -108,7 +108,7 @@
 
 If the scalar from the previous example had an extra reference:
 
-        use Devel::Peek 'Dump';
+        use Apache::Peek 'Dump';
         $a = 42;
         $b = \$a;
         Dump $a;
@@ -128,7 +128,7 @@
 
 This shows what a reference looks like when it references a simple scalar.
 
-        use Devel::Peek 'Dump';
+        use Apache::Peek 'Dump';
         $a = 42;
         $b = \$a;
         Dump $b;
@@ -159,7 +159,7 @@
 
 This shows what a reference to an array looks like.
 
-        use Devel::Peek 'Dump';
+        use Apache::Peek 'Dump';
         $a = [42];
         Dump $a;
 
@@ -194,7 +194,7 @@
 If C<$a> pointed to an array of two elements then we would see the
 following.
 
-        use Devel::Peek 'Dump';
+        use Apache::Peek 'Dump';
         $a = [42,24];
         Dump $a;
 
@@ -234,7 +234,7 @@
 
 The following shows the raw form of a reference to a hash.
 
-        use Devel::Peek 'Dump';
+        use Apache::Peek 'Dump';
         $a = {hello=>42};
         Dump $a;
 
@@ -269,14 +269,14 @@
 toplevel array or hash.  This number can be increased by supplying a
 second argument to the function.
 
-        use Devel::Peek 'Dump';
+        use Apache::Peek 'Dump';
         $a = [10,11,12,13,14];
         Dump $a;
 
 Notice that C<Dump()> prints only elements 10 through 13 in the above code.
 The following code will print all of the elements.
 
-        use Devel::Peek 'Dump';
+        use Apache::Peek 'Dump';
         $a = [10,11,12,13,14];
         Dump $a, 5;
 
@@ -407,9 +407,9 @@
 );
 %EXPORT_TAGS = ('ALL' => \@EXPORT_OK);
 
-$VERSION = $VERSION = 0.86;
+$VERSION = $VERSION = 0.8601;
 
-bootstrap Devel::Peek;
+bootstrap Apache::Peek;
 
 # Preloaded methods go here.
 
--- Peek.xs	1998/02/10 21:32:04	1.3
+++ Peek.xs	1998/02/10 21:38:25
@@ -1,6 +1,25 @@
+#ifdef MOD_PERL
+#include "modules/perl/mod_perl.h"
+
+#undef PerlIO
+#undef PerlIO_printf
+#undef PerlIO_vprintf
+#undef PerlIO_stderr
+#undef PerlIO_putc
+#undef PerlIO_puts
+
+#define PerlIO request_rec
+#define PerlIO_printf rprintf
+#define PerlIO_vprintf(r,fmt,vlist) \
+ vbprintf(r->connection->client, fmt, vlist)
+#define PerlIO_stderr() perl_request_rec(NULL)
+#define PerlIO_putc(r,c) rputc(c,r)
+#define PerlIO_puts(r,s) rputs(s,r)
+#else
 #include "EXTERN.h"
 #include "perl.h"
 #include "XSUB.h"
+#endif
 
 #define LANGDUMPMAX 4
 /* #define fprintf		 */
@@ -673,10 +692,10 @@
 	PerlIO_printf(PerlIO_stderr(), "%s: perl not compiled with DEBUGGING_MSTATS\n",str);
 #endif
 
-MODULE = Devel::Peek		PACKAGE = Devel::Peek
+MODULE = Apache::Peek		PACKAGE = Apache::Peek
 
 void
-mstat(str="Devel::Peek::mstat: ")
+mstat(str="Apache::Peek::mstat: ")
 char *str
 
 void
--- README	1998/02/10 21:32:04	1.3
+++ README	1998/02/10 21:34:05
@@ -1,3 +1,12 @@
+Apache::Peek is Ilya Zakharevich's Devel::Peek module that sends
+output to the browser instead of stderr.
+
+see Apache.pat for the diffs between Apache::Peek and Devel::Peek 0.86
+
+-Doug MacEachern
+
+------------------------------------------------------------------------------
+
 LEGALESE
 ~~~~~~~~
      Copyright (c) 1995 Ilya Zakharevich. All rights reserved.
