# =============================================================================
# Ruby and Rails
# I primarily use Ruby via Rails and for scripting tasks. rbenv manages
# versions. Requires: brew install rbenv ruby-build
# =============================================================================

# rbenv version management
alias rbls="rbenv versions"
alias rbuse="rbenv local"
alias rbglobal="rbenv global"
alias rbinstall="rbenv install"

# Bundler
alias be="bundle exec"
alias binst="bundle install"
alias bupd="bundle update"
alias boutd="bundle outdated"
alias bcheck="bundle check"
alias bclean="bundle clean --force"

# Rails
alias rs="bundle exec rails server"
alias rc="bundle exec rails console"
alias rg="bundle exec rails generate"
alias rgm="bundle exec rails generate model"
alias rgc="bundle exec rails generate controller"
alias rds="bundle exec rails db:seed"
alias rdc="bundle exec rails db:create"
alias rdd="bundle exec rails db:drop"
alias rdreset="bundle exec rails db:reset"
alias rdm="bundle exec rails db:migrate"
alias rrout="bundle exec rails routes"
alias rtask="bundle exec rails"

# rnew: scaffold a brand new Rails app - run outside bundle exec since there's no Gemfile yet
alias rnew="rails new"

# RSpec
alias rspec="bundle exec rspec"
alias rspecf="bundle exec rspec --format documentation"

# Ruby basics
alias rb="ruby"
alias irb="bundle exec irb 2>/dev/null || irb"

# RubyGems
alias gemi="gem install"
alias gemls="gem list"

# Rubocop (linting)
alias rubocop="bundle exec rubocop 2>/dev/null || rubocop"
alias rubofix="bundle exec rubocop --autocorrect"
