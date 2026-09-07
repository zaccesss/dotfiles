# =============================================================================
# PHP and Laravel
# =============================================================================

function pa    { php artisan $args }
function par   { php artisan serve }
function pamm  { php artisan make:migration $args }
function pamc  { php artisan make:controller $args }
function pam   { php artisan migrate }
function pamr  { php artisan migrate:rollback }
function pamfs { php artisan migrate:fresh --seed }
function pads  { php artisan db:seed }
function parl  { php artisan route:list }
function paq   { php artisan queue:work }
function paoc  { php artisan optimize:clear }
function pat   { php artisan tinker }

function pserve { php -S localhost:8000 }

function ci        { composer install }
function cupdate   { composer update }
function creq      { composer require $args }
function cdump     { composer dump-autoload }
function coutdated { composer outdated }

function punit { .\vendor\bin\phpunit.bat $args }
function pint  { .\vendor\bin\pint.bat $args }
