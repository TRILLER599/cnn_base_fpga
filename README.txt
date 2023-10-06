
    The main goal of this project is to test the feasibility of implementing a 
system for training large neural networks (NN) on a set of FPGAs to reduce 
training time by an order of magnitude compared to GPUs.

    The central part of the project is a simple convolutional neural network on 
FPGA with fully parallel/pipeline computations. In this project, 1 chip is used, 
but it is assumed that each layer/multiple layers of NN are computed on a 
separate microchip, and the connection between the layers is organized using 
high-speed transceivers with a simple FIFO-based interface. The computations are 
condensed for resource reuse, but in some places, they are still not optimal.
However, there is a vast scope for research here. After the "attention" is 
implemented, it will be time for real optimization.
    To implement the training, a UDP packet processing protocol is written on 
the FPGA side, and its client part for PC is implemented in Python.
    The same neural network is implemented in NumPy for running computations 
on the processor and validating the correctness of the FPGA algorithm.

    I am NOT a professional programmer, but an FPGA developer, so please bear with me:)

    1. Folder "classInt16CNN"
    Inside this folder, there is a convolutional neural network implemented in 
pure numpy and run on the processor. Execute classInt16CNN_Transfer_00_Base.py 
in the interpreter to start the training of a three-layer convolutional network 
for 2 epochs – specified by the parameter EPOCHA. Before running this, it's 
necessary to unzip mnist_original_archive.zip in the same directory.
The convolutional and fully connected layers are described in conv_layer.py 
and fully_layer.py respectively. Training for 1 epoch takes about 15 
minutes. 
The data printed in the console can be used for comparison with the training of 
a similar neural network on the FPGA. Attention! It's important to maintain 
the repository directory structure, as the "weights" and settings of the class 
classInt16CNN are used during the training of the neural network on the FPGA. 
The small size of the network is due to the long operation of the reference 
model and not the FPGA resources.


    2. The directory "cnn_sv" contains the source files of the FPGA project.
The code does not contain primitives but was oriented towards Xilinx DSP. 
However, there should be nothing complicated or problematic, and it should work 
fine for Altera and other platforms as well.
    
neural_network_top.sv (         - top level file
    input clk,                  - neural network frequency must be < clk_eth
    input clk_eth,              - Ethernet_10G frequency = 312.5 MHz
    input i_eth_conf_complete,  - Ethernet ready signal
    
    The remaining ports are standard RX and TX ten gigabit optics
);
    
reti_neurali_base_0929.sv (     - neural network top level file
    It's generated from pseudo-C++ sources using our own version of HLS, 
    so the code's readability and comprehensibility are not at a high level.
);
    
    3. Connection Setup
    Jumbo frames must be enabled in the settings of the ten-gigabit optical 
network card! The training management protocol uses UDP packets with a maximum 
payload of 8192 bytes. The FPGA's IP address is set to 192.168.19.128, so the 
network card should be in the 19th subnet. Only responses to ARP requests and 
training commands are implemented - I was too lazy to bother with more for now.
By the time training begins, the board should be programmed, and the IP address 
should correspond to MAC=33:11:22:00:AA:BB. I hope to find time to add a response 
to ping.


    4. scenario.py - Implements the neural network training scenario on FPGA.
To initiate the training process on the FPGA, this script should be executed.
It utilizes the class classGestioneFunzionale and its methods from the file
pyGestioneFunzionale.py, where the exchange protocol with the FPGA is implemented.
classGestioneFunzionale extracts the "weights" and other adjustable parameters 
from classInt16CNN, ensuring the correctness of the FPGA's operation.
A simple echo client is implemented, so the maximum training speed is not 
achieved. Hence, running the FPGA at the maximum frequency does not make sense 
- it will still be idle. The full power of the FPGA and the entire network flow 
are needed for much more significant tasks.
