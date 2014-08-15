require 'open-uri'
require 'fileutils'
require 'zlib'
require 'os'
require 'archive/tar/minitar'
require 'colorize'
include Archive::Tar


$RUBY_DOWNLOAD = "http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz"
$RUBY_DIR="ruby-2.1.2"
$current_dir = Dir.pwd

def run_autoconf(directory, file, logfile)
  return %x[cd #{directory}; aclocal; autoconf ; ./configure > /dev/null 2> #{logfile} ; echo $?]
end

def download_file(src, destination)
    File.write(destination, open(src).read)
end

def delete_directory(dir)
  FileUtils.rm_rf("#{$dir}")
end

def tar_gz_directory(dir, destination)
  tgz = Zlib::GzipWriter.new(File.open("#{destination}", 'wb'))
    # Warning: tgz will be closed!
  Minitar.pack("#{dir}", tgz)
end

Dir.glob('rake/*.rake').each { |r| import r }
