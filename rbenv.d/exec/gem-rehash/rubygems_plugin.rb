hook = lambda do |installer|
  begin
    # Ignore gems that aren't installed in locations that rbenv searches for binstubs
    if installer.spec.executables.any? &&
        [Gem.default_bindir, Gem.bindir(Gem.user_dir)].include?(installer.bin_dir)
      `rbenv rehash`
    end
  rescue
    warn "rbenv: error in gem-rehash (#{$!.class.name}: #{$!.message})"
  end
end

if defined?(Bundler::Installer) && Bundler::Installer.respond_to?(:install)
  Bundler::Installer.class_eval do
    class << self
      alias install_without_rbenv_rehash install
      def install(root, definition, options = {})
        result = install_without_rbenv_rehash(root, definition, options)
        begin
          if result && Gem.default_path.include?(Bundler.bundle_path.to_s)
            `rbenv rehash`
          end
        rescue
          warn "rbenv: error in Bundler post-install hook (#{$!.class.name}: #{$!.message})"
        end
        result
      end
    end
  end
else
  begin
    Gem.post_install(&hook)
    Gem.post_uninstall(&hook)
  rescue
    warn "rbenv: error installing gem-rehash hooks (#{$!.class.name}: #{$!.message})"
  end
end
