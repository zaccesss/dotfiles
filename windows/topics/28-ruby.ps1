# =============================================================================
# Ruby and Rails - Windows PowerShell
# Install Ruby: winget install RubyInstallerTeam.RubyWithDevKit
# =============================================================================

function rbls      { rbenv versions }
function rbuse     { rbenv local @args }
function rbglobal  { rbenv global @args }
function rbinstall { rbenv install @args }

function be        { bundle exec @args }
function binst     { bundle install }
function bupd      { bundle update }
function boutd     { bundle outdated }
function bcheck    { bundle check }
function bclean    { bundle clean --force }

function rs        { bundle exec rails server }
function rc        { bundle exec rails console }
function rg        { bundle exec rails generate @args }
function rgm       { bundle exec rails generate model @args }
function rgc       { bundle exec rails generate controller @args }
function rdm       { bundle exec rails db:migrate }
function rds       { bundle exec rails db:seed }
function rdc       { bundle exec rails db:create }
function rdd       { bundle exec rails db:drop }
function rdreset   { bundle exec rails db:reset }
function rrout     { bundle exec rails routes }
function rtask     { bundle exec rails @args }

# rnew: scaffold a brand new Rails app - run outside bundle exec since there's no Gemfile yet
function rnew      { rails new @args }

function rspec     { bundle exec rspec @args }
function rspecf    { bundle exec rspec --format documentation @args }

function rb        { ruby @args }

# irb: fall back to the bare interpreter when there's no Gemfile to bundle exec against
function irb {
    bundle exec irb 2>$null
    if ($LASTEXITCODE -ne 0) { irb.bat }
}

function gemi      { gem install @args }
function gemls     { gem list }

# rubocop: fall back to the bare gem when there's no Gemfile to bundle exec against
function rubocop {
    bundle exec rubocop @args 2>$null
    if ($LASTEXITCODE -ne 0) { rubocop.bat @args }
}
function rubofix   { bundle exec rubocop --autocorrect @args }
