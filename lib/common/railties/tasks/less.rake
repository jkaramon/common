desc "Rake LESS helper tasks"
namespace :less do
  
  
  desc "Generates application stylesheets from from .less source files"
  task :screen do
    `lessc public/stylesheets/less/screen.less public/stylesheets/screen.css`
    `lessc public/stylesheets/less/session.less public/stylesheets/session.css`
    `lessc public/stylesheets/less/base.less public/stylesheets/base.css`
    puts 'Stylesheet screen.css has been generated.'
  end
  
  desc "Generates base and external stylesheets from from .less source files"
  task :base do
    `lessc public/stylesheets/less/base.less public/stylesheets/base.css`
    puts 'Stylesheet base.css has been generated.'
  end
  
end

task :less => 'less:screen'
