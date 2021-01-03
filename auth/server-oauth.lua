local version = 1.5
local oauthToken;
-- would like this gone... i need to pass nep tho
local pointer = tostring(NeP);
_G[pointer] = NeP;
local server_secret = 'SECRET_BY_SERVER';
local current_class = select(1,UnitClass('player')):lower();
local domain = "nerdpack.xyz"

local function setCrs(body)
	local func, errorMessage = loadstring(
		"local NeP = _G['" .. pointer .. "'];\n" ..
		"local n_name = '" .. n_name .. "';\n" ..
		"local local_stream_name = '" .. local_stream_name .. "'\n" ..
		body,
		'NerdPack-Auth-CRs'
	);
	if errorMessage then
		print('Error Loading CRs', errorMessage)
	end
	pcall(func);
	NeP.Core:Print('DONE loading crs!');
end

local function setPlugins(body)
	local func, errorMessage = loadstring(
		"local NeP = _G['" .. pointer .. "'];\n" ..
		"local n_name = '" .. n_name .. "';\n" ..
		"local local_stream_name = '" .. local_stream_name .. "'\n" ..
		body,
		'NerdPack-Auth-Plugins'
	);
	if errorMessage then
		print('Error Loading Plugins', errorMessage)
	end
	pcall(func);
	NeP.Core:Print('DONE loading plugins!');
end

--REPLACE_WITH_UNLOCKER_FILE

local function login()
  if oauthToken then NeP.Core:Print('Already Logged in'); return; end
  local username = NeP.Interface:Fetch(n_name .. '_ServerOAuth', 'username');
  local password = NeP.Interface:Fetch(n_name .. '_ServerOAuth', 'password');
  if password and password:len() > 0 and username and username:len() > 0 then
		pcall(getToken, username, password)
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
login();
