# =============================================================================
# PHP and Laravel
# I use Laravel for PHP projects. All aliases use the 'pa' prefix (php artisan)
# so they're instantly recognisable.
# =============================================================================

alias pa="php artisan"
alias par="php artisan serve"
alias pamm="php artisan make:migration"
alias pamc="php artisan make:controller"
alias pam="php artisan migrate"
alias pamr="php artisan migrate:rollback"
alias pamfs="php artisan migrate:fresh --seed"
alias pads="php artisan db:seed"
alias parl="php artisan route:list"
alias paq="php artisan queue:work"
alias paoc="php artisan optimize:clear" # clear route/config/view/cache in one go
alias pat="php artisan tinker"          # Laravel's REPL

# php built-in server for a plain PHP project with no framework
alias pserve="php -S localhost:8000"

# Composer
alias ci="composer install"
alias cupdate="composer update"
alias creq="composer require"
alias cdump="composer dump-autoload"
alias coutdated="composer outdated"

# Testing and formatting
alias punit="./vendor/bin/phpunit"
alias pint="./vendor/bin/pint"          # Laravel's official formatter
