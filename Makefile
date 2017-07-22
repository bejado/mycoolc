main : lex.yy.c
	gcc lex.yy.c -ll

lex.yy.c : cool.lex
	flex cool.lex


