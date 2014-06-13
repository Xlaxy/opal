# A sample Guardfile
# More info at https://github.com/guard/guard#readme

def mspec *paths
  command = ['bundle', 'exec', './bin/opal-mspec', *paths.flatten]
  time(:mspec, *paths) { system *command }
end

def rspec *paths
  command = ['bundle', 'exec', 'rspec', *paths.flatten]
  time(:rspec, *paths) { system *command }
end

def color *args
  Guard::UI.send :color, *args
end

def time *titles
  puts color("== #{titles.join(' ')} ".ljust(80,'='), :cyan)
  s = Time.now
  yield
  puts color("== time: #{(Time.now - s).to_f} ".ljust(80, '='), :cyan)
end

watch(%r{.*}) do |m|
  path = m[0]
  puts color("Searching specs for #{m[0]}...", :yellow)
  case path
  when %r{^spec/cli}     then rspec path
  when %r{^spec/corelib} then mspec path
  when %r{^opal/corelib}
    name = File.basename(path, '.rb')
    mspec "spec/corelib/core/#{name}/**/*_spec.rb"
  when %r{^lib/opal/(.*)\.rb$}
    name = $1
    specs = Dir["spec/cli/#{name}_spec.rb"]
    rspec *specs
  end
end
