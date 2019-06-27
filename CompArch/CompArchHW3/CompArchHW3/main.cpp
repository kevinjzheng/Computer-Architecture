//
//  main.cpp
//  CompArchHW3
//
//  Created by Kevin J. Zheng on 2/26/19.
//  Copyright © 2019 Kevin J. Zheng. All rights reserved.
//

#include <iostream>
using namespace std;


void es15assemblyProgram() {
    int Rg0, Rg1;
    // myRom[2]
    Rg0 = 15;
    // myRom[5]
    Rg1 = 15;
    int counter = 0;
    for (int i = 0; i != Rg0; Rg0--) {
        // myRom[5]
        Rg1 = 15;
        for (int j = 0; j != Rg1; Rg1--) {
            counter++;
        }
    }
    cout << "Done! Rg0:" << Rg0 << " Rg1: " << Rg1 << endl;
    cout << counter << endl;
}

int main() {
    es15assemblyProgram();
}
