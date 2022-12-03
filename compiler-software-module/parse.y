%{
    #include <iostream> 
    #include <stack>
    #include <fstream>
    #include <map>
    #include "fileutils.hpp"
    #include "lex.yy.c"
    using namespace std;
    void yyerror(const char *str);

    // flags
    bool syntaxFlag = false;
    bool semanticFlag = true;

    map<string, string> m;
    map<string, string> decls;
    stack<string> st;

    ofstream data("compiler-output/data.txt");
    ofstream code("compiler-output/intermediate-assembly-code.txt");
    ofstream declsAddress("compiler-output/declarations-address-mapping.txt");
    ifstream imap("encoding-table.txt");

    // Data starts from memory address 256(0x100) in processor
    int data_address = 256;
    string getDataAddress() {
        int temp = data_address;
        data_address += 1;
        return to_string(temp);
    }

    int k = 0;
    string generateKey() {
        string ans = "t" + to_string(k);
        k++;
        return ans;
    }

    int l = 0;
    string lineTagGenerate() {
        string ans = "L" + to_string(l);
        l++;
        return ans;
    }

    Wrapper* printOperationCycle(string wrapper1Label, string wrapper3Label, string operation) {
        string address = getDataAddress();

        if(m.find(wrapper1Label) != m.end()) {
            code << "LOAD R1 " << m[wrapper1Label] << " R2" << endl;
        } else {
            code << "LOAD R1 " << wrapper1Label << " R2" << endl;
        }
        
        if(m.find(wrapper3Label) != m.end()) {
            code << "LOAD R3 " << m[wrapper3Label] << " R2" << endl;
        } else {
            code << "LOAD R3 " << wrapper3Label << " R2" << endl;
        }
        
        code << operation << " R1 R1 R3" << endl;
        code << "STORE R1 " << address << " R2" << endl;

        Wrapper* temp  = new Wrapper(address);
        return temp;
    }
%}

%union  { // typedef struct {} yylval;
    int value;
    char* identifier;
    Wrapper* wrapper;
}

%locations
%token AND ASSIGN COMMA COLON DEF ELSE END EQ GLOBAL GE GT ID IF INT INT_CONST LEFT_PAREN LE LT MINUS NE OR PLUS RIGHT_PAREN SEMICOLON WHILE

%left PLUS MINUS
%left AND OR

%start S

%%
S: prog {syntaxFlag = true; return 0;}

prog: GLOBAL declList stmtListO END
;

declList: decl declList
|
;

decl: DEF typeList END
;

typeList: typeList SEMICOLON varList COLON type
| varList COLON type {

}
;

type: INT
;

varList: id COMMA varList {
    string address = getDataAddress();
    declsAddress << $<wrapper>1->label << " " << address << endl;
    decls[$<wrapper>1->label] = address;
}
| id {
    string address = getDataAddress();
    declsAddress << $<wrapper>1->label << " " << address << endl;
    decls[$<wrapper>1->label] = address; // "a = 1024"
}
;

stmtListO: stmtList
|
;

stmtList: stmtList SEMICOLON stmt
| stmt
;

stmt: assignmentStmt
| ifStmt
| whileStmt
;

// TODO: IF STMT, WHILE STMT and bExp relop bExp, Add Jump Statement in processor
// TODO: Refactor the redundant code

// if Statement -> JUMP R2; and TODO: JUMP R1, R2
assignmentStmt: id ASSIGN exp {

    if(decls.find($<wrapper>1->label) == decls.end()) {
        // identifier variable not declared
        semanticFlag = false;
        string error = $<wrapper>1->label + " not declared";
        yyerror(error.c_str());
    }

    string address = decls[$<wrapper>1->label];
    // R2 is base register
    code << "LOAD R7 " << $<wrapper>3->label << " R2" << endl;
    code << "STORE R7 " << address << " R2" << endl;  
    m[$<wrapper>1->label] = address;
} 
;

ifStmt: IF {
    string lineNumber1 = lineTagGenerate();
    string lineNumber2 = lineTagGenerate();

    st.push(lineNumber2);
    st.push(lineNumber1);
    st.push(lineNumber2);
    st.push(lineNumber1);
} 
bExp {
    string bExpResult = $<wrapper>3->label;
    code << "LOAD R7 " << bExpResult << " R2" << endl;
    code << "MVI R6 " << st.top() << endl;
    code << "JZ R7 R6" << endl; // We will substitute label with address for PC later.
    st.pop();
}
COLON stmtList {
    code << "MVI R6 " << st.top() << endl;
    code << "JUMP R6" << endl; 
    st.pop();
    code << st.top() << " :" << endl;
    st.pop();
} 
elsePart {
    code << st.top() << " :" << endl;
    st.pop();
}
END
;

