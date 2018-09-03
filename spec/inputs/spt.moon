+{
	*{
		-{
			&{
				^ /
			}
		}
	}
}

EmptyLine^0 * sym"lkwjeflk" Advance * Ct(SwitchCase * (Break^1 * SwitchCase)^0 * (Break^1 * SwitchElse)^-1) * PopIndent / lkjwe

{
	EmptyLine[0,] sym"lkjwef" Advance 
	{
		SwitchCase 
		{
			Break[1,] SwitchCase
		}[0,] 
		{
			Break[1,] SwitchElse
		}^-1
	} PopIndent
} / lkjwe