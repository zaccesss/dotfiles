# =============================================================================
# Go
# =============================================================================

alias gor="go run ."
alias gob="go build ./..."
alias got="go test ./..."
alias gfmt="go fmt ./..."
alias govet="go vet ./..."
alias gomod="go mod tidy"
alias goi="go install ./..."
alias goup="go get -u ./..."
alias godoc="go doc"
alias gocov="go test -cover ./..."
alias goenv="go env"
alias goci="golangci-lint run"          # requires: apt install golangci-lint (or the install script)

goadd() {
    go get "${1:?Usage: goadd <package>}"
}
