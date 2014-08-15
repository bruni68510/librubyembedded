#ifndef emb_ruby_error_h__
#define emb_ruby_error_h__


enum emb_ruby_config_error
{
    E_SUCCESS = 0,
    E_UNCOMPRESS_ERROR,
    E_NO_SUCH_FILE
};

/* type to provide in your API */
typedef enum emb_ruby_config_error emb_ruby_error_t;

/* use this to provide a perror style method to help consumers out */
struct emb_ruby_errordesc {
    int  code;
    char *message;
};


#endif
