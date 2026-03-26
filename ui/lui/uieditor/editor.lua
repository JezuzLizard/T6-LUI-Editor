editor_tools = {}
editor_api = {}

require("lui.uieditor.editor_api_functions")
require("lui.uieditor.editor_api_callbacks")
--require("ui.lui.uieditor.editor_api_code_generator")

editor_api.tokenize = function(string, delimiters)
	local tokens = {}
	local regex = '([^'..delimiters..']+)'
	string.gsub(string, regex, function(value) 
									tokens[#tokens + 1] = value;  
								 end);
	return tokens
end

--format: <cmdname arg1 arg2 arg3 ...>;<cmdname arg1 arg2 arg3 ...>;
editor_tools.MAIN = function(uieditor_element, event)
	if not Engine then
		return
	end

	editor_api.f_toggle_editor()
	print("TICK; UIEDITOR ENABLED: [" .. tostring(editor_api.f_editor_active()) .. "]")
	if not editor_api.f_editor_active() then
		return
	end
	local input = UIExpression.DvarString(nil, "uieditor_input_watcher")

	local commands = {}
	if input ~= "" then
		print("EXECUTING: [" .. input .. "]")
		local cmd_names_args_pairs = editor_api.tokenize(input, ";")
		for i = 1, #cmd_names_args_pairs, 1 do
			commands[i] = {}
			local cmdname_args_pairs = editor_api.tokenize(cmd_names_args_pairs[i], " ")
			commands[i].cmdname = cmdname_args_pairs[1]
			commands[i].cmdargs = {}
			for j = 2, #cmdname_args_pairs, 1 do
				commands[i].cmdargs[j - 1] = cmdname_args_pairs[j]
			end

			local event = {
				name = "uieditor_user_event",
				cmdname = commands[i].cmdname,
				cmdargs = commands[i].cmdargs,
				delay = 0
			}

			if editor_api.T_EVENTS_PRIVATE[commands[i].cmdname] ~= nil then
				editor_api.T_EVENTS_PRIVATE[commands[i].cmdname](uieditor_element, commands[i].cmdname, commands[i].cmdargs)
			else
				print("INVALID COMMAND: " .. commands[i].cmdname)
			end
		end

		Engine.SetDvar("uieditor_input_watcher", "")
	end
end