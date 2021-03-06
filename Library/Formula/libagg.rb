require 'formula'

class Libagg < Formula
  homepage 'http://www.antigrain.com'
  url 'http://www.antigrain.com/agg-2.5.tar.gz'
  sha1 '08f23da64da40b90184a0414369f450115cdb328'

  option 'with-freetype', 'Build with FreeType support'

  depends_on :automake
  depends_on 'pkg-config' => :build
  depends_on 'sdl'
  depends_on :freetype => :optional if build.include? "with-freetype"
  depends_on :libtool unless MacOS.version >= :mountain_lion

  fails_with :clang do
    build 421
    cause <<-EOS.undent
      AGG tries to return a const reference as a non-const reference, which is
      rejected by clang 3.1 but accepted by gcc
    EOS
  end

  def install
    # AM_C_PROTOTYPES was removed in automake 1.12, as it's only needed for
    # pre-ANSI compilers
    inreplace 'configure.in', 'AM_C_PROTOTYPES', ''

    # No configure script. We need to run autoreconf, and aclocal and automake
    # need some direction.
    ENV['ACLOCAL'] = "aclocal -I#{HOMEBREW_PREFIX}/share/aclocal" # To find SDL m4 files
    # This part snatched from MacPorts
    ENV['AUTOMAKE'] = "automake --foreign --add-missing --ignore-deps"
    system "autoreconf -fi"

    system "./configure",
           "--disable-debug",
           "--disable-dependency-tracking",
           "--prefix=#{prefix}",
           "--disable-platform", # Causes undefined symbols
           "--disable-ctrl",     # No need to run these during configuration
           "--disable-examples",
           "--disable-sdltest"

    system "make install"
  end
end
