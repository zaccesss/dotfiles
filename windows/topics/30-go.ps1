# =============================================================================
# Go
# =============================================================================

function gor   { go run . $args }
function gob   { go build ./... }
function got   { go test ./... }
function gfmt  { go fmt ./... }
function govet { go vet ./... }
function gomod { go mod tidy }
function goi    { go install ./... }
function goup   { go get -u ./... }
function godoc  { go doc @args }
function gocov  { go test -cover ./... }
function goenv  { go env @args }
function goci   { golangci-lint run }   # requires: winget install golangci-lint
function goadd  { param($Pkg) go get $Pkg }
