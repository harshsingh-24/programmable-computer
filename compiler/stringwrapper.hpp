#include <iostream>
using namespace std;
class Wrapper {
public: 
    // label stores the address of expression/literal evaluated
    string label;

    Wrapper(string l) {
        label = l;
    }
};