#ifndef emb_ruby_main_h__
#define emb_ruby_main_h__
#include "error.h"

extern emb_ruby_error_t emb_ruby_initialize(int argc, char **argv);
extern emb_ruby_error_t emb_ruby_run_file(const char* file_name);
extern void emb_ruby_release();

#endif
