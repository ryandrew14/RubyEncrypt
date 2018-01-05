Gem::Specification.new do |s|
  s.name = "rbencrypt2"  # i.e. visualruby.  This name will show up in the gem list.
  s.version = "0.0.1"  # i.e. (major,non-backwards compatable).(backwards compatable).(bugfix)
  s.add_dependency "visualruby", ">= 3.0.18"
  s.add_dependency "require_all", ">= 1.2.0"
  s.has_rdoc = false
  s.authors = ["Your Name"] 
  s.email = "you@yoursite.com" # optional
  s.summary = "Short Description Here." # optional
  s.homepage = "http://www.yoursite.org/"  # optional
  s.description = "Full description here" # optional
  s.executables = ['rubyencrypt']  # i.e. 'vr' (optional, blank if library project)
  s.default_executable = 'rubyencrypt'  # i.e. 'vr' (optional, blank if library project)
  s.bindir = ['.']    # optional, default = bin
  s.require_paths = ['lib']  # optional, default = lib 
  s.files = Dir.glob(File.join("**", "*.{rb,glade}"))
  s.rubyforge_project = "nowarning" # supress warning message 
end
