IMPORTANT! IF YOU WANT TO SHARE COMPESSOR PRIVATLY, MY COMPILED CASE HASNT BEEN COMPRESSED WHILE COMPILING, SO SOURCES CAN BE TAKEN BY ANYONE!

ahk compressor by lex
discord: lexx#0457
version: beta_1.1

whats new?
- added more compressing operators ({a := b} will be {a:=b}, {x >>= y} = {x>>=y} etc.)
- compressed script won't have #CommentFlag command (mostly because all comments will be removed, in the source you can change if you want)
- auto-adapt if script changes his comment flag {#CommentFlag, <string>}
- fixed (probably) bug with deleting code (when compressor tries to remove a comment from a working line, example (ternary): { f := (x > y) ? "f" : "d" ; <comment> })
- if user use CommentFlag //, it checks whether its a link {https://} or a comment && check whether its a function or operator {x // y} (with functions and operators it doesnt work perfectly, be careful)
- added removing large comments {/* .... */}
- removes almost every useless space (probably, too, in the future will improve)

hopefully you enjoyed!