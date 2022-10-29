%{
    #include <iostream> 
    #include <stack>
    #include <fstream>
    #include <map>
    #include "lex.yy.c"
    using namespace std;
    bool flag = false;
    void yyerror(const char *str);

    map<string, string> m;
    ofstream data("compiler-output/data.txt");
    ofstream code("compiler-output/assembly-code.txt");
    ifstream imap("encoding-table.txt");

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
    
%}

%union  { // typedef struct {} yylval;
    int value;
    char* identifier;
    Wrapper* wrapper;
}

%locations
%token ASSIGN COLON END GLOBAL ID INT_CONST LEFT_PAREN MINUS PLUS RIGHT_PAREN SEMICOLON

%left PLUS MINUS
%left AND OR

%start S

%%
S: prog {flag = true; return 0;}

prog: GLOBAL stmtListO END
;

stmtListO: stmtList
|
;

stmtList: stmtList SEMICOLON stmt
| stmt
;

stmt: assignmentStmt
;

assignmentStmt: id ASSIGN exp {
    string address = getDataAddress();
    // R2 is base register
    code << "LOAD R7 " << $<wrapper>3->label << " R2" << endl;
    code << "STORE R7 " << address << " R2" << endl;  
    m[$<wrapper>1->label] = address;
} 
;

id: ID {
    string s = $<identifier>1;
    $<wrapper>$ = new Wrapper(s);
}
;

exp: exp PLUS exp {
        string address = getDataAddress();

        if(m.find($<wrapper>1->label) != m.end()) {
            code << "LOAD R1 " << m[$<wrapper>1->label] << " R2" << endl;
        } else {
            code << "LOAD R1 " << $<wrapper>1->label << " R2" << endl;
        }
        
        if(m.find($<wrapper>3->label) != m.end()) {
            code << "LOAD R3 " << m[$<wrapper>3->label] << " R2" << endl;
        } else {
            code << "LOAD R3 " << $<wrapper>3->label << " R2" << endl;
        }
        
        code << "ADD R1 R1 R3" << endl;
        code << "STORE R1 " << address << " R2" << endl;

        // We need to generate a t0 variable for storing the results as well
        Wrapper* temp  = new Wrapper(address);
        $<wrapper>$ = temp;
}
| exp MINUS exp {
    string address = getDataAddress();

        if(m.find($<wrapper>1->label) != m.end()) {
            code << "LOAD R1 " << m[$<wrapper>1->label] << " R2" << endl;
        } else {
            code << "LOAD R1 " << $<wrapper>1->label << " R2" << endl;
        }
        
        if(m.find($<wrapper>3->label) != m.end()) {
            code << "LOAD R3 " << m[$<wrapper>3->label] << " R2" << endl;
        } else {
            code << "LOAD R3 " << $<wrapper>3->label << " R2" << endl;
        }
        
        code << "SUB R1 R1 R3" << endl;
        code << "STORE R1 " << address << " R2" << endl;

        // We need to generate a t0 variable for storing the results as well
        Wrapper* temp  = new Wrapper(address);
        $<wrapper>$ = temp;
} 
| LEFT_PAREN exp RIGHT_PAREN {
    $<wrapper>$ = $<wrapper>2;
}
| id {
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

%%

int main(){
    int token;
    yyin = fopen("input-code/input1.txt", "r");
    yyparse();
    cout << (flag ? "Accepted": "Rejected") << endl;
    return 0;
}

void yyerror(const char *str) 
{ 
	printf("%s at line: %d\n", str, yylineno);
} 