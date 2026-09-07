# =============================================================================
# JSON tools
# I use jq on every project that touches APIs - it's the most-used CLI tool
# outside of git in my day-to-day work. Requires: apt install jq
# =============================================================================

# Pretty-print JSON from stdin or a file
alias jqk='jq .'

# Count items in a JSON array or number of keys in an object
alias jqlen='jq length'

# Raw string output - avoids the default quoted output when extracting values
alias jqf='jq -r'

# Minify JSON - compress whitespace before sending over the wire
alias json-min='jq -c .'

# List all top-level keys in an object
alias json-keys='jq keys'

# Sort object keys alphabetically at every level - the same normalisation json-diff
# uses internally, handy standalone when comparing output by eye instead of with diff
alias jqsort='jq -S .'

# json-check: validate that a file is parseable - tells me immediately if a
# config is malformed before I waste time debugging a 422 response.
json-check() {
    jq empty "$1" 2>&1 && echo "Valid JSON" || echo "Invalid JSON: $1"
}

# json-diff: compare two JSON files ignoring key order.
# Useful for spotting config drift between environments.
json-diff() {
    diff <(jq -S . "$1") <(jq -S . "$2")
}

# jqpaths: list all leaf paths in a JSON file - useful for exploring unknown
# schemas from third-party APIs before writing real queries against them.
jqpaths() {
    jq -r '[paths | map(tostring) | join(".")][] | .' "$1" | sort -u
}

# jqmerge: deep-merge two JSON files, values in the second file win on conflict -
# useful for layering a local override file on top of a shared base config
jqmerge() {
    jq -s '.[0] * .[1]' "${1:?Usage: jqmerge <base.json> <override.json>}" "${2:?}"
}
