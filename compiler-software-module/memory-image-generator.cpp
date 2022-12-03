#include <iostream>
#include <fstream>
#include <sstream>
#include <unordered_map>
#include <map>
#include <string>
#include <algorithm>
using namespace std;

ifstream memory("compiler-output/data.txt");
ifstream input("compiler-output/final-assembly-code.txt");
ifstream encode("encoding-table.txt");
ofstream output("compiler-output/memory-image");

map<string, string> encoding;
map<int, string> memoryData;

void createMap(unordered_map<string, char> *um)
{
    (*um)["0000"] = '0';
    (*um)["0001"] = '1';
    (*um)["0010"] = '2';
    (*um)["0011"] = '3';
    (*um)["0100"] = '4';
    (*um)["0101"] = '5';
    (*um)["0110"] = '6';
    (*um)["0111"] = '7';
    (*um)["1000"] = '8';
    (*um)["1001"] = '9';
    (*um)["1010"] = 'A';
    (*um)["1011"] = 'B';
    (*um)["1100"] = 'C';
    (*um)["1101"] = 'D';
    (*um)["1110"] = 'E';
    (*um)["1111"] = 'F';
}
 
// function to find hexadecimal
// equivalent of binary
string binaryToHex(string bin)
{
    int l = bin.size();
    int t = bin.find_first_of('.');
     
    // length of string before '.'
    int len_left = t != -1 ? t : l;
     
    // add min 0's in the beginning to make
    // left substring length divisible by 4
    for (int i = 1; i <= (4 - len_left % 4) % 4; i++)
        bin = '0' + bin;
     
    // if decimal point exists   
    if (t != -1)   
    {
        // length of string after '.'
        int len_right = l - len_left - 1;
         
        // add min 0's in the end to make right
        // substring length divisible by 4
        for (int i = 1; i <= (4 - len_right % 4) % 4; i++)
            bin = bin + '0';
    }
     
    // create map between binary and its
    // equivalent hex code
    unordered_map<string, char> bin_hex_map;
    createMap(&bin_hex_map);
     
    int i = 0;
    string hex = "";
     
    while (1)
    {
        // one by one extract from left, substring
        // of size 4 and add its hex code
        hex += bin_hex_map[bin.substr(i, 4)];
        i += 4;
        if (i == bin.size())
            break;
             
        // if '.' is encountered add it
        // to result
        if (bin.at(i) == '.')   
        {
            hex += '.';
            i++;
        }
    }
     
    // required hexadecimal number
    return hex;   
}

string decimalToBinary(int num)
{
    string str;
      while(num) {
      if(num & 1)
        str+='1';
      else // 0
        str+='0';
      num >>= 1; 
    }   
    
    int n = str.size();
    reverse(str.begin(), str.end());
    
    string ans = "";
    for(int i=1; i<=16-n; i++) {
        ans = ans + "0";
    }

    ans = ans + str;

    return ans;
}

string decimalToHex(int n)
{
    // ans string to store hexadecimal number
    string ans = "";
   
    while (n != 0) {
        // remainder variable to store remainder
        int rem = 0;
         
        // ch variable to store each character
        char ch;
        // storing remainder in rem variable.
        rem = n % 16;
 
        // check if temp < 10
        if (rem < 10) {
            ch = rem + 48;
        }
        else {
            ch = rem + 55;
        }
         
        // updating the ans string with the character variable
        ans += ch;
        n = n / 16;
    }
     
    // reversing the ans string to get the final result
    int i = 0, j = ans.size() - 1;
    while(i <= j)
    {
      swap(ans[i], ans[j]);
      i++;
      j--;
    }
    return ans;
}

void parseAssemblyCode(string s) {

    string ans;

    string opcode = "00000";
    string dr = "00000";
    string sr1 = "00000";
    string sr2 = "00000";
    string iv = "00000000000";
    string ei = "0";
    
    stringstream ss(s);

    string operation;
    ss >> operation;

    if(operation == "HLT") {
        ans = binaryToHex(opcode + dr + sr1 + sr2 + iv + ei);
    } else if(operation == "MVI") {
        opcode = encoding[operation];
        // Get 16-bit Intermediate Value
        string destination_register;
        int intermediate_value;
        ss >> destination_register >> intermediate_value;
        dr = encoding[destination_register];
        iv = decimalToBinary(intermediate_value);
        ei = "1";

        ans = binaryToHex(opcode + dr + sr1 + iv + ei);
    } else if(operation == "JUMP") {
        opcode = encoding[operation];
        string source_register_2;
        ss >> source_register_2;
        sr2 = encoding[source_register_2];

        ans = binaryToHex(opcode + dr + sr1 + sr2 + iv + ei);
    } else if(operation == "JZ") {
        opcode = encoding[operation];
        string source_register_1, source_register_2;
        ss >> source_register_1 >> source_register_2;
        sr1 = encoding[source_register_1];
        sr2 = encoding[source_register_2];

        ans = binaryToHex(opcode + dr + sr1 + sr2 + iv + ei);
    } else {
        opcode = encoding[operation];

        string destination_register;
        ss >> destination_register;
        dr = encoding[destination_register];

        if(operation == "LOAD" || operation == "STORE") {
            int intermediate_value;
            ss >> intermediate_value;
            iv = decimalToBinary(intermediate_value);

            string source_register_1;
            ss >> source_register_1;
            sr1 = encoding[source_register_1];
            ei = "1";

            ans = binaryToHex(opcode + dr + sr1 + iv + ei);
        } else if (operation == "ADD" || operation == "SUB" || operation == "AND" || operation == "OR" || 
                   operation == "GT" || operation == "LT" || operation == "GE" || operation == "LE" || operation == "EQ") {
            string source_register_1;
            ss >> source_register_1;
            sr1 = encoding[source_register_1];

            string source_register_2;
            ss >> source_register_2;
            sr2 = encoding[source_register_2];

            ans = binaryToHex(opcode + dr + sr1 + sr2 + iv + ei);
        }
        else {
            // ADI, SUI
            string source_register_1;
            ss >> source_register_1;
            sr1 = encoding[source_register_1];

            int intermediate_value;
            ss >> intermediate_value;
            iv = decimalToBinary(intermediate_value);
            ei = "1";

            ans = binaryToHex(opcode + dr + sr1 + iv + ei);
        }
    }
    
    output << ans << " ";   
}

void getEncodingInMap(string s) {
    if(s.size() == 0 || s[0] == '/') {
        return;
    }
    stringstream ss(s);

    string key, value;
    ss >> key;
    ss >> value;

    encoding[key] = value;
}

void printMap() {
    for(auto i: encoding) {
        cout << i.first << " " << i.second << endl;
    }
}

void parseMemoryData(string s) {
    stringstream ss(s);

    int key, value;
    ss >> key;
    ss >> value;

    memoryData[key] = decimalToHex(value);
}

int main() {

    cout << "Memory Image Generator starting" << endl;
    string s;
    while(getline(encode, s)) {
        getEncodingInMap(s);
    }
    // printMap();

    // cout << decimalToHex(31) << endl;
    output << "v2.0 raw" << endl;

    int count = 0;
    while(getline(input, s)) {
        count++;
        parseAssemblyCode(s);
    }

    while(getline(memory, s)) {
        parseMemoryData(s);
    }

    for(auto i: memoryData) {
        int diff = i.first - count;
        if(diff > 0)
            output << diff << "*0" << " ";
        output << i.second << " ";
        count = i.first + 1;
    }

    cout << "Memory Image Generator successfully executed" << endl;
}