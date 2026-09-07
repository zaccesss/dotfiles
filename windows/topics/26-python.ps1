# =============================================================================
# Python and Django
# =============================================================================

function py      { python $args }
function pip     { pip3 $args }
function venv    { python -m venv venv }
function activate { .\venv\Scripts\Activate.ps1 }
function ptest    { pytest $args }
function ptestcov { pytest --cov $args }
function plint    { ruff check . }
function pfmt     { ruff format . }
function ptype    { mypy . }
function preqs    { pip install -r requirements.txt }
function pfreeze  { pip freeze | Out-File requirements.txt }

function ipy { ipython $args }

function djr    { python manage.py runserver $args }
function djm    { python manage.py migrate }
function djmm   { python manage.py makemigrations $args }
function djs    { python manage.py shell }
function djc    { python manage.py collectstatic --noinput }
function djsu   { python manage.py createsuperuser }
function djtest { python manage.py test $args }
