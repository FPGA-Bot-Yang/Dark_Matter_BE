#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include <string>
#include <fstream>

int main(){

	std::string filename = "Threshold_0.mif";

	std::string output_path = filename;
	std::ofstream fout;
	fout.open(output_path.c_str());
	if (fout.fail()){
		printf("open %s failed, exiting\n", output_path.c_str());
		exit(-1);
	}

	fout << "DEPTH = 128;                   -- The size of memory in words" << std::endl;
	fout << "WIDTH = 12;                    -- The size of data in bits" << std::endl;
	fout << "ADDRESS_RADIX = HEX;           -- The radix for address values" << std::endl;
	fout << "DATA_RADIX = BIN;              -- The radix for data values" << std::endl;
	fout << "CONTENT                        -- start of (address : data pairs)" << std::endl;
	
	fout << std::endl;
	
	fout << "BEGIN" << std::endl;
	
	for(int i = 0; i < 128; i++){
		char content[40];
		sprintf(content, "%02X : 00001100;", i);
		fout << content << std::endl;
	}
	
	fout << std::endl;
	fout << "END;" << std::endl;
	
	fout.close();
	

	return 0;
}
