-- The language servers to install and start. The first four are always wanted: clangd for C and
-- C++ (microcontroller work), pyright for Python, ts_ls for TypeScript and lua_ls for this config.
-- The rest need a runtime of their own, so each is only listed on a machine that has it, rather
-- than Mason failing to install it on every start where the runtime is missing.
local M = {}

local always = { "clangd", "pyright", "ts_ls", "lua_ls", "marksman" }

-- server = the program its runtime needs
local needs = {
	rust_analyzer = "cargo",
	gopls = "go",
	jdtls = "java",
	html = "npm",
	cssls = "npm",
	jsonls = "npm",
	bashls = "npm",
}

function M.list()
	local servers = vim.deepcopy(always)
	for server, program in pairs(needs) do
		if vim.fn.executable(program) == 1 then
			table.insert(servers, server)
		end
	end
	table.sort(servers)
	return servers
end

return M
