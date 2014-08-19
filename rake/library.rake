namespace :library do
  desc 'create compress archive for ruby libraries'
  task :archive do
    puts "create compressed archive for ruby libs"
    tar_gz_directory("target/ruby/lib/ruby","target/library_archive/libs.tar.gz")
    %x[cd library/src ; ./create_binary_data.sh ]
  end

  desc 'compile the library'
  task :compile do
    puts "compiling librubyembedded library"
    %x[cd library; make distclean ]
    output = %x[cd library ; ./autogen.sh ; ./configure -prefix=#{$current_dir}/target/librubyembedded; make ; make install ; echo $? ]
    result = output.lines.last
    if result.to_s.strip != "0"
      puts "failed to compile the library ruby"
      puts output
      abort
    end
  end

  desc 'print dependencies'
  task :dep do
    puts "this will show you the dependencies"

    deps = []

    if OS.mac?
      Find.find("target/ruby/lib") do |file|
        if [ ".bundle", ".dylib" ].find_index(File.extname(file))
          %x[otool -L #{file}].each_line do |line|
            deps << line unless line.start_with?("target")
          end
        end
      end
      Find.find("target/librubyembedded/bin") do |file|
        %x[otool -L #{file}].each_line do |line|
          deps << line unless line.start_with?("target")
        end
      end


      deps.uniq.sort.each do |line|
        line = line.strip
        if line.start_with?("/usr/lib") or line.start_with?("/System/Library")
          puts line.green
        else
          filepath = line.split("(compatibility").first.strip
          puts line.red
          filename = File.basename(filepath)
          FileUtils.rm("target/output/#{filename}") if File.exists?("target/output/#{filename}")
          FileUtils.cp(line.split("(compatibility").first.strip, "target/output"
          )
        end
      end

      puts "files copied to target/output directory"

    end

  end

  desc 'all library tasks'
  task :all do
      Rake::Task["library:archive"].invoke
      Rake::Task["library:compile"].invoke
      Rake::Task["library:dep"].invoke
  end

end
