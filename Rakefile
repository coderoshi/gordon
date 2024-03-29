$: << 'lib'
require 'bundler/setup'
require 'rake-pipeline'
require 'pathname'

task :environment do
  Bundler.require(:default, ENV["RACK_ENV"] || :development)
  require 'gordon'
end

namespace :assets do
  task :precompile do
    Rake::Pipeline::Project.new("Assetfile").invoke
  end
end

task :jshint do
  jsfiles = Dir["assets/javascripts/app/**/*.js"]
  result = system "jshint", "--config" , ".jshintrc", *jsfiles
  exit result || 1
end

namespace :db do
  task :migrate => :environment do
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate([Pathname.new('db/migrate')], ENV["VERSION"] ? ENV["VERSION"].to_i : nil) do |migration|
      ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
    end
    Rake::Task['db:schema:dump'].invoke
  end

  task :seed => :migrate do
    load 'db/seed.rb'
  end

  # task :backfill_log_url => :environment do
  #   TestResult.where('log_url IS NULL').each do |result|
  #     puts "Backfilling test result: #{result.id}."
  #     begin
  #       result.log_url = GiddyUp::S3.directories.get(GiddyUp::LogBucket).files.new(:key => "#{result.id}.log").public_url
  #     rescue Excon::Errors::Error => e
  #       puts "  Failed! #{e.message.split(/\n/).first}"
  #     else        
  #       result.save
  #     end
  #   end
  # end

  namespace :schema do
    task :dump => :environment do
      require 'active_record/schema_dumper'
      filename = ENV['SCHEMA'] || "db/schema.rb"
      File.open(filename, "w:utf-8") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end
  end
end
