AC_INIT(bootstrap)

AC_PROG_CC

# Check for ssl library
AC_CHECK_LIB([ssl], [SSL_library_init],,[AC_MSG_ERROR([ssl library missing])])
AC_CHECK_LIB([crypto], [CRYPTO_num_locks],,[AC_MSG_ERROR([crypto library missing])])

#Check for readline library
AC_CHECK_LIB([readline], [readline],,[AC_MSG_ERROR([readline library is missing])])
AC_CHECK_LIB([mpc], [mpc_log10],,[AC_MSG_ERROR([mpc library is missing])])

#Check for libarchive
PKG_CHECK_MODULES([ARCHIVE],[libarchive])

#AC_CONFIG_HEADERS([config.h])

AC_OUTPUT
