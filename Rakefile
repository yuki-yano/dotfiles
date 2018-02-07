SRC_DIR = File.dirname(File.expand_path(__FILE__))
VIMPERATOR_DIR = File.join(SRC_DIR, '.vimperator')
DOTFILES_SRCS = %w[
  .Xdefaults
  .agignore
  .amethyst
  .atom
  .bashrc
  .config
  .ctags
  .dircolors
  .gemrc
  .gitattributes_global
  .gitconfig
  .gitignore_global
  .globalrc
  .gvimrc
  .ideavimrc
  .pryrc
  .railsrc
  .rdebugrc
  .stylelintrc
  .textlintrc
  .tigrc
  .tmux.conf
  .vim
  .vimperator
  .vimperatorrc
  .vimrc
  .zsh
  .zshenv
  .zshrc
].freeze
OSX_SCRIPTS = FileList['osx/**/*.sh']

namespace :dotfiles do
  desc 'Install dotfiles'
  task install: DOTFILES_SRCS do |t|
    t.prerequisites.each do |prereq|
      src = File.join(SRC_DIR, prereq)
      dest = File.join(ENV['HOME'], prereq)
      sh "\\rm -rf #{dest}"
      sh "ln -sfn #{src} #{dest}"
    end
  end
end

namespace :zgen do
  desc 'Update zgen'
  task :update do
    sh 'curl -fLo ~/.zsh/zgen/zgen.zsh --create-dirs https://raw.githubusercontent.com/tarjoilija/zgen/master/zgen.zsh'
    sh 'curl -fLo ~/.zsh/zgen/_zgen --create-dirs https://raw.githubusercontent.com/tarjoilija/zgen/master/_zgen'
  end
end

namespace :gem do
  desc 'Uninstall gem'
  task :uninstall do
    default_gem = 'bigdecimal|io-console|json|minitest|openssl|psych|rake|rdoc|test-unit|bundler|neovim|rcodetools'
    sh 'rbenv rehash'
    sh "gem uninstall -axI $(gem list --no-versions | egrep -v '#{default_gem}')"
  end
end

namespace :bundle do
  desc 'Install bundle'
  task install: 'Gemfile' do
    sh 'rbenv rehash'
    sh 'gem install bundler'    unless Gem::Specification.any? { |g| g.name == 'bundler' }
    sh 'gem install neovim'     unless Gem::Specification.any? { |g| g.name == 'neovim' }
    sh 'gem install rcodetools' unless Gem::Specification.any? { |g| g.name == 'rcodetools' }
    sh 'gem install fastri'     unless Gem::Specification.any? { |g| g.name == 'fastri' }
    sh 'gem install solargraph' unless Gem::Specification.any? { |g| g.name == 'solargraph' }
    sh 'gem update'
    File.delete('Gemfile.lock')     if File.exist?('Gemfile.lock')
    FileUtils.rm_r('vendor/bundle') if Dir.exist?('vendor/bundle')
    sh 'bundle install -j8 --path vendor/bundle --binstubs=vendor/bin'
  end

  desc 'Uninstall bundle install gems'
  task uninstall: 'Gemfile' do
    sh 'rbenv rehash'
    sh 'gem install bundler' unless Gem::Specification.any? { |g| g.name == 'bundler' }
    File.delete('Gemfile.lock') if File.exist?('Gemfile.lock')
    FileUtils.rm_r('vendor/bundle') if Dir.exist?('vendor/bundle')
  end
end

namespace :pip do
  desc 'Install pip'
  task install: 'Pipfile' do
    sh 'pyenv rehash'
    sh 'pip  install setuptools'
    sh 'pip2 install setuptools'
    sh 'pip3 install setuptools'
    sh 'pip  install pip --upgrade'
    sh 'pip2 install pip --upgrade'
    sh 'pip3 install pip --upgrade'
    sh 'pip  list --outdated --format=legacy | cut -d" " -f1 | xargs pip2 install --upgrade'
    sh 'pip2 list --outdated --format=legacy | cut -d" " -f1 | xargs pip2 install --upgrade'
    sh 'pip3 list --outdated --format=legacy | cut -d" " -f1 | xargs pip3 install --upgrade'
    File.readlines('Pipfile').map(&:chomp).each do |package|
      system "pip  install #{package} --upgrade"
      system "pip2 install #{package} --upgrade"
      system "pip3 install #{package} --upgrade"
    end
  end
end