elsePart: ELSE stmtList 
| 
{
    code << endl;
}
;

whileStmt: WHILE {
    string lineNumber1 = lineTagGenerate();
    string lineNumber2 = lineTagGenerate();

    code << lineNumber1 << " :" << endl;
    st.push(lineNumber2);
    st.push(lineNumber1);
    st.push(lineNumber2);
}
bExp {
    string bExpResult = $<wrapper>3->label;
    code << "LOAD R7 " << bExpResult << " R2" << endl;
    code << "MVI R6 " << st.top() << endl;
    code << "JZ R7 R6" << endl; // We will substitute label with address for PC later.
    st.pop();
}
COLON stmtList {
    code << "MVI R6 " << st.top() << endl;
    code << "JUMP R6" << endl; 
    st.pop();
    code << st.top() << " :" << endl;
    st.pop(); 
} 
END
;

exp: exp PLUS exp {
    $<wrapper>$ = printOperationCycle($<wrapper>1->label, $<wrapper>3->label,"ADD"); 
}
| exp MINUS exp {
    $<wrapper>$ = printOperationCycle($<wrapper>1->label, $<wrapper>3->label,"SUB");
} 
| LEFT_PAREN exp RIGHT_PAREN {
    $<wrapper>$ = $<wrapper>2;
}
| id {
    if(decls.find($<wrapper>1->label) == decls.end()) {
        // ID not declared
        semanticFlag = false;
        string error = $<wrapper>1->label + " not declared";
        yyerror(error.c_str());
    }
    $<wrapper>$ = $<wrapper>1;
}
| INT_CONST {
    string address = getDataAddress();
    Wrapper* temp  = new Wrapper(address);
    m[address] = address;
    $<wrapper>$ = temp;
    data << address << " " << $<value>1 << endl;
}
;

/* Binary Expression Support - AND, OR
   Relational Ops - Greater than(>), Greater than Equal to(>=), Less than(<), Less than Equal to(<=), Equal to(==)
 */
bExp: bExp OR bExp {
    $<wrapper>$ = printOperationCycle($<wrapper>1->label, $<wrapper>3->label,"OR");
}
| bExp AND bExp {
    $<wrapper>$ = printOperationCycle($<wrapper>1->label, $<wrapper>3->label,"AND");
}
| LEFT_PAREN bExp RIGHT_PAREN {
    $<wrapper>$ = $<wrapper>2;
}
| exp GT exp {
    $<wrapper>$ = printOperationCycle($<wrapper>1->label, $<wrapper>3->label,"GT");
}
| exp LT exp {
    $<wrapper>$ = printOperationCycle($<wrapper>1->label, $<wrapper>3->label,"LT");
}
| exp EQ exp {
    $<wrapper>$ = printOperationCycle($<wrapper>1->label, $<wrapper>3->label,"EQ");
} 
| exp GE exp {
    // GE is evaluated as (exp GT exp) OR (exp EQ exp)
    Wrapper* greaterThanWrapper = printOperationCycle($<wrapper>1->label, $<wrapper>3->label,"GT");
    Wrapper* equalToWrapper = printOperationCycle($<wrapper>1->label, $<wrapper>3->label,"EQ");
    $<wrapper>$ = printOperationCycle(greaterThanWrapper->label, equalToWrapper->label,"OR");
} 
| exp LE exp {
    Wrapper* lessThanWrapper = printOperationCycle($<wrapper>1->label, $<wrapper>3->label,"LT");
    Wrapper* equalToWrapper = printOperationCycle($<wrapper>1->label, $<wrapper>3->label,"EQ");
    $<wrapper>$ = printOperationCycle(lessThanWrapper->label, equalToWrapper->label,"OR");
}
;
// add support for NE

id: ID {
    string s = $<identifier>1;
    $<wrapper>$ = new Wrapper(s);
}
;

%%

int main(){

    FileUtils fileutils;

    int token;
    yyin = fopen("input-program/input1.txt", "r");
    yyparse();
    cout << (syntaxFlag ? "Grammar is Syntactically Correct": "Grammar is Syntactically Incorrect") << endl;
    cout << (semanticFlag ? "Grammar is Semantically Correct": "Grammar is Semantically Incorrect") << endl;
    code << "HLT" << endl;

    fileutils.ofstreamClose(data);
    fileutils.ofstreamClose(code);
    fileutils.ofstreamClose(declsAddress);
    fileutils.instreamClose(imap);

    if(syntaxFlag && semanticFlag)
        fileutils.substituteLabelWithAddress();
    return 0;
}

void yyerror(const char *str) 
{ 
	printf("%s at line: %d\n", str, yylineno);
} 