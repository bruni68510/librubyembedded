AC_INIT(bootstrap)

AC_PROG_CC

#Check for readline library
AC_CHECK_LIB([readline], [readline],,[AC_MSG_ERROR([readline library is missing])])
AC_CHECK_LIB([mpc], [mpc_log10],,[AC_MSG_ERROR([mpc library is missing])])

#Check for libarchive
PKG_CHECK_MODULES([ARCHIVE],[libarchive])
PKG_CHECK_MODULES([OPENSSL],[openssl, libcrypto])

#AC_CONFIG_HEADERS([config.h])

AC_OUTPUT