namespace :yarn do
  desc 'Install node modules'
  task install: 'package.json' do
    sh 'nodenv rehash'
    sh 'yarn install'
  end
end

namespace :vimperator do
  desc 'Install vimperator plugins'
  task install: 'Vimperatorfile' do
    # vimperator-plugins
    File.readlines('Vimperatorfile').map(&:chomp).each do |plugin|
      src = File.join(VIMPERATOR_DIR, 'vimperator-plugins', plugin)
      dest = File.join(VIMPERATOR_DIR, 'plugin', plugin)
      sh "ln -sfn #{src} #{dest}"
    end

    # local plugins
    FileList['.vimperator/local-plugins/*'].each do |plugin|
      src = File.expand_path(plugin)
      dest = File.join(VIMPERATOR_DIR, 'plugin', File.basename(plugin))
      sh "ln -sfn #{src} #{dest}"
    end
  end
end

namespace :osx do
  desc 'Setup OSX preferences'
  task setup: OSX_SCRIPTS do |t|
    t.prerequisites.each do |prereq|
      system 'bash', prereq
    end

    # karabiner
    # src = File.join(SRC_DIR, 'osx', 'karabiner', 'private.xml')
    # dest = File.join(ENV['HOME'], 'Library', 'Application\ Support', 'Karabiner', 'private.xml')
    # sh "ln -sfn #{src} #{dest}"

    # BetterTouchTool
    # src = File.join(ENV['HOME'], 'Dropbox', 'settings', 'BetterTouchTool')
    # dest = File.join(ENV['HOME'], 'Library', 'Application\ Support', 'BetterTouchTool')
    # sh "ln -sfn #{src} #{dest}"

    # Witch
    # src = File.join(ENV['HOME'], 'Dropbox', 'settings', 'Witch')
    # dest = File.join(ENV['HOME'], 'Library', 'Application\ Support', 'Witch')
    # sh "ln -sfn #{src} #{dest}"
  end
end

namespace :homebrew do
  desc 'Install homebrew packages'
  task bundle: 'Brewfile' do
    package = File.readlines('Brewfile').map(&:chomp).select do |line|
      !line.empty? && line[0] != '#'
    end

    package.each do |line|
      sh "brew #{line}"
    end
  end

  desc 'Install homebrew cask packages'
  task cask: 'Caskfile' do
    app = File.readlines('Caskfile').map(&:chomp).select do |line|
      !line.empty? && line[0] != '#'
    end

    app.each do |line|
      sh "brew #{line}"
    end
  end
end

namespace :go do
  desc 'Install Go packages'
  task install: 'Gofile' do
    File.readlines('Gofile').map(&:chomp).each do |package|
      sh "go get #{package}"
    end
  end
end

namespace :mas do
  desc 'Install AppStore packages'
  task install: 'Masfile' do
    # MasfileからアプリのIDを抽出
    apps = File.readlines('Masfile').map(&:chomp).select do |line|
      !line.empty? && line[0] != '#'
    end
    apps = apps.map do |app|
      app.split(' ')[1]
    end

    # インストール済みのアプリを抽出
    installed_app = `mas list`.split("\n").map { |app| app.split(' ')[0] }

    install_app = apps - installed_app
    install_app.map do |app|
      sh "mas install #{app}"
    end
  end
end

namespace :apm do
  desc 'Install atom packages'
  task install: 'Apmfile' do
    packages = File.readlines('Apmfile').map(&:chomp).select do |line|
      !line.empty? && line[0] != '#'
    end
    packages = packages.map do |package|
      package.split('@')[0]
    end

    installed_packages = `apm list --installed --bare`.split("\n")

    install_packages = packages - installed_packages
    install_packages.map do |package|
      sh "apm install #{package}"
    end
  end

  desc 'Update atom packages'
  task update: 'Apmfile' do
    sh 'apm upgrade'
  end

  namespace :update do
    desc 'Update Apmfile'
    task file: 'Apmfile' do
      File.write('Apmfile', `apm list --installed --bare`.split("\n").map { |package| package.split('@')[0] }.join("\n"))
    end
  end

  desc 'Uninstall atom packages'
  task :uninstall do
    sh 'apm uninstall .'
  end
end

namespace :vagrant do
  desc 'Install vagrant plugins'
  task plugins: 'VagrantPlugins' do
    sh 'vagrant plugin update'
    File.readlines('VagrantPlugins').map(&:chomp).each do |plugin|
      sh "vagrant plugin install #{plugin}"
    end
  end
end
