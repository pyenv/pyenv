hook = lambda do |installer|
  begin
    # Ignore gems that aren't installed in locations that rbenv searches for binstubs
    if installer.spec.executables.any? &&
        [Gem.default_bindir, Gem.bindir(Gem.user_dir)].include?(installer.bin_dir)
      `rbenv rehash`
    end
  rescue
    warn "rbenv: error in gem-rehash (#{$!})"
  end
end

begin
  Gem.post_install(&hook)
  Gem.post_uninstall(&hook)
rescue
  warn "rbenv: error installing gem-rehash hooks (#{$!})"
end
