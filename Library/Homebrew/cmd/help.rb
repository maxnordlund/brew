HOMEBREW_HELP = <<-EOS
Example usage:
  brew [info | home | options ] [FORMULA...]
  brew install FORMULA...
  brew uninstall FORMULA...
  brew search [foo]
  brew list [FORMULA...]
  brew update
  brew upgrade [FORMULA...]
  brew pin/unpin [FORMULA...]

Troubleshooting:
  brew doctor
  brew install -vd FORMULA
  brew [--env | config]

Brewing:
  brew create [URL [--no-fetch]]
  brew edit [FORMULA...]
  https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Formula-Cookbook.md

Further help:
  man brew
  brew home
EOS

# NOTE Keep the lenth of vanilla --help less than 25 lines!
# This is because the default Terminal height is 25 lines. Scrolling sucks
# and concision is important. If more help is needed we should start
# specialising help like the gem command does.
# NOTE Keep lines less than 80 characters! Wrapping is just not cricket.
# NOTE The reason the string is at the top is so 25 lines is easy to measure!

module Homebrew
  def help
    puts HOMEBREW_HELP
  end

  def help_s
    HOMEBREW_HELP
  end

  def help_for_command(cmd)
    cmd = HOMEBREW_INTERNAL_COMMAND_ALIASES.fetch(cmd, cmd)
    cmd_path = if File.exist?(HOMEBREW_LIBRARY_PATH/"cmd/#{cmd}.sh")
      HOMEBREW_LIBRARY_PATH/"cmd/#{cmd}.sh"
    elsif ARGV.homebrew_developer? && File.exist?(HOMEBREW_LIBRARY_PATH/"dev-cmd/#{cmd}.sh")
      HOMEBREW_LIBRARY_PATH/"dev-cmd/#{cmd}.sh"
    elsif File.exist?(HOMEBREW_LIBRARY_PATH/"cmd/#{cmd}.rb")
      HOMEBREW_LIBRARY_PATH/"cmd/#{cmd}.rb"
    elsif ARGV.homebrew_developer? && File.exist?(HOMEBREW_LIBRARY_PATH/"dev-cmd/#{cmd}.rb")
      HOMEBREW_LIBRARY_PATH/"dev-cmd/#{cmd}.rb"
    end
    return if cmd_path.nil?

    cmd_path.read.
      split("\n").
      grep(/^#:/).
      map do |line|
        line.slice(2..-1).sub(/^  \* /, "#{Tty.highlight}brew#{Tty.reset} ").
        gsub(/`(.*?)`/, "#{Tty.highlight}\\1#{Tty.reset}").
        gsub(/<(.*?)>/, "#{Tty.em}\\1#{Tty.reset}")
      end.join("\n")
  end
end
