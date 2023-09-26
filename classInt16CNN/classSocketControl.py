#!/usr/bin/env python3
# -*- coding: utf-8 -*-
    
from sys import exit as sys_exit
import socket

# from threading import Thread

# PART_NUM = 2
# PAGE_SIZE = 512
# NUMB_SECTORS_FULL = 256
# NUMB_SECTORS = 252
# BYTE_PER_SECTOR = 262144
# NOB_PAGES_FULL = 131072
# NOB_PAGES = 129024            # 131072 - FULL
# PAYLOAD = 1024

# MAIN_SECTOR = int(NUMB_SECTORS_FULL/4)
# MAIN_PROGRAM = MAIN_SECTOR*BYTE_PER_SECTOR
# SLEEP_STEP = 0.6
# SLEEP_STEP_MS = SLEEP_STEP*1000

# CMD_FF = b'\xFF'
# PG_IN_SECTOR = int(BYTE_PER_SECTOR/PAGE_SIZE);
# PLD_IN_SECTOR = int(BYTE_PER_SECTOR/PAYLOAD);
# PG_IN_PLD = int(PAYLOAD/PAGE_SIZE);

# ADC_ADELAY          = [0x03, 0x4B, 0xA3, 0x6B]
# ADC_SYSREF          = [0x12, 0x13, 0x14, 0x15]

