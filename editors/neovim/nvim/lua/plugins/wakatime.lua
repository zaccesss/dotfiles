-- loaded at start-up rather than on an event, so time spent in the very first buffer is counted too.
-- The plugin reads the api key from the WakaTime config file and uses its own wakatime-cli
return {
	{ "wakatime/vim-wakatime", lazy = false },
}
