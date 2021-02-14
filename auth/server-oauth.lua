local version = 1.5
local oauthToken;
local server_secret = 'SECRET_BY_SERVER';
local current_class = select(2,UnitClass('player')):lower();
local domain = "nerdpack.xyz"
local print = function(...) NeP.Core:Print(...) end

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function load_code(code, name)
    local func, errorMessage = loadstring(code, name)
	if(not func) then
		print('ERROR loading ', name, '!');
		errorhandler(errorMessage)
	end
	setfenv(func, _G)
	local success, xerrorMessage = xpcall(func, errorhandler);
	if(not success) then
		print('ERROR loading ', name, '!');
		errorhandler(xerrorMessage)
	end
end

local function setCrs(body)
	if not body then
		print('DONE no crs loaded');
		return;
	end
	local crs = _G.json.decode(body)
	for _,cr in pairs(crs) do
		load_code(cr.cr, cr.name);
	end
	NeP.Interface.ResetCRs();
    NeP.CR:Set();
	print('DONE loading crs!');
end

local function setPlugins(body)
	if not body then
		print('DONE no Plugins loaded');
		return;
	end
	local plugins = _G.json.decode(body)
	for _,plugin in pairs(plugins) do
		load_code(plugin.lua, plugin.name);
	end
	print('DONE loading plugins!');
end

--REPLACE_WITH_UNLOCKER_FILE

local function login()
  if oauthToken then print('Already Logged in'); return; end
  local username = NeP.Interface:Fetch(n_name .. '_ServerOAuth', 'username');
  local password = NeP.Interface:Fetch(n_name .. '_ServerOAuth', 'password');
  if password and password:len() > 0 and username and username:len() > 0 then
		getToken(username, password)
  end
end

local config = {
	key = n_name .. '_ServerOAuth',
	title = n_name,
	subtitle = 'OAuth',
	width = 250,
	height = 100,
	config = {
		{ type = 'spacer' },
		{ type = 'input', text = 'Username', key = 'username', width = 150 },
		{ type = 'input', text = 'Password', key = 'password', width = 150 },
		{ type = 'spacer' },
		{ type = 'button', text = 'Login', width = 230, height = 20, callback = function(val) login() end},
	}
}

local GUI = NeP.Interface:BuildGUI(config)
NeP.Interface:Add('OAuth V:'..version, function() GUI.parent:Show() end)
GUI.parent:Hide();

-- try auto login
NeP.Core:WhenInGame(login, 9997);
