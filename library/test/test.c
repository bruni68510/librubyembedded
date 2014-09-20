#include "../src/main.h"

int main(int argc, char **argv) {
  if ( emb_ruby_initialize(argc, argv) == E_SUCCESS)
  {
        emb_ruby_run_file("./test.rb");
  }


  emb_ruby_release();
}
