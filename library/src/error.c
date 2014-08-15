#include "error.h"

struct emb_ruby_errordesc errordesc[] = {
    { E_SUCCESS, "No error" },
    { E_UNCOMPRESS_ERROR, "error using libarchive" },
    { E_NO_SUCH_FILE, "error ruby source file not found" },
};
