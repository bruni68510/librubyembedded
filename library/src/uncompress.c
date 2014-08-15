#include <stdio.h>
#include <archive.h>
#include <archive_entry.h>
#include "error.h"

extern const unsigned char binary_data[];
extern unsigned long binary_size;


void emd_ruby_uncompress_cleanup(struct archive *input_archive, struct archive *output_archive)
{
  archive_read_close(input_archive);
  archive_read_free(input_archive);
  archive_write_close(output_archive);
  archive_write_free(output_archive);
}

static int emb_ruby_uncompress_copy_data(struct archive *ar, struct archive *aw)
{
  int r;
  const void *buff;
  size_t size;
  off_t offset;

  for (;;) {
    r = archive_read_data_block(ar, &buff, &size, &offset);
    if (r == ARCHIVE_EOF)
      return (ARCHIVE_OK);
    if (r < ARCHIVE_OK)
      return (r);
    r = archive_write_data_block(aw, buff, size, offset);
    if (r < ARCHIVE_OK) {
      fprintf(stderr, "%s\n", archive_error_string(aw));
      return (r);
    }
  }
}

emb_ruby_error_t emb_ruby_uncompress(){

  struct archive *input_archive;
  struct archive *output_archive;
  struct archive_entry* entry;

  int result;
  int output_flags;

  unsigned char buff[2048];
  int buffsize = 2048;
  int size;

  output_flags = ARCHIVE_EXTRACT_TIME;
  output_flags |= ARCHIVE_EXTRACT_PERM;
  output_flags |= ARCHIVE_EXTRACT_ACL;
  output_flags |= ARCHIVE_EXTRACT_FFLAGS;

  input_archive = archive_read_new();
  output_archive = archive_write_disk_new();

  archive_read_support_filter_gzip(input_archive);
  archive_read_support_format_tar(input_archive);
  //archive_read_support_format_raw(a);

  archive_write_disk_set_options(output_archive, output_flags);
  archive_write_disk_set_standard_lookup(output_archive);

  result = archive_read_open_memory(input_archive, (void*)binary_data, binary_size);

  if (result != ARCHIVE_OK) {
    fprintf(stderr, "%s\n", archive_error_string(input_archive));
    return E_UNCOMPRESS_ERROR;
  }


  for (;;) {

    /**
     * Read new header from memory
     */
    result = archive_read_next_header(input_archive, &entry);
    // EOF
    if (result == ARCHIVE_EOF) {
      break;
    }
    // error handling
    if (result != ARCHIVE_OK) {
      fprintf(stderr, "%s\n", archive_error_string(input_archive));
      emd_ruby_uncompress_cleanup(input_archive, output_archive);
      return E_UNCOMPRESS_ERROR;
    }

    /**
     * Write new header into disk
     */
    result = archive_write_header(output_archive, entry);
    // error handling
    if (result != ARCHIVE_OK) {
      fprintf(stderr, "%s\n", archive_error_string(output_archive));
      emd_ruby_uncompress_cleanup(input_archive, output_archive);
      return E_UNCOMPRESS_ERROR;
    }

    /**
     * copy the data
     */
     result = emb_ruby_uncompress_copy_data(input_archive, output_archive);
     if (result != ARCHIVE_OK) {
          fprintf(stderr, "%s\n", archive_error_string(output_archive));
          emd_ruby_uncompress_cleanup(input_archive, output_archive);
          return E_UNCOMPRESS_ERROR;
      }

      /**
       * Write the trailing
       */
       result = archive_write_finish_entry(output_archive);
       if (result != ARCHIVE_OK) {
            fprintf(stderr, "%s\n", archive_error_string(output_archive));
            emd_ruby_uncompress_cleanup(input_archive, output_archive);
            return E_UNCOMPRESS_ERROR;
        }

  }

  emd_ruby_uncompress_cleanup(input_archive, output_archive);

  return E_SUCCESS;

}
