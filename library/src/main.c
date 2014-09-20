#include <stdio.h>
#include <archive.h>
#include <archive_entry.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <dirent.h>
#include "error.h"
#include "main.h"
#include "uncompress.h"
#include <ruby.h>
 #include <ruby/encoding.h>

char extract_directory[PATH_MAX];

emb_ruby_error_t emb_ruby_initialize(int argc, char **argv)
{

    emb_ruby_error_t result;

    char current_dir[PATH_MAX];

    sprintf(extract_directory,"%s_XXXXXX", P_tmpdir);

    getcwd(current_dir, PATH_MAX);

    mkdtemp(extract_directory);

    printf("Extracting ruby libraries to %s\n", extract_directory);

    chdir(extract_directory);
    result = emb_ruby_uncompress();
    chdir(current_dir);

    if (result != E_SUCCESS)
        return result;

    ruby_sysinit(&argc,&argv);
    RUBY_INIT_STACK;
    ruby_init();
    ruby_init_loadpath();

    return E_SUCCESS;

}

void emb_ruby_check_error(int rb_status)
{
  if (rb_status) {
      //emb_ruby_exception_print(stderr)
      VALUE rbError = rb_funcall(rb_gv_get("$!"), rb_intern("message"), 0);
      fprintf(stderr,"%s\n",StringValuePtr(rbError));

  }
}


emb_ruby_error_t emb_ruby_run_file(const char * file)
{
    //FILE *ruby_file = tmpfile();

    int rb_status;

    rb_encoding *enc, *lenc;

    char string[200];


    rb_eval_string_protect(" $NEW_LOAD_PATH = $LOAD_PATH.clone \n", &rb_status);
    emb_ruby_check_error(rb_status);

    rb_eval_string_protect("$NEW_LOAD_PATH_PREFIX = $LOAD_PATH.first[0..$LOAD_PATH.first.rindex(File.join('target','ruby','lib','ruby'))-1] \n", &rb_status);
    emb_ruby_check_error(rb_status);

    rb_eval_string_protect("$LOAD_PATH.clear \n", &rb_status);
    emb_ruby_check_error(rb_status);

    sprintf(string,"$NEW_LOAD_PATH.each { |path|  $LOAD_PATH << path.gsub($NEW_LOAD_PATH_PREFIX, '%s' + File::SEPARATOR) } \n", extract_directory);
    rb_eval_string_protect(string, &rb_status);
    emb_ruby_check_error(rb_status);

    ruby_script(file);

    rb_enc_find_index("encdb");
    lenc = rb_locale_encoding();
    rb_enc_set_default_external(rb_enc_from_encoding(lenc));
    rb_enc_set_default_internal(rb_enc_from_encoding(lenc));
    rb_load_protect (rb_str_new2(file), 0, &rb_status);
    emb_ruby_check_error(rb_status);



    return E_SUCCESS;
}

int rmdir_r(const char *dirname)
{
    struct dirent **namelist;
    int n = scandir(dirname, &namelist, 0, alphasort);

    if (n < 0) {
        return -1;
    } else {
        for (int i = 0; i < n; ++i) {

            // skip special entries
            if (strcmp(namelist[i]->d_name, ".") == 0 ||
                strcmp(namelist[i]->d_name, "..") == 0) {
                continue;
            }

            // get a path to this file, relative to the current working directory
            char *filename;
            asprintf(&filename, "%s/%s", dirname, namelist[i]->d_name);


            // what sort of file is this anyways?
            struct stat st;
            if (lstat(filename, &st)) {
                return -1;
            }


            if (S_ISDIR(st.st_mode)) {
                // recursively delete directories
                if (rmdir_r(filename)) {
                    return -1;
                }
            } else {
                // unlink files
                if (unlink(filename)) {
                    return -1;
                }
            }

            // clean up our messes
            free(filename);
        }

        // the directory should now be empty, so delete it
        if (rmdir(dirname)) {
            return -1;
        }

        return 0;
    }
}

void emb_ruby_release()
{

    rmdir_r(extract_directory);
    ruby_finalize();
}
