//
// Created by lucas on 11/08/2021.
//

#include <grn.h>
#include <cstring>
#include <langinfo.h>


Grn::Grn(std::string xclbin,
         std::string kernel_name,
         std::string input_file,
         std::string output_file): m_xclbin(std::move(xclbin)),
                            m_kernel_name(std::move(kernel_name)),
                            m_input_file(std::move(input_file)),
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
    printf("\nGRN reading file");
    std::string line;
    std::string str_conf;
    std::ifstream conffile(m_input_file);
    if (conffile.is_open()) {
        // Verification of the lenght of input/output data
        unsigned long total_input_size = 0;
        unsigned long total_output_size = 0;
        while (getline(conffile, line)) {
            strtok((char *)line.c_str(), ",");
            strtok(NULL, ",");
            strtok(NULL, ",");
            char *num_states = strtok(NULL, ",");
            auto sz = std::stoul(num_states, nullptr, 10);
            total_input_size ++;
            total_output_size+=sz + 1;
        }

        for (int i = 0; i < NUM_CHANNELS; i++){
            m_input_size[i] = (unsigned long) total_input_size / NUM_CHANNELS;
            m_output_size[i] = (unsigned long) total_output_size / NUM_CHANNELS;
        }


        conffile.clear();
        conffile.seekg(0);
        printf("\nGRN allocating memory");
        for (int j = 0; j < NUM_CHANNELS; ++j) {
            if(m_input_size[j] > 0){
                m_acc_fpga->createInputQueue(j,sizeof(grn_conf_t)*m_input_size[j]);
                m_input_data[j] = (unsigned char*)m_acc_fpga->getInputQueue(j);
            }
            if(m_output_size[j] > 0){
                m_acc_fpga->createOutputQueue(j,sizeof(grn_data_out_t)*m_output_size[j]);
                m_output_data[j] = (grn_data_out_t*) m_acc_fpga->getOutputQueue(j);
            }
        }

        printf("\nGRN filling the input buffers");
        for (int j = 0; j < NUM_CHANNELS; ++j) {
            grn_conf_t * grn_conf_ptr;
            grn_conf_ptr = (grn_conf_t *)m_input_data[j];
            for (unsigned long k = 0; k < m_input_size[j]; k++){
                getline(conffile, line);
                strtok((char *)line.c_str(), ",");
                char *init_state = strtok(NULL, ",");
                char *end_state = strtok(NULL, ",");
                strtok(NULL, ",");
                std::string init_state_str(init_state);
                std::string end_state_str(end_state);
                for(int i = (STATE_SIZE_WORDS)-1,p = 0; i >= 0;--i,p+=2){
                    grn_conf_ptr[k].init_state[i] = std::stoul(init_state_str.substr(p,2), nullptr, 16);
                    grn_conf_ptr[k].end_state[i] = std::stoul(end_state_str.substr(p,2), nullptr, 16);
                }
            }
        }
        conffile.close();
    }
    else{
        std::cout << "Error: input file not found." << std::endl;
        exit(255);
    }
}
void Grn::run(){
    m_acc_fpga->fpgaInit(m_xclbin, m_kernel_name);
    readInputFile();
    printf("\nGRN executing");
    m_acc_fpga->execute();
}
void Grn::savePerfReport(){
  printf("\nGRN generating performance report file");
  std::ofstream reportfile("performance_report.csv");
  reportfile << "Name,Initialization(ms),Size input data(bytes),Data copy HtoD(ms),Size output data(bytes),";
  reportfile << "Data copy DtoH(ms),Execution time(ms),Total execution time(ms)" << std::endl;
  reportfile << m_kernel_name << ",";
  reportfile << m_acc_fpga->getInitTime()+m_acc_fpga->getSetArgsTime() << ",";
  reportfile << m_acc_fpga->getTotalInputSize() << ",";
  reportfile << m_acc_fpga->getDataCopyHtoDTime() << ",";
  reportfile << m_acc_fpga->getTotalOutputSize() << ",";
  reportfile << m_acc_fpga->getDataCopyDtoHTime() << ",";
  reportfile << m_acc_fpga->getExecTime() << ",";
  reportfile << m_acc_fpga->getTotalTime() << std::endl;
  reportfile.close();
}

void Grn::cleanup(){
    m_acc_fpga->cleanup();
    //free(m_main_data);
    //free(m_clusters_old);
    //free(m_output_data);
    //return 0;
}

void Grn::saveGrnOutput(){
    printf("\nGRN saving data out file");
    std::ofstream output_data_file(m_output_file);
    output_data_file << "b_state" << "," << "core_id" << "," << "period" << "," << "transient" << std::endl;
    for (int k = 0; k < NUM_CHANNELS; ++k) {
        for(unsigned long i = 0; i < m_output_size[k];i++){
            std::stringstream bstate;
            for(int j=0; j<(STATE_SIZE_WORDS); ++j){
                bstate << std::hex << (int)m_output_data[k][i].b_state[j];
            }
            output_data_file << bstate.str() << ","<< m_output_data[k][i].core_id << "," << m_output_data[k][i].period << "," << m_output_data[k][i].transient << std::endl;
        }
    }
    output_data_file.close();
}

