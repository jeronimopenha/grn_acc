//
// Created by lucas on 11/08/2021.
//

#include <grn.h>
#include <cstring>
#include <langinfo.h>


Grn::Grn(std::string xclbin,
         std::string kernel_name,
         std::string input_file,
         std::string mem_cfg_file,
         std::string output_file): m_xclbin(std::move(xclbin)),
                            m_kernel_name(std::move(kernel_name)),
                            m_input_file(std::move(input_file)),
                            m_mem_cfg_file(std::move(mem_cfg_file)),
                            m_output_file(std::move(output_file)){

    m_acc_fpga = new AccFpga(NUM_CHANNELS,NUM_CHANNELS);
    m_input_data = (unsigned char **) malloc(sizeof(unsigned char*)*NUM_CHANNELS);
    m_output_data = (grn_data_out_t **) malloc(sizeof(grn_data_out_t)*NUM_CHANNELS);
    m_input_size = (unsigned long *) malloc(sizeof(unsigned long)*NUM_CHANNELS);
    m_output_size = (unsigned long *) malloc(sizeof(unsigned long)*NUM_CHANNELS);
    memset(m_input_size,0,sizeof(unsigned long)*NUM_CHANNELS);
    memset(m_output_size,0,sizeof(unsigned long)*NUM_CHANNELS);
}
Grn::~Grn(){
    m_acc_fpga->cleanup();
    delete m_input_data;
    delete m_output_data;
    delete m_input_size;
    delete m_output_size;
    delete m_acc_fpga;
}
void Grn::readInputFile(){
    std::string line;
    std::string str_conf;
    std::ifstream myfile(m_input_file);
    std::ifstream memfile(m_mem_cfg_file);
    if (myfile.is_open()) {
        // Verification of the lenght of input/output data
        while (getline(myfile, line)) {
            strtok((char *)line.c_str(), ",");
            strtok(NULL, ",");
            strtok(NULL, ",");
            char *num_states = strtok(NULL, ",");
            auto sz = std::stoul(num_states, nullptr, 10);
            m_input_size[0]++;
            m_output_size[0]+=sz;
        }

        // Take the mem_conf data
        if (memfile.is_open()){
            getline(memfile, str_conf);
        } else{
            std::cout << "Error: mem file not found." << std::endl;
            exit(255);
        }
        
        memfile.close();
        
        myfile.clear();
        myfile.seekg(0);

        for (int j = 0; j < NUM_CHANNELS; ++j) {
            if(m_input_size[j] > 0){
                if (PE_TYPE == 0){
                    m_acc_fpga->createInputQueue(j,sizeof(grn_conf_t)*m_input_size[j]);
                    m_input_data[j] = (unsigned char*)m_acc_fpga->getInputQueue(j);
                }else if (PE_TYPE == 1){
                    m_acc_fpga->createInputQueue(j,((sizeof(grn_conf_t)*m_input_size[j]) + sizeof(mem_conf_t)));
                    m_input_data[j] = (unsigned char*)m_acc_fpga->getInputQueue(j);
                }else{
                    std::cout << "Error: pe_type not defined." << std::endl;
                    exit(255);
                }
            }
            if(m_output_size[j] > 0){
                m_acc_fpga->createOutputQueue(j,sizeof(grn_data_out_t)*m_output_size[j]);
                m_output_data[j] = (grn_data_out_t*) m_acc_fpga->getOutputQueue(j);
            }
        }
        
       
        int c = 0;
        grn_conf_t * grn_conf_ptr = (grn_conf_t *)m_input_data[0];
        if (PE_TYPE == 1){
            mem_conf_t * mem_conf_ptr = (mem_conf_t *)m_input_data[0];
            for(int i = MEM_CONF_BYTES-1, p = 0; i >= 0;--i,p+=2){
                mem_conf_ptr[0].mem_conf[i] = std::stoul(str_conf.substr(p,2), nullptr, 16);
            }
            grn_conf_ptr = (grn_conf_t *) &m_input_data[0][MEM_CONF_BYTES];
        }
         
        while (getline(myfile, line)) {
            strtok((char *)line.c_str(), ",");
            char *init_state = strtok(NULL, ",");
            char *end_state = strtok(NULL, ",");
            strtok(NULL, ",");
            std::string init_state_str(init_state);
            std::string end_state_str(end_state);
            for(int i = (STATE_SIZE_WORDS * 4)-1,p = 0; i >= 0;--i,p+=2){
                grn_conf_ptr[c].init_state[i] = std::stoul(init_state_str.substr(p,2), nullptr, 16);
                grn_conf_ptr[c].end_state[i] = std::stoul(end_state_str.substr(p,2), nullptr, 16);
            }
            c++;
        }
        myfile.close();
    }
    else{
        std::cout << "Error: input file not found." << std::endl;
        exit(255);
    }
}
void Grn::run(){
    m_acc_fpga->fpgaInit(m_xclbin, m_kernel_name);
    readInputFile();
    m_acc_fpga->execute();
}
void Grn::savePerfReport(){
  std::ofstream myfile("performance_report.csv");
  myfile << "Name,Initialization(ms),Size input data(bytes),Data copy HtoD(ms),Size output data(bytes),";
  myfile << "Data copy DtoH(ms),Execution time(ms),Total execution time(ms)" << std::endl;
  myfile << m_kernel_name << ",";
  myfile << m_acc_fpga->getInitTime()+m_acc_fpga->getSetArgsTime() << ",";
  myfile << m_acc_fpga->getTotalInputSize() << ",";
  myfile << m_acc_fpga->getDataCopyHtoDTime() << ",";
  myfile << m_acc_fpga->getDataCopyDtoHTime() << ",";
  myfile << m_acc_fpga->getExecTime() << ",";
  myfile << m_acc_fpga->getTotalTime() << std::endl;
}
void Grn::saveGrnOutput(){
    std::ofstream myfile(m_output_file);
    for (int k = 0; k < NUM_CHANNELS; ++k) {
        myfile << "i_state" << "," << "b_state" << "," << "period" << "," << "transient" << std::endl;
        for(unsigned long i = 0; i < m_output_size[k];i++){
            std::stringstream bstate,istate;
            for(int j=0; j<(STATE_SIZE_WORDS * 4); ++j){
                istate << std::hex << (int)m_output_data[k][i].i_state[j];
                bstate << std::hex << (int)m_output_data[k][i].b_state[j];
            }
            myfile << istate.str() << "," << bstate.str() << "," << m_output_data[k][i].period << "," << m_output_data[k][i].transient << std::endl;
            //printf("%d\n",m_output_data[k][i].sum);
        }
    }
    myfile.close();
}

