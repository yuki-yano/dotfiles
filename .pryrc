Pry.config.editor = 'vim'

alias r require

def safe_require_gem(gem)
  return unless Gem::Specification.any? { |g| g.name == gem }
  require gem
  yield if block_given?
end

%w[pp].each do |lib|
  require lib
end

safe_require_gem 'tapp'

safe_require_gem('awesome_print') do
  AwesomePrint.pry!
end

safe_require_gem('hirb') do
  Hirb::View.instance_eval do
    def enable_output_method
      @output_method = true
      @old_print = Pry.config.print
      Pry.config.print = proc do |*args|
        Hirb::View.view_or_page_output(args[1]) || @old_print.call(*args)
      end
    end

    def disable_output_method
      Pry.config.print = @old_print
      @output_method = nil
    end
  end

  Hirb.enable
end
