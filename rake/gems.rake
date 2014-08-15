namespace :gem do

  desc 'installing bundle gem'
  task :install_bundle do
    puts "install gem bundle"
    output = %x[ target/ruby/bin/gem install bundle ; echo $?]
    result = output.lines.last
    if result.to_s.strip != "0"
      puts "failed to install bundle gem"
      puts output
      abort
    end
  end

  desc 'installation of application bundle'
  task :install_app do
    puts "install application gem with bundle"
    output = %x[ target/ruby/bin/bundle install --gemfile app/Gemfile ; echo $?]
    result = output.lines.last
    if result.to_s.strip != "0"
      puts "failed to install bundle gem"
      puts output
      abort
    end
  end
  desc 'all gems tasks'
  task :all do
      Rake::Task["gem:install_bundle"].invoke
      Rake::Task["gem:install_app"].invoke

  end

end
