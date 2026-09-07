# =============================================================================
# Ruby and Rails
# rbenv manages versions on Linux. Requires: rbenv ruby-build
# =============================================================================

alias rbls="rbenv versions"
alias rbuse="rbenv local"
alias rbglobal="rbenv global"
alias rbinstall="rbenv install"

alias be="bundle exec"
alias binst="bundle install"
alias bupd="bundle update"
alias boutd="bundle outdated"
alias bcheck="bundle check"
alias bclean="bundle clean --force"

alias rs="bundle exec rails server"
alias rc="bundle exec rails console"
alias rg="bundle exec rails generate"
alias rgm="bundle exec rails generate model"
alias rgc="bundle exec rails generate controller"
alias rdm="bundle exec rails db:migrate"
alias rds="bundle exec rails db:seed"
alias rdc="bundle exec rails db:create"
alias rdd="bundle exec rails db:drop"
alias rdreset="bundle exec rails db:reset"
alias rrout="bundle exec rails routes"
alias rtask="bundle exec rails"
alias rnew="rails new"

alias rspec="bundle exec rspec"
alias rspecf="bundle exec rspec --format documentation"

alias rb="ruby"
alias irb="bundle exec irb 2>/dev/null || irb"

alias gemi="gem install"
alias gemls="gem list"

alias rubocop="bundle exec rubocop 2>/dev/null || rubocop"
alias rubofix="bundle exec rubocop --autocorrect"
