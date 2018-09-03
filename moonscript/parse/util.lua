local unpack
unpack = require("moonscript.util").unpack
local P, C, S, Cp, Cmt, V
do
	local _obj_0 = require("lpeg")
	P, C, S, Cp, Cmt, V = _obj_0.P, _obj_0.C, _obj_0.S, _obj_0.Cp, _obj_0.Cmt, _obj_0.V
end
local ntype
ntype = require("moonscript.types").ntype
local Space
Space = require("moonscript.parse.literals").Space
local insert = table.insert
local append = insert
local reverse
reverse = function(t)
	local newt = { }
	for i = 1, #t do
		insert(newt, 1, t[i])
	end
	return newt
end
local Indent = C(S("\t ") ^ 0) / function(str)
	do
		local sum = 0
		for v in str:gmatch("[\t ]") do
			local _exp_0 = v
			if " " == _exp_0 then
				sum = sum + 1
			elseif "\t" == _exp_0 then
				sum = sum + 4
			end
		end
		return sum
	end
end
local Cut = P(function()
	return false
end)
local ensure
ensure = function(patt, finally)
	return patt * finally + finally * Cut
end
local extract_line
extract_line = function(str, start_pos)
	str = str:sub(start_pos)
	do
		local m = str:match("^(.-)\n")
		if m then
			return m
		end
	end
	return str:match("^.-$")
