SRC_DIR       = File.dirname(File.expand_path(__FILE__))
ZINIT_DIR     = File.join(ENV['HOME'], '.zinit')
ZGEN_DIR      = File.join(ENV['HOME'], '.zsh/zgen')
DOTFILES_SRCS = %w[
  .bashrc
  .config
  .ctags.d
  .dir_colors
  .finicky.js
  .gitattributes_global
  .gitconfig
  .gitignore_global
  .globalrc
  .hammerspoon
  .tigrc
  .tmux.conf
  .vim
  .vimrc
  .zsh
  .zshenv
  .zshrc
].freeze

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
  namespace :zinit do
    # @see https://github.com/zdharma/zinit/blob/master/doc/install.sh
    desc 'Install zinit'
    task :install do
      begin
        FileUtils.mkdir(ZINIT_DIR)
        puts ">>> Downloading zinit to #{ZINIT_DIR}/bin"
        sh "cd #{ZINIT_DIR}; git clone --depth 10 https://github.com/zdharma-continuum/zinit.git bin"
        puts '>>> Done'
      rescue Errno::EEXIST => _
        puts 'Zinit directory already exists'
        exit 1
      end
    end

    desc 'Uninstall zinit'
    task :uninstall do
      begin
        FileUtils.rm_r(ZINIT_DIR)
        puts "Remove directory #{ZINIT_DIR}"
      rescue Errno::ENOENT => _
        puts "#{ZINIT_DIR} does not exist"
        exit 1
      end
    end
  end
end

namespace :tmux do
  desc 'Enable italic'
  task install: '.tmux/tmux-256color.terminfo' do |t|
    sh 'tic -x .tmux/tmux-256color.terminfo'
  end
end

namespace :gem do
  desc 'Install gem'
  task install: 'GemGlobal' do
    packages = File.readlines('GemGlobal').map(&:chomp).join(' ')
    sh "gem install #{packages}"
  end

  desc 'Uninstall gem'
  task :uninstall do
    sh 'gem uninstall --all --ignore-dependencies --executables $(gem list | grep -v "default" | awk "{print $1}")'
    sh 'gem install rake bundler'
  end
end

namespace :pip do
  desc 'Install pip'
  task install: 'PipGlobal' do
    sh 'pip  install setuptools'
    sh 'pip  install pip --upgrade'
    sh 'pip  list --outdated --format=legacy | cut -d" " -f1 | xargs pip install --upgrade'
    File.readlines('PipGlobal').map(&:chomp).each do |package|
      system "pip install #{package} --upgrade"
    end
  end

  desc 'Uninstall pip'
  task :uninstall do
    pip3file = '/tmp/piplist3.txt'
    system "pip3 freeze > #{pip3file} && test -f #{pip3file} && yes | pip3 uninstall -r #{pip3file} && rm #{pip3file}"
  end
end

namespace :npm do
  desc 'Install node modules'
  task install: 'NpmGlobal' do
    packages = File.readlines('NpmGlobal').map(&:chomp).join(' ')
    sh "yarn global add #{packages}"
  end

  desc 'Uninstall node modules'
  task :uninstall do
    sh "rm -rf #{`yarn global dir`}"
  end

  desc 'Upgrade node modules'
  task :upgrade do
    sh 'yarn global upgrade'
  end
end

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

# namespace :vscode do
#   desc 'Override vscode settings file'
#   task settings: ['.config/vscode/settings.json', '.config/vscode/keybindings.json', '.config/vscode/locale.json'] do
#     config_root = '~/Library/Application\ Support/Code/User'
#     sh "ln -sfn ~/.config/vscode/settings.json #{config_root}/settings.json"
#     sh "ln -sfn ~/.config/vscode/keybindings.json #{config_root}/keybindings.json"
#     sh "ln -sfn ~/.config/vscode/locale.json #{config_root}/locale.json"
#   end
# 
#   desc 'Install extensions'
#   task extension: 'Codefile' do
#     File.readlines('Codefile').map(&:chomp).each do |extension|
#       sh "code --install-extension #{extension}"
#     end
#   end
# 
#   desc 'Export extensions'
#   task :export_extension do
#     File.write('Codefile', `code --list-extensions`)
#   end
# end

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
