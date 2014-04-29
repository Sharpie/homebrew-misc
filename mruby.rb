require 'formula'

class Mruby < Formula
  homepage 'http://www.mruby.org'
  url 'https://github.com/mruby/mruby/archive/1.0.0.tar.gz'
  sha1 '6d4cb1b3594b1c609cc3e39d458d2ff27e4f9b4d'

  head 'https://github.com/mruby/mruby.git'

  patch :DATA

  depends_on 'bison' => :build

  depends_on 'linenoise'

  def install
    system 'make'

    bin.install Dir['bin/*']
    include.install Dir['include/*']
    lib.install Dir['build/host/lib/*']
  end

  test do
    system '#{bin}/mruby', '-e', 'true'
  end
end

__END__
Switch default compiler to Clang and add linenoise library to mirb.

diff --git a/build_config.rb b/build_config.rb
index 7952514..044eebf 100644
--- a/build_config.rb
+++ b/build_config.rb
@@ -5,7 +5,7 @@ MRuby::Build.new do |conf|
   if ENV['VisualStudioVersion'] || ENV['VSINSTALLDIR']
     toolchain :visualcpp
   else
-    toolchain :gcc
+    toolchain :clang
   end
 
   enable_debug
diff --git a/mrbgems/mruby-bin-mirb/mrbgem.rake b/mrbgems/mruby-bin-mirb/mrbgem.rake
index ffef67a..684ad09 100644
--- a/mrbgems/mruby-bin-mirb/mrbgem.rake
+++ b/mrbgems/mruby-bin-mirb/mrbgem.rake
@@ -3,7 +3,12 @@ MRuby::Gem::Specification.new('mruby-bin-mirb') do |spec|
   spec.author  = 'mruby developers'
   spec.summary = 'mirb command'
 
-  spec.linker.libraries << 'readline' if spec.cc.defines.include? "ENABLE_READLINE"
+  linenoise_root = `brew --prefix linenoise`
+
+  spec.cc.defines << 'ENABLE_LINENOISE'
+  spec.cc.include_paths << File.join(linenoise_root, 'include')
+  spec.linker.library_paths << File.join(linenoise_root, 'lib')
+  spec.linker.libraries << 'linenoise'
 
   spec.bins = %w(mirb)
 end
