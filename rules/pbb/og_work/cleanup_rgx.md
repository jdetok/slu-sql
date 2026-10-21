## move ) at end of block to new line
`([)]\s*\n+)(^\s*\t*[)(?=^[\t][^A-Za-z-])`
`\n)\n`

## move ( at beginning new line to after the = at end of last line 
`=(\s*\n+\()`
`= (\n`

## remove space preceeding END = RORALGS_KEY_N
`^[\s\t]+END =`
`END =`

## remove new line after WHERE
`WHERE[\s\t]*\n`
`WHERE `
