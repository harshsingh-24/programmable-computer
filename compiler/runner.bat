yacc parse.y -d 
lex lex.l
g++ parse.tab.c -o parser
start /b /wait parser.exe
g++ memory-image-generator.cpp -o generator
start /b /wait generator.exe
pause