# encoding: UTF-8
require 'rubygems'
require 'i18n'

class Templater < Thor

  desc "export", "export all mail templates from files"
  def export
    @basedir = Dir.pwd
    @destinationdir = File.join(@basedir, "translations", "mails")
    FileUtils.mkdir_p @destinationdir

    @list_file = File.join(@destinationdir, "list.txt")
    FileUtils.rm @list_file if File.exists?(@list_file)
    list = File.new( @list_file, 'w+' )

    @s_list_file = File.join(@destinationdir, "source_list.txt")
    FileUtils.rm @s_list_file if File.exists?(@s_list_file)
    s_list = File.new( @s_list_file, 'w+' )
    
    @basedir = File.join(@basedir, "app", "views", "**", "*mailer*", "*")
    
    Dir[@basedir].each do |source|
      destination = File.join(@destinationdir, File.basename(source))
      FileUtils.rm destination  if File.exists?(destination)
      list.write "#{File.basename(source)}\n"
      s_list.write "#{source}\n"
      FileUtils.cp(source, destination)
    end

  end

end