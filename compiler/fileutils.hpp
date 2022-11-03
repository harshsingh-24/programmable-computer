#include <iostream>
#include <fstream>
#include <map>
#include <string>
#include <sstream>
#include <set>
using namespace std;
class FileUtils {
public: 
    // label stores the address of expression/literal evaluated
    void instreamClose(ifstream& file) {
        cout << "Input File Closed" << endl;
        file.close();
    }
    
    void ofstreamClose(ofstream& file) {
        cout << "Output File Closed" << endl;
        file.close();
    }

    void substituteLabelWithAddress() {
        ifstream input("compiler-output/intermediate-assembly-code.txt");
        ofstream output("compiler-output/final-assembly-code.txt");

        getLabelToAddressMap();

        string s;
        while(getline(input, s)) {
            stringstream ss(s);
            string instruction;
            ss >> instruction;

            if(allowedInstructions.find(instruction) == allowedInstructions.end()) {
                continue;
            }
            else if(instruction == "MVI") {
                string registerNo, label;
                ss >> registerNo >> label;
                output << "MVI R6 " << labelToAddressMap[label] << endl;
            } else {
                output << s << endl;
            }
        }
    }
private: 

    set<string> allowedInstructions = {"HLT", "MOV", "MVI", "LOAD", "STORE", "ADD", "ADI", "SUB", "SUI", "AND", "ANI", "OR", "ORI", "GT", "EQ", "LT", "JUMP", "JZ"};
    map<string, int> labelToAddressMap;
    void getLabelToAddressMap() {
        int count = 0;
        ifstream input("compiler-output/intermediate-assembly-code.txt");

        string s;
        while (getline(input, s)) {
            stringstream ss(s);
            string instruction;
            ss >> instruction;

            if(allowedInstructions.find(instruction) == allowedInstructions.end()) {
                labelToAddressMap[instruction] = count;
                continue; // You don't increase line count on labels
            }
            count++;
        }
    }    
};