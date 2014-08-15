
namespace :ruby do

  desc 'downloading ruby'
  task :download do
    puts "downloading ruby"
    download_file($RUBY_DOWNLOAD, "target/source/ruby.tar.gz")
  end

  desc 'uncompress ruby'
  task :uncompress do
    puts "uncompress ruby"
    output = %x[tar zxvf target/source/ruby.tar.gz -C target/ruby_source ; echo $?]
    result = output.lines.last
    if result.to_s.strip != "0"
      puts "failed to uncompress ruby"
      puts output
      abort
    end
  end

  desc "erasing output ruby directory"
  task :erase do
    delete_directory("#{$current_dir}/target/ruby")
  end

  desc "configure ruby, using $RUBY_CONFIG_OPTS to change configuration options"
  task :configure do
    puts "configuring ruby"
    output = %x[cd target/ruby_source/#{$RUBY_DIR} ; ./configure #{ENV['RUBY_CONFIG_OPTS']} -enable-shared -prefix #{$current_dir}/target/ruby ; echo $? ]
    result = output.lines.last
    if result.strip != "0"
      puts output
      puts "error configuring ruby"
      abort
    end
  end

  desc "compile ruby"
  task :compile do
    puts "compiling ruby"
    output = %x[cd target/ruby_source/#{$RUBY_DIR} ; make install ; echo $? ]
    result = output.lines.last
    if result.strip != "0"
      puts output
      puts "error compiling ruby"
      abort
    end
  end

  desc "all ruby tasks"
  task :all do
    Rake::Task["ruby:download"].invoke
    Rake::Task["ruby:uncompress"].invoke
    Rake::Task["ruby:configure"].invoke
    Rake::Task["ruby:compile"].invoke
  end

end
