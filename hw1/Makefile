tokens : lex.yy.c
	gcc lex.yy.c -o ba -lfl

lex.yy.c : final.lex
	flex final.lex

clean :
	rm ba lex.yy.c
