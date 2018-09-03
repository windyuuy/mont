
import unpack from require "moonscript.util"
import P, C, S, Cp, Cmt, V from require "lpeg"
import ntype from require "moonscript.types"
import Space from require "moonscript.parse.literals"

-- dump=->

insert=table.insert
append=insert
reverse=(t)->
	newt={}
	for i=1,#t do
		insert newt,1,t[i]
	newt

-- captures an indentation, returns indent depth
Indent = C(S"\t "^0) / (str) ->
	with sum = 0
		for v in str\gmatch "[\t ]"
			switch v
				when " "
					sum += 1
				when "\t"
					sum += 4


-- causes pattern in progress to be rejected
-- can't have P(false) because it causes preceding patterns not to run
Cut = P -> false

-- ensures finally runs regardless of whether pattern fails or passes
ensure = (patt, finally) ->
	patt * finally + finally * Cut

-- take rest of line from pos out of str
extract_line = (str, start_pos) ->
	str = str\sub start_pos
	if m = str\match "^(.-)\n"
		return m

	str\match "^.-$"

-- print the line with a token showing the position
show_line_position = (str, pos, context=true) ->
	lines = { {} }
	for c in str\gmatch "."
		lines[#lines] or= {}
		table.insert lines[#lines], c
		if c == "\n"
			lines[#lines + 1] = {}

	for i, line in ipairs lines
		lines[i] = table.concat line

	local out

	remaining = pos - 1
	for k, line in ipairs lines
		if remaining < #line
			left = line\sub 1, remaining
			right = line\sub remaining + 1
			out = {
				"#{left}◉#{right}"
			}

			if context
				if before = lines[k - 1]
					table.insert out, 1, before

				if after = lines[k + 1]
					table.insert out, after

			break
		else
			remaining -= #line


	return "-" unless out

	out = table.concat out
	(out\gsub "\n*$", "")

-- used to identify a capture with a label
mark = (name) ->
	(...) -> {name, ...}

-- wraps pattern to capture pos into node
-- pos is the character offset from the buffer where the node was parsed from.
-- Used to generate error messages
pos = (patt) ->
	(Cp! * patt) / (pos, value) ->
		if type(value) == "table"
			value[-1] = pos
		value

-- generates a debug pattern that always succeeds and prints out where we are
-- in the buffer with a label
got = (what, context=true) ->
	Cmt "", (str, pos) ->
		print "++ got #{what}", "[#{show_line_position str, pos, context}]"
		true

-- converts 1 element array to its value, otherwise marks it
flatten_or_mark = (name) ->
	(tbl) ->
		return tbl[1] if #tbl == 1
		table.insert tbl, 1, name
		tbl

-- determines if node is able to be on left side of assignment
is_assignable = do
	chain_assignable = { index: true, dot: true, slice: true }

	(node) ->
		return false if node == "..."
		switch ntype node
			when "ref", "self", "value", "self_class", "table"
				true
			when "chain"
				chain_assignable[ntype node[#node]]
			else
				false

check_assignable = (str, pos, value) ->
	if is_assignable value
		true, value
	else
		false

-- joins the two parts of an assign parse into a single node
format_assign = do
	flatten_explist = flatten_or_mark "explist"

	(lhs_exps, assign) ->
		unless assign
			return flatten_explist lhs_exps

		for assign_exp in *lhs_exps
			unless is_assignable assign_exp
				error {assign_exp, "left hand expression is not assignable"}

		t = ntype assign
		switch t
			when "assign"
				{"assign", lhs_exps, unpack assign, 2}
			when "update"
				{"update", lhs_exps[1], unpack assign, 2}
			else
				error "unknown assign expression: #{t}"

-- helper for if statement, which only has single lhs
format_single_assign = (lhs, assign) ->
	if assign
		format_assign {lhs}, assign
	else
		lhs


-- a symbol
sym = (chars) -> Space * chars
-- a symbol that doesn't accept whitespace before it
symx = (chars) -> chars

-- a constructor for quote delimited strings
simple_string = (delim, allow_interpolation) ->
	inner = P("\\#{delim}") + "\\\\" + (1 - P delim)

	inner = if allow_interpolation
		interp = symx'#{' * V"Exp" * sym'}'
		(C((inner - interp)^1) + interp / mark"interpolate")^0
	else
		C inner^0

	C(symx(delim)) * inner * sym(delim) / mark"string"

-- wraps a single value in format needed to be passed as function arguments
wrap_func_arg = (value) -> {"call", {value}}

-- chains are parsed in two captures, the chain and then the open arguments
-- if there are open arguments, then append them to the end of the chain as a call
join_chain = (callee, args) ->
	return callee if #args == 0
	args = {"call", args}

	if ntype(callee) == "chain"
		table.insert callee, args
		return callee

	{"chain", callee, args}

-- constructor for decorator node
wrap_decorator = (stm, dec) ->
	return stm unless dec
	{"decorated", stm, dec}

check_lua_string = (str, pos, right, left) ->
	#left == #right

-- constructor for :name self assignments in table literals
self_assign = (name, pos) ->
	{{"key_literal", name}, {"ref", name, [-1]: pos}}

conv_to_foreach= (value)->
	{p1,direction,paramcount,p2,mark}=value
	t,f=p1,p2
	paramcount=tonumber(paramcount[2]) or 2
	paramlist={}
	callparams={}
	for i=1,paramcount do
		paramname='_vn_'..tostring(i)
		paramlist[#paramlist+1]=paramname
		callparams[#callparams+1]={"ref",paramname}
	
	-- if(mark=='pack')
	-- 	{
	-- 		"comprehension",
	-- 		{
	-- 			"chain",
	-- 			f,
	-- 			{
	-- 				"call",
	-- 				{
	-- 					{
	-- 						"ref",
	-- 						"v",
	-- 					},
	-- 					{
	-- 						"ref",
	-- 						"i",
	-- 					},
	-- 				},
	-- 			},
	-- 		},
	-- 		{
	-- 			{
	-- 				"foreach",
	-- 				{
	-- 					"v",
	-- 					"i",
	-- 				},
	-- 				{
	-- 					"unpack",
	-- 					t,
	-- 				},
	-- 			},
	-- 		},
	-- 	}
	-- else
	{
		"comprehension",
		{
			"chain",
			{
				"parens",
				f,
			},
			{
				"call",
				callparams,
			},
		},
		{
			{
				"foreach",
				paramlist,
				{
					"unpack",
					t,
				},
			},
		},
	}
	
get_value=(node using nil)->
	ntype=node[1]
	switch ntype
		when 'number'
			tonumber(node[2])
		when 'string'
			tostring(node[2])
		when 'ref'
			node[2]
	
build_exch_params=(value)->
	src_params={}
	obj_params={}
	
	the_order=0
	add_curorder=(new_order)->
		for i=the_order+1,new_order-1
			src_params[#src_params+1]={'_p_'..tostring(i)}
			obj_params[i]={"ref",'_p_'..tostring(i)}
			
		i=new_order
		obj_params[i]={"ref",'_p_'..tostring(i)}

	NP={}
	setmetatable(NP, {__newindex:->error("")})
	for the_value in *value
		param_type=the_value[1]
		the_order+=1
		sp_cur=(param_type=='add_set') and NP or {'_p_'..tostring(#src_params+1)}
		op_cur={"ref",'_p_'..tostring(the_order)}
		-- src_params[the_order]=sp_cur
		append src_params,sp_cur
		obj_params[the_order]=op_cur
		-- print 'start'
		for item in *the_value[2,]
			switch item[1]
				when 'order'
					new_order=get_value item[2]
					assert(new_order>=the_order,table.concat{"the_order:",tostring(the_order),"new_order:",tostring(new_order)})
					add_curorder new_order
					topop=(new_order==the_order)
					the_order=new_order
					sp_cur=src_params[#src_params]
					if(topop)
						src_params[#src_params]=NP
					pname='_p_'..tostring(#src_params)
					sp_cur[1]=pname
					obj_params[the_order]={"ref",pname}
					
				when 'default'
					sp_cur[2]=item[2]
					
				when 'set_obj'
					obj_params[the_order]=item[2]
					
	-- append src_params,{"..."}
	-- append obj_params,"..."
	if(obj_params[#obj_params]=='...')
		append src_params,{"..."}
		
	for i=#src_params,1,-1
		if(src_params[i]==NP)
			table.remove(src_params,i)

	{src_params,obj_params}
	
build_lazyfunc=(value)->
	-- print 'build_lazyfunc'
	-- print dump value
	{func,{src_params,obj_params}}=value
	{
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
					obj_params,
				},
			},
		},
	}
	
build_flowprocmap=(value)->
	-- print "build_flowprocmap"
	-- print dump value
	
	build_callfunc=(fn,params)->
		{
			"chain",
			fn,
			{
				"call",
				{
					params
				},
			},
		}
	build_func=(fn,params)->
		{
			"fndef",
			{
				{
					params,
				},
			},
			{ },
			"slim",
			{
				fn
			},
		}
	
	{direction,values}=value
	if(direction=='left')
		values=reverse(values)
		return build_flowprocmap({'right',values})
		
	params='...'
	for func in *values
		continue if(func=='^')
		params=build_callfunc func,params
	fncall=params
	func=build_func fncall,'...'
	func={"parens",func}
	-- print 'builtfunc'
	-- print dump func
	func
	
organize_switch_table=(value)->
	-- print "organize_switch_table"
	-- print dump value
	{input_param,secondary_params,indexable_value}=value
	
	if indexable_value[1]~='ref'
		indexable_value={'parens',indexable_value}
		
	{
		"chain",
		indexable_value,
		{
			"index",
			input_param,
		},
		{
			"call",
			secondary_params,
		},
	}
	
	-- {
	-- 	"switch",
	-- 	input_param,
	-- 	{
	-- 		{
	-- 			"case",
	-- 			{
	-- 				{
	-- 					[-1] = 51,
	-- 					"ref",
	-- 					"true",
	-- 				},
	-- 			},
	-- 			{
	-- 				{
	-- 					[-1] = 59,
	-- 					"number",
	-- 					"32",
	-- 				},
	-- 			},
	-- 		},
	-- 	},
	-- }

trans_parens_exp=(value)->
	{op,vt}=value
	for i=1,#vt-1
		insert(vt,i*2,op)
	insert(vt,1,"exp")
	
	newvalue={
		"parens",
		vt
	}
	return newvalue

-- {
--         {
--                 [-1] = 7,
--                 "number",
--                 "1",
--         },
--         "-",
--         {
--                 [-1] = 9,
--                 "number",
--                 "2",
--         },
--         "+",
--         {
--                 [-1] = 11,
--                 "number",
--                 "3",
--         },
-- }

{ :Indent, :Cut, :ensure, :extract_line, :mark, :pos, :flatten_or_mark,
	:is_assignable, :check_assignable, :format_assign, :format_single_assign,
	:sym, :symx, :simple_string, :wrap_func_arg, :join_chain, :wrap_decorator,
	:check_lua_string, :self_assign, :conv_to_foreach, :build_exch_params,
	:build_lazyfunc, :build_flowprocmap, :organize_switch_table,:got, :show_line_position,
	:trans_parens_exp
}
