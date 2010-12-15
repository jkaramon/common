require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'

namespace :hudson do
  def report_path
    "hudson/reports"
  end

  def cucumber_report_path
    "#{report_path}/cucumber"
  end

  def rspec_report_path
    "#{report_path}/rspec"
  end

  def report_setup(report_path)
    rm_rf report_path
    mkdir_p report_path
  end
  
  desc 'Recreates cucumber report output folder'
  task :cucumber_report_setup do
    report_setup cucumber_report_path
  end

  desc 'Recreates rspec report output folder'
  task :rspec_report_setup do
    report_setup rspec_report_path
  end

  desc "Runs all cucumber features"
  Cucumber::Rake::Task.new({'cucumber'  => [:cucumber_report_setup]}) do |t|
    t.cucumber_opts = %{--profile default  --format junit --out #{cucumber_report_path}}
  end

 

  desc "Runs all rspec tests"
  task :spec => [:rspec_report_setup, "hudson:setup:rspec", :hudson_spec] 


  RSpec::Core::RakeTask.new(:hudson_spec) do |t|

  end


  namespace :setup do
    task :pre_ci do
      ENV["CI_REPORTS"] = rspec_report_path
      gem 'ci_reporter'
      require 'ci/reporter/rake/rspec'
    end

    task :rspec => [:pre_ci, "ci:setup:rspec"]
  end
  
end

