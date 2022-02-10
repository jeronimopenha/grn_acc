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

    m_grn_fpga = new GrnFpga(NUM_CHANNELS,NUM_CHANNELS);
    m_input_data = (grn_conf_t **) malloc(sizeof(grn_conf_t*)*NUM_CHANNELS);
    m_output_data = (grn_data_out_t **) malloc(sizeof(grn_data_out_t*)*NUM_CHANNELS);
    m_input_size = (unsigned long *) malloc(sizeof(unsigned long)*NUM_CHANNELS);
    m_output_size = (unsigned long *) malloc(sizeof(unsigned long)*NUM_CHANNELS);
    memset(m_input_size,0,sizeof(unsigned long)*NUM_CHANNELS);
    memset(m_output_size,0,sizeof(unsigned long)*NUM_CHANNELS);
}
Grn::~Grn(){
    m_grn_fpga->cleanup();
    delete m_input_data;
    delete m_output_data;
    delete m_input_size;
    delete m_output_size;
    delete m_grn_fpga;
}
void Grn::readInputFile(){
    std::string line;
    std::ifstream myfile(m_input_file);
    if (myfile.is_open()) {
        while (getline(myfile, line)) {
            //char *id = strtok((char *)line.c_str(), ",");
            strtok((char *)line.c_str(), ",");
            strtok(NULL, ",");
            strtok(NULL, ",");
            //auto idx = std::stoul(id, nullptr, 10) / NUM_COPIES_PER_CHANNEL;
            m_input_size[0]++;
        }
        m_output_size[0] = NUM_NOS + 1;

        myfile.clear();
        myfile.seekg(0);

        for (int j = 0; j < NUM_CHANNELS; ++j) {
            if(m_input_size[j] > 0){
                m_grn_fpga->createInputQueue(j,sizeof(grn_conf_t)*m_input_size[j]);
                m_input_data[j] = (grn_conf_t*)m_grn_fpga->getInputQueue(j);
            }
            if(m_output_size[j] > 0){
                m_grn_fpga->createOutputQueue(j,sizeof(grn_data_out_t)*m_output_size[j]);
                m_output_data[j] = (grn_data_out_t*) m_grn_fpga->getOutputQueue(j);
            }
        }
        int c[NUM_CHANNELS];
        memset(c,0,sizeof(int)*NUM_CHANNELS);
        while (getline(myfile, line)) {
            /*char *id = */strtok((char *)line.c_str(), ",");
            char *init_state = strtok(NULL, ",");
            char *end_state = strtok(NULL, ",");
            strtok(NULL, ",");
            std::string init_state_str(init_state);
            std::string end_state_str(end_state);
//             auto ch = std::stoul(id, nullptr, 10) / NUM_COPIES_PER_CHANNEL;
//             m_input_data[ch][c[ch]].id = (std::stoul(id, nullptr, 10) % NUM_COPIES_PER_CHANNEL) + 1;
            int ch = 0;
            for(int i = (STATE_SIZE_WORDS * 4)-1,p = 0; i >= 0;--i,p+=2){
                m_input_data[ch][c[ch]].init_state[i] = std::stoul(init_state_str.substr(p,2), nullptr, 16);
                m_input_data[ch][c[ch]].end_state[i] = std::stoul(end_state_str.substr(p,2), nullptr, 16);
            }
            c[ch]++;
        }
        myfile.close();
    }
    else{
        std::cout << "Error: input file not found." << std::endl;
        exit(255);
    }
}
void Grn::run(){
    m_grn_fpga->fpgaInit(m_xclbin, m_kernel_name);
    readInputFile();
    m_grn_fpga->execute();
}
void Grn::savePerfReport(){
  std::ofstream myfile("performance_report.csv");
  myfile << "Name,Initialization(ms),Size input data(bytes),Data copy HtoD(ms),Size output data(bytes),";
  myfile << "Data copy DtoH(ms),Execution time(ms),Total execution time(ms)" << std::endl;
  myfile << m_kernel_name << ",";
  myfile << m_grn_fpga->getInitTime()+m_grn_fpga->getSetArgsTime() << ",";
  myfile << m_grn_fpga->getTotalInputSize() << ",";
  myfile << m_grn_fpga->getDataCopyHtoDTime() << ",";
  myfile << m_grn_fpga->getDataCopyDtoHTime() << ",";
  myfile << m_grn_fpga->getExecTime() << ",";
  myfile << m_grn_fpga->getTotalTime() << std::endl;
}
void Grn::saveDerridaPlotHist(){
    std::ofstream myfile(m_output_file);
    for (int k = 0; k < NUM_CHANNELS; ++k) {
        for(unsigned long i = 0; i < m_output_size[k];i++){
            float val = 0;
            val = (float)m_output_data[k][i].sum;
            myfile << i <<  " , " << val << std::endl;
            printf("%d\n",m_output_data[k][i].sum);
        }
    }
    myfile.close();
}