end
local show_line_position
show_line_position = function(str, pos, context)
	if context == nil then
		context = true
	end
	local lines = {
		{ }
	}
	for c in str:gmatch(".") do
		local _update_0 = #lines
		lines[_update_0] = lines[_update_0] or { }
		table.insert(lines[#lines], c)
		if c == "\n" then
			lines[#lines + 1] = { }
		end
	end
	for i, line in ipairs(lines) do
		lines[i] = table.concat(line)
	end
	local out
	local remaining = pos - 1
	for k, line in ipairs(lines) do
		if remaining < #line then
			local left = line:sub(1, remaining)
			local right = line:sub(remaining + 1)
			out = {
				tostring(left) .. "◉" .. tostring(right)
			}
			if context then
				do
					local before = lines[k - 1]
					if before then
						table.insert(out, 1, before)
					end
				end
				do
					local after = lines[k + 1]
					if after then
						table.insert(out, after)
					end
				end
			end
			break
		else
			remaining = remaining - #line
		end
	end
	if not (out) then
		return "-"
	end
	out = table.concat(out)
	return (out:gsub("\n*$", ""))
end
local mark
mark = function(name)
	return function(...)
		return {
			name,
			...
		}
	end
end
local pos
pos = function(patt)
	return (Cp() * patt) / function(pos, value)
		if type(value) == "table" then
			value[-1] = pos
		end
		return value
	end
end
local got
got = function(what, context)
	if context == nil then
		context = true
	end
	return Cmt("", function(str, pos)
		print("++ got " .. tostring(what), "[" .. tostring(show_line_position(str, pos, context)) .. "]")
		return true
	end)
end
local flatten_or_mark
flatten_or_mark = function(name)
	return function(tbl)
		if #tbl == 1 then
			return tbl[1]
		end
		table.insert(tbl, 1, name)
		return tbl
	end
end
local is_assignable
do
	local chain_assignable = {
		index = true,
		dot = true,
		slice = true
	}
	is_assignable = function(node)
		if node == "..." then
			return false
		end
		local _exp_0 = ntype(node)
		if "ref" == _exp_0 or "self" == _exp_0 or "value" == _exp_0 or "self_class" == _exp_0 or "table" == _exp_0 then
			return true
		elseif "chain" == _exp_0 then
			return chain_assignable[ntype(node[#node])]
		else
			return false
		end
	end
end
local check_assignable
check_assignable = function(str, pos, value)
	if is_assignable(value) then
		return true, value
	else
		return false
	end
end
local format_assign
do
	local flatten_explist = flatten_or_mark("explist")
	format_assign = function(lhs_exps, assign)
		if not (assign) then
			return flatten_explist(lhs_exps)
		end
		for _index_0 = 1, #lhs_exps do
			local assign_exp = lhs_exps[_index_0]
			if not (is_assignable(assign_exp)) then
				error({
					assign_exp,
					"left hand expression is not assignable"
				})
			end
		end
		local t = ntype(assign)
		local _exp_0 = t
		if "assign" == _exp_0 then
			return {
				"assign",
				lhs_exps,
				unpack(assign, 2)
			}
		elseif "update" == _exp_0 then
			return {
				"update",
				lhs_exps[1],
				unpack(assign, 2)
			}
		else
			return error("unknown assign expression: " .. tostring(t))
		end
	end
end
local format_single_assign
format_single_assign = function(lhs, assign)
	if assign then
		return format_assign({
			lhs
		}, assign)
	else
		return lhs
	end
end
local sym
sym = function(chars)
	return Space * chars
end
local symx
symx = function(chars)
	return chars
end
local simple_string
simple_string = function(delim, allow_interpolation)
	local inner = P("\\" .. tostring(delim)) + "\\\\" + (1 - P(delim))
	if allow_interpolation then
		local interp = symx('#{') * V("Exp") * sym('}')
		inner = (C((inner - interp) ^ 1) + interp / mark("interpolate")) ^ 0
	else
		inner = C(inner ^ 0)
	end
	return C(symx(delim)) * inner * sym(delim) / mark("string")
end
local wrap_func_arg
wrap_func_arg = function(value)
	return {
		"call",
		{
			value
		}
	}
end
local join_chain
join_chain = function(callee, args)
	if #args == 0 then
		return callee
	end
	args = {
		"call",
		args
	}
	if ntype(callee) == "chain" then
		table.insert(callee, args)
		return callee
	end
	return {
		"chain",
		callee,
		args
	}
end
local wrap_decorator
wrap_decorator = function(stm, dec)
	if not (dec) then
		return stm
	end
	return {
		"decorated",
		stm,
		dec
	}
end
local check_lua_string
check_lua_string = function(str, pos, right, left)
	return #left == #right
end
local self_assign
self_assign = function(name, pos)
	return {
		{
			"key_literal",
			name
		},
		{
			"ref",
			name,
			[-1] = pos
		}
	}
end
local conv_to_foreach
conv_to_foreach = function(value)
	local p1, direction, paramcount, p2
	p1, direction, paramcount, p2, mark = value[1], value[2], value[3], value[4], value[5]
	local t, f = p1, p2
	paramcount = tonumber(paramcount[2]) or 2
	local paramlist = { }
	local callparams = { }
	for i = 1, paramcount do
		local paramname = '_vn_' .. tostring(i)
		paramlist[#paramlist + 1] = paramname
		callparams[#callparams + 1] = {
			"ref",
			paramname
		}
	end
	return {
		"comprehension",
		{
			"chain",
			{
				"parens",
				f
			},
			{
				"call",
				callparams
			}
		},
		{
			{
				"foreach",
				paramlist,
				{
					"unpack",
					t
				}
			}
		}
	}
end
local get_value
get_value = function(node)
	local ntype = node[1]
	local _exp_0 = ntype
	if 'number' == _exp_0 then
		return tonumber(node[2])
	elseif 'string' == _exp_0 then
		return tostring(node[2])
	elseif 'ref' == _exp_0 then
		return node[2]
	end
end
local build_exch_params
build_exch_params = function(value)
	local src_params = { }
	local obj_params = { }
	local the_order = 0
	local add_curorder
	add_curorder = function(new_order)
		for i = the_order + 1, new_order - 1 do
			src_params[#src_params + 1] = {
				'_p_' .. tostring(i)
			}
			obj_params[i] = {
				"ref",
				'_p_' .. tostring(i)
			}
		end
		local i = new_order
		obj_params[i] = {
			"ref",
			'_p_' .. tostring(i)
		}
	end
	local NP = { }
	setmetatable(NP, {
		__newindex = function()
			return error("")
		end
	})
	for _index_0 = 1, #value do
		local the_value = value[_index_0]
		local param_type = the_value[1]
		the_order = the_order + 1
		local sp_cur = (param_type == 'add_set') and NP or {
			'_p_' .. tostring(#src_params + 1)
		}
		local op_cur = {
			"ref",
			'_p_' .. tostring(the_order)
		}
		append(src_params, sp_cur)
		obj_params[the_order] = op_cur
		for _index_1 = 2, #the_value do
			local item = the_value[_index_1]
			local _exp_0 = item[1]
			if 'order' == _exp_0 then
				local new_order = get_value(item[2])
				assert(new_order >= the_order, table.concat({
					"the_order:",
					tostring(the_order),
					"new_order:",
					tostring(new_order)
				}))
				add_curorder(new_order)
				local topop = (new_order == the_order)
				the_order = new_order
				sp_cur = src_params[#src_params]
				if (topop) then
					src_params[#src_params] = NP
				end
				local pname = '_p_' .. tostring(#src_params)
				sp_cur[1] = pname
				obj_params[the_order] = {
					"ref",
					pname
				}
			elseif 'default' == _exp_0 then
				sp_cur[2] = item[2]
			elseif 'set_obj' == _exp_0 then
				obj_params[the_order] = item[2]
			end
		end
	end
	if (obj_params[#obj_params] == '...') then
		append(src_params, {
			"..."
		})
	end
	for i = #src_params, 1, -1 do
		if (src_params[i] == NP) then
			table.remove(src_params, i)
		end
	end
	return {
		src_params,
		obj_params
	}
end
local build_lazyfunc
build_lazyfunc = function(value)
	local func, src_params, obj_params
	func, src_params, obj_params = value[1], value[2][1], value[2][2]
	return {
		"fndef",
		src_params,
		{ },
		"slim",
		{
			{
				"chain",
				func,
				{
					"call",
					obj_params
				}
			}
		}
	}
end
local build_flowprocmap
build_flowprocmap = function(value)
	local build_callfunc
	build_callfunc = function(fn, params)
		return {
			"chain",
			fn,
			{
				"call",
				{
					params
				}
			}
		}
	end
	local build_func
	build_func = function(fn, params)
		return {
			"fndef",
			{
				{
					params
				}
			},
			{ },
			"slim",
			{
				fn
			}
		}
	end
	local direction, values
	direction, values = value[1], value[2]
	if (direction == 'left') then
		values = reverse(values)
		return build_flowprocmap({
			'right',
			values
		})
	end
	local params = '...'
	for _index_0 = 1, #values do
		local _continue_0 = false
		repeat
			local func = values[_index_0]
			if (func == '^') then
				_continue_0 = true
				break
			end
			params = build_callfunc(func, params)
			_continue_0 = true
		until true
		if not _continue_0 then
			break
		end
	end
	local fncall = params
	local func = build_func(fncall, '...')
	func = {
		"parens",
		func
	}
	return func
end
local organize_switch_table
organize_switch_table = function(value)
	local input_param, secondary_params, indexable_value
	input_param, secondary_params, indexable_value = value[1], value[2], value[3]
	if indexable_value[1] ~= 'ref' then
		indexable_value = {
			'parens',
			indexable_value
		}
	end
	return {
		"chain",
		indexable_value,
		{
			"index",
			input_param
		},
		{
			"call",
			secondary_params
		}
	}
end
local trans_parens_exp
trans_parens_exp = function(value)
	local op, vt
	op, vt = value[1], value[2]
	for i = 1, #vt - 1 do
		insert(vt, i * 2, op)
	end
	insert(vt, 1, "exp")
	local newvalue = {
		"parens",
		vt
	}
	return newvalue
end
return {
	Indent = Indent,
	Cut = Cut,
	ensure = ensure,
	extract_line = extract_line,
	mark = mark,
	pos = pos,
	flatten_or_mark = flatten_or_mark,
	is_assignable = is_assignable,
	check_assignable = check_assignable,
	format_assign = format_assign,
	format_single_assign = format_single_assign,
	sym = sym,
	symx = symx,
	simple_string = simple_string,
	wrap_func_arg = wrap_func_arg,
	join_chain = join_chain,
	wrap_decorator = wrap_decorator,
	check_lua_string = check_lua_string,
	self_assign = self_assign,
	conv_to_foreach = conv_to_foreach,
	build_exch_params = build_exch_params,
	build_lazyfunc = build_lazyfunc,
	build_flowprocmap = build_flowprocmap,
	organize_switch_table = organize_switch_table,
	got = got,
	show_line_position = show_line_position,
	trans_parens_exp = trans_parens_exp
}