class classSocketControl:
    def __init__(self, timeout=1.0, fpga_connessione=False):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.M_timeout = 0
        if timeout>0:
            if timeout>9.0:
                self.M_timeout = int(timeout//9)
                self.sock.settimeout(9.0)
            else:
                self.sock.settimeout(timeout)
        if fpga_connessione:
            self.FPGA_ADDR = '192.168.19.128'
        else:
            self.FPGA_ADDR = '127.0.0.1'
        self.FPGA_PORT = 7007
        self.HOST_ADDR = '192.168.19.2'
        self.HOST_PORT = 7008
        self.DATA = b''
        self.b_255 = b'\xFF'
        self.remote_addr = ''
      
    def __str__(self):
        return 'classSocketControl'

    def to1b(self, int):
        return (int).to_bytes(1, byteorder='big')
    def to2b(self, int):
        return (int).to_bytes(2, byteorder='big')    
    def to4b(self, int):
        return (int).to_bytes(4, byteorder='big')
    def to1024b(self, int):
        return (int).to_bytes(1024, byteorder='big')    
    def toLb(self, int, L):
        return (int).to_bytes(L, byteorder='big')  
    def to1bl(self, int):
        return (int).to_bytes(1, byteorder="little",signed=True if int<0 else False)
    def to2bl(self, int):
        return (int).to_bytes(2, byteorder="little",signed=True if int<0 else False)
    def to4bl(self, int):
        return (int).to_bytes(4, byteorder="little",signed=True if int<0 else False)
    def toLbl(self, int, L):
        return (int).to_bytes(L, byteorder="little",signed=True if int<0 else False)  
        
    def toHEX(self, i):
        h_str = hex(i)  
        return ('0' + h_str[2:]) if len(h_str) == 3 else h_str[2:]   
        
    def toBIN(self, i):
        b_str = bin(int(i))
        m = (((len(b_str)-2)-1) // 8) + 1
        for i in range(8*m + 2 - len(b_str)):
            b_str = '{}0{}'.format(b_str[0:2], b_str[2:])
        return b_str       

    def emptyB(self, l):
        b = b'\xFF'
        for i in range(l-1):
                b = b + self.b_255
        return b    
     
    def bind(self):
        return self.sock.bind((self.HOST_ADDR, self.HOST_PORT))
        
    def send(self, bytes=b''):
        return self.sock.sendto(bytes, (self.FPGA_ADDR, self.FPGA_PORT))    
        
    def recv(self):
        M_counter = 0
        while(True):
            try:
                data, self.remote_addr = self.sock.recvfrom(8192)
                break
            except:
                if M_counter >= self.M_timeout:
                    return -1
                M_counter += 1
        return data      
        
    def close(self):
        self.sock.close()  
        return True           
        
    def eho_client(self, bytes):
        self.send(bytes)
        return self.recv() 
        
    def eho_server(self):
        data = self.recv()
        self.sock.sendto(data, self.remote_addr)  
        return data
        
    def completamento(self):
        return self.sock.sendto(self.toLb(255,5), (self.FPGA_ADDR, self.FPGA_PORT))   

    # def setupLink(self): 
            # try:
                # self.sock.close()  
            # except OSError:
                # self.printLog('Сокет был закрыт системой')            
            # return None
    # if data[0]&96 != 0:
    # def look_temperature(self, data, jstat, adc_fovr): 
        # self.ui.label_C.setText("Температура {}".format(data[3]))
        # # self.ui.label_stat_adc.setText("Статус {}".format(hex(data[2])))     
        # self.ui.label_stat_adc.setText("Статус {}x{}{}{}{}".format(self.toHEX(data[2]).upper(), \
        # self.toHEX(jstat[0]).upper(), self.toHEX(jstat[1]).upper(), self.toHEX(jstat[2]).upper(), self.toHEX(jstat[3]).upper()))
        # self.ui.label_stream.setText("Поток {}".format(int.from_bytes(data[0:2], byteorder='big')/1000))   
        # self.ui.label_count_ovf.setText("{}".format(self.count_ovf))  
        # self.ui.label_fovr_adc.setText("FOVR {}".format(self.toBIN(adc_fovr)))
        # self.ui.label_count_fovr.setText("{}".format(self.count_fovr))           
        # return None   
    # def clear_count_ovf(self): 
        # self.count_ovf, self.count_fovr = 0, 0
        # self.ui.label_count_ovf.setText("{}".format(self.count_ovf))
        # self.ui.label_count_fovr.setText("{}".format(self.count_fovr))         
    # def load_ctrl(self, mux_cmd = 2):
        # # self.printLog ('0 - питание включено, 2 - только статистика, 4 - перезагрузка, 256 - питание ВЫКЛЮЧЕНО')
        # # toCMD(1) - разрешение ref jesd
        # ref = self.toCMD(1) if self.ui.checkBox_on_refresh.isChecked() else self.toCMD(0)   # toCMD(1) - разрешение ref jesd
        # w = self.toCMD(3) + self.to4b(mux_cmd) + self.to4b(PAYLOAD) + self.toLb(0, 23) + ref + self.toLb(0, 1000) 
        # data = self.eho(w) 
        # # self.printLog("Команда  -  load_ctrl")
        # # self.printLog("Температура {}   Статус {}     Поток {}".format(data[7], hex(data[6]), int.from_bytes(data[4:6], byteorder='big')/1000))  
        # if data[139] > 127:
            # self.count_ovf += 1
        # if data[138] != 0:
            # self.count_fovr += 1
        # self.look_temperature(data[4:8], data[72:76], data[138])
        # return None     
    # def size_check(self, i_name = ''):
        # f = open('old.bin', 'rb')
        # f.seek(0, 2)
        # so = f.tell() 
        # f.close()
        # f = open('{}.bin'.format(i_name), 'rb')
        # f.seek(0, 2)
        # sn = f.tell() 
        # f.close()
        # if (so == sn):
            # self.printFaceL('Размер файлов совпадает', 2) 
        # elif (so > sn):
            # se = so - sn
            # se_4096 = se // 4096
            # se_1 = se - (se_4096*4096)
            # f = open('{}.bin'.format(i_name), 'ab')
            # for i in range(se_4096): 
                # f.write(self.CMD_FFx4096) 
            # for i in range(se_1): 
                # f.write(CMD_FF) 
            # f.close()
            # self.printFaceL('Файл был дописан', 2) 
        # else:    
            # self.printFaceL('Файл обновления прошивки слишком большой!!!', 3) 
            # return False
        # return sn   

if __name__ == '__main__': 
    print('classSocketControl')
    sys_exit()

