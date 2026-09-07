# =============================================================================
# Go
# I use Go for backend services and CLI tools. gfmt is named to avoid
# conflicting with the actual gofmt binary - go fmt ./... is the idiomatic
# way to format a full module anyway.
# =============================================================================

alias gor="go run ."
alias gob="go build ./..."
alias got="go test ./..."
alias gfmt="go fmt ./..."
alias govet="go vet ./..."
alias gomod="go mod tidy"
alias goi="go install ./..."
alias goup="go get -u ./..."            # update all deps to latest minor/patch
alias godoc="go doc"
alias gocov="go test -cover ./..."
alias goenv="go env"
alias goci="golangci-lint run"          # requires: brew install golangci-lint

# goadd: fetch a single dependency and add it to go.mod
goadd() {
    go get "${1:?Usage: goadd <package>}"
}
