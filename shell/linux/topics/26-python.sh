# =============================================================================
# Python and Django
# =============================================================================

alias py="python3"
alias pip="pip3"
alias venv="python3 -m venv venv"
alias activate="source venv/bin/activate"
alias ptest="pytest"
alias ptestcov="pytest --cov"
alias plint="ruff check ."
alias pfmt="ruff format ."
alias ptype="mypy ."
alias preqs="pip install -r requirements.txt"
alias pfreeze="pip freeze > requirements.txt"

alias ipy="ipython"

alias djr="python manage.py runserver"
alias djm="python manage.py migrate"
alias djmm="python manage.py makemigrations"
alias djs="python manage.py shell"
alias djc="python manage.py collectstatic --noinput"
alias djsu="python manage.py createsuperuser"
alias djtest="python manage.py test"
