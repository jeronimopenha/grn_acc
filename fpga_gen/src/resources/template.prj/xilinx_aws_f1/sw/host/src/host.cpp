#include <host.h>


int main(int argc, char *argv[]){
            
    if (argc != 6) {
        std::cout << "Usage: " << argv[0] << " <XCLBIN File> <kernel name> <GRN Configuration file> <Mem Configuration file> <Output file name>" << std::endl;
        return EXIT_FAILURE;
    }
    
    std::string binaryFile = argv[1];
    std::string kernel_name = argv[2];
    std::string grn_cfg = argv[3];
    std::string grn_mem_cfg = argv[4];
    std::string grn_outputfile = argv[5];

    auto grn = Grn(binaryFile,kernel_name,grn_cfg,grn_mem_cfg,grn_outputfile);
    grn.run();
    grn.saveGrnOutput();
    grn.savePerfReport();

    return 0;
}

