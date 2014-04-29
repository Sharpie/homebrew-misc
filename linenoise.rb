require 'formula'

class Linenoise < Formula
  homepage 'https://github.com/antirez/linenoise'
  head 'https://github.com/antirez/linenoise.git'
  patch :DATA

  def install
    system 'make'
    lib.install 'liblinenoise.a'
    include.install 'linenoise.h'
  end
end

__END__
Add static library to linenoise build.

diff --git a/Makefile b/Makefile
index a285410..12cf058 100644
--- a/Makefile
+++ b/Makefile
@@ -1,7 +1,15 @@
+all: liblinenoise.a linenoise_example
+
+liblinenoise.a: linenoise.o
+	$(AR) -rc liblinenoise.a linenoise.o
+
+%.o: %.c
+	$(CC) $(CFLAGS) -o $@ -c $<
+
 linenoise_example: linenoise.h linenoise.c
 
 linenoise_example: linenoise.c example.c
 	$(CC) -Wall -W -Os -g -o linenoise_example linenoise.c example.c
 
 clean:
-	rm -f linenoise_example
+	rm -f linenoise_example linenoise.o liblinenoise.a
