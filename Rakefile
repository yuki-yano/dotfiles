SRC_DIR        = File.dirname(File.expand_path(__FILE__))
VIMPERATOR_DIR = File.join(SRC_DIR, '.vimperator')
ZPLUGIN_DIR    = File.join(ENV['HOME'], '.zplugin')
ZGEN_DIR       = File.join(ENV['HOME'], '.zsh/zgen')
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
  .githudrc
  .gitignore_global
  .globalrc
  .gvimrc
  .ideavimrc
  .pryrc
  .railsrc
  .rdebugrc
  .rgignore
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

namespace :zsh do
  namespace :zplugin do
    # @see https://github.com/zdharma/zplugin/blob/master/doc/install.sh
    desc 'Install zplugin'
    task :install do
      begin
        FileUtils.mkdir(ZPLUGIN_DIR)
        puts ">>> Downloading zplugin to #{ZPLUGIN_DIR}/bin"
        sh "cd #{ZPLUGIN_DIR}; git clone --depth 10 https://github.com/zdharma/zplugin.git bin"
        puts '>>> Done'
      rescue Errno::EEXIST => _
        puts 'Zplugin directory already exists'
        exit 1
      end
    end

    desc 'Uninstall zplugin'
    task :uninstall do
      begin
        FileUtils.rm_r(ZPLUGIN_DIR)
        puts "Remove directory #{ZPLUGIN_DIR}"
      rescue Errno::ENOENT => _
        puts "#{ZPLUGIN_DIR} does not exist"
        exit 1
      end
    end
  end

  namespace :zgen do
    desc 'Update zgen'
    task :update do
      sh "curl -fLo #{ZGEN_DIR}/zgen.zsh --create-dirs https://raw.githubusercontent.com/tarjoilija/zgen/master/zgen.zsh"
      sh "curl -fLo #{ZGEN_DIR}/_zgen --create-dirs https://raw.githubusercontent.com/tarjoilija/zgen/master/_zgen"
    end
  end
end

namespace :gem do
  desc 'Uninstall gem'
  task :uninstall do
    sh 'rbenv rehash'
    sh 'gem uninstall --all --ignore-dependencies --executables $(gem list | grep -v "default" | awk "{print $1}")'
  end
end

namespace :bundle do
  desc 'Install bundle'
  task install: 'Gemfile' do
    sh 'rbenv rehash'
    sh 'yes | gem update'
    File.delete('Gemfile.lock') if File.exist?('Gemfile.lock')
    sh 'gem install bundler && bundle install'
  end

  desc 'Uninstall bundle install gems'
  task uninstall: 'Gemfile' do
    sh 'rbenv rehash'
    sh 'gem uninstall --all --ignore-dependencies --executables --user-install --force'
    sh 'gem install bundler'
    File.delete('Gemfile.lock') if File.exist?('Gemfile.lock')
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
    sh 'rm -rf node_modules yarn.lock && yarn cache clean'
    sh 'yarn install'
  end

  desc 'Uninstall node modules'
  task uninstall: 'package.json' do
    sh 'nodenv rehash'
    sh 'rm -rf node_modules yarn.lock && yarn cache clean'
  end
end

# namespace :vimperator do
#   desc 'Install vimperator plugins'
#   task install: 'Vimperatorfile' do
#     # vimperator-plugins
#     File.readlines('Vimperatorfile').map(&:chomp).each do |plugin|
#       src  = "~/.vimperator/vimperator-plugins/#{plugin}"
#       dest = "~/.vimperator/plugin/#{plugin}"
#       sh "ln -sfn #{src} #{dest}"
#     end
#
#     # local plugins
#     FileList['.vimperator/local-plugins/*'].each do |plugin|
#       src = "~/#{plugin}"
#       dest = "~/.vimperator/plugin/#{File.basename(plugin)}"
#       sh "ln -sfn #{src} #{dest}"
#     end
#   end
#
#   desc 'Uninstall vimperator plugins'
#   task :uninstall do
#     FileList['.vimperator/plugin/*'].each do |plugin|
#       sh "rm ~/#{plugin}"
#     end
#   end
# end

# namespace :osx do
#   desc 'Setup OSX preferences'
#   task setup: OSX_SCRIPTS do |t|
#     t.prerequisites.each do |prereq|
#       system 'bash', prereq
#     end
#
#     karabiner
#     src = File.join(SRC_DIR, 'osx', 'karabiner', 'private.xml')
#     dest = File.join(ENV['HOME'], 'Library', 'Application\ Support', 'Karabiner', 'private.xml')
#     sh "ln -sfn #{src} #{dest}"
#
#     BetterTouchTool
#     src = File.join(ENV['HOME'], 'Dropbox', 'settings', 'BetterTouchTool')
#     dest = File.join(ENV['HOME'], 'Library', 'Application\ Support', 'BetterTouchTool')
#     sh "ln -sfn #{src} #{dest}"
#
#     Witch
#     src = File.join(ENV['HOME'], 'Dropbox', 'settings', 'Witch')
#     dest = File.join(ENV['HOME'], 'Library', 'Application\ Support', 'Witch')
#     sh "ln -sfn #{src} #{dest}"
#   end
# end

namespace :brew do
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

namespace :coteditor do
  desc 'Integrate command line with citeditor'
  task :install do
    sh 'ln -sfn /Applications/CotEditor.app/Contents/SharedSupport/bin/cot /usr/local/bin/cot'
  end

  desc 'Delete cot command'
  task :uninstall do
    sh 'rm /usr/local/bin/cot'
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
