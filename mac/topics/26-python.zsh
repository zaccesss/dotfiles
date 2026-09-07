# =============================================================================
# Python and Django
# I use Python for backend services, data processing and scripting. Django
# and DRF are my main backend framework for web projects.
# =============================================================================

# Python and pip shims so I never have to type python3 or pip3
alias py="python3"
alias pip="pip3"

# Virtual environment - I create a fresh venv in every project root
alias venv="python3 -m venv venv"
alias activate="source venv/bin/activate"

# Testing and linting - I use pytest and ruff on every Python project
alias ptest="pytest"
alias ptestcov="pytest --cov"
alias plint="ruff check ."
alias pfmt="ruff format ."
alias ptype="mypy ."
alias preqs="pip install -r requirements.txt"
alias pfreeze="pip freeze > requirements.txt"

# REPLs - ipython over the bare interpreter whenever it's on the PATH
alias ipy="ipython"

# Django management commands - I use these constantly in Django/DRF projects
alias djr="python manage.py runserver"
alias djm="python manage.py migrate"
alias djmm="python manage.py makemigrations"
alias djs="python manage.py shell"
alias djc="python manage.py collectstatic --noinput"
alias djsu="python manage.py createsuperuser"
alias djtest="python manage.py test"
