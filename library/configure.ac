AC_INIT([librubyembedded], [0.1])

AC_PROG_CC

PKG_CHECK_MODULES([RUBY],[libarchive, ruby-2.1])
#PKG_CHECK_MODULES([ARCHIVE], [libarchive])

#AC_SUBST([RUBY_CFLAGS])
#AC_SUBST([RUBY_LIBS])


AM_INIT_AUTOMAKE(librubyembedded,0.1)
LT_INIT

AC_PROG_RANLIB

AC_CONFIG_FILES([
  src/Makefile
  test/Makefile
  Makefile
])

AC_CONFIG_HEADERS([config.h])

AC_OUTPUT
