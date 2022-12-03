yacc parse.y -d 
lex lex.l
g++ parse.tab.c -o parser
start /b /wait parser.exe
g++ memory-image-generator.cpp -o memory-image-generator
start /b /wait memory-image-generator.exe
pause