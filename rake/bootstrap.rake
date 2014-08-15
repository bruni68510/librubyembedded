
namespace :bootstrap do

  desc 'check for libraries'
  task :check_system do
    result = run_autoconf("bootstrap", "bootstrap.ac", "logfile")
      if result.to_s.strip != "0"
        puts "error in bootstrap checking for libraries"
        puts File.read("bootstrap/logfile")
        abort
      end
      puts "system check ok"
  end

  desc 'create target'
  task :create_target_dir do
    puts "creating target dir"
    Dir.mkdir "target" unless Dir.exists?("target")
    Dir.mkdir "target/source" unless Dir.exists?("target/source")
    Dir.mkdir "target/ruby_source" unless Dir.exists?("target/ruby_source")
    Dir.mkdir "target/ruby" unless Dir.exists?("target/ruby")
    Dir.mkdir "target/library_archive" unless Dir.exists?("target/library_archive")
    Dir.mkdir "target/output" unless Dir.exists?("target/output")
  end


  desc 'all boostrap tasks'
  task :all do
    Rake::Task["bootstrap:check_system"].invoke
    Rake::Task["bootstrap:create_target_dir"].invoke
  end


end
