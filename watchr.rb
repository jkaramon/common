def all_specs
  "spec"
end

`rm -rf coverage/`
`growlnotify -n autotest -m '#{Dir.pwd}' 'Watchr Started'`

trap 'INT' do
  if $interrupted
    exit! 0
  else
    puts "Interrupt a second time to quit"
    `rm -rf coverage/`
    $interrupted = true
    sleep 1
    $interrupted = false
    run_spec(all_specs)
  end
end

def run_spec(file)
  puts "Running spec file(s) #{file}"
  return unless file.include?(" ") || File.exist?(file)
  system("bundle exec rspec --drb -fp -d -c #{file}")
end


def basename(md)
  File.basename(md[0], ".rb")
end


watch( '^(.*)' ) {|md| run_spec(all_specs) }
