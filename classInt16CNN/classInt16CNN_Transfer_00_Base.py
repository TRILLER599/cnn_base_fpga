#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
from datetime import datetime
rand_G = np.random.default_rng(6)
from conv_layer import conv_strato
from fully_layer import fully_strato

class classInt16CNN:
    def __init__(self, conv0_size, conv0_num, conv1_size, conv1_num,\
    y_len, class_num, H=28, mini_b=40, slowdown=12, y_lev1=256):
        self.y_len = y_len
        self.class_num = 10 if class_num>10 else class_num
        self.h0 = H
        self.conv0_size = conv0_size
        self.conv0_num  = conv0_num
        self.pool_0 = 2
        self.dir_log2 = 0
        self.rit_log2 = 0
        self.peso_log2 = 0
        self.modo_log2 = "arrot" # arrot tronc
        self.uno = 8
        self.precisione = 16
        self.rallent_max = 15
        
        self.S = []
        # слой 0
        self.S.append(\
        conv_strato((1,self.h0, self.h0), conv0_size, conv0_num,\
        rand_G, self.pool_0, reNu_t=0, uno = self.uno,\
        rallent_max=self.rallent_max))
        
        # слой 1
        self.h1 = (self.h0-conv0_size+1)//self.pool_0
        self.conv1_size = conv1_size
        self.conv1_num  = conv1_num
        self.pool_1 = 2
        
        self.S.append(\
        conv_strato((conv0_num, self.h1, self.h1), conv1_size, conv1_num,\
        rand_G, self.pool_1, reNu_t=0, uno = self.uno,\
        rallent_max=self.rallent_max))
        
        # слой 2
        self.h2 = (self.h1-conv1_size+1)//self.pool_1
        self.r2 = self.conv1_num*self.h2*self.h2
        
        self.mini_b     = mini_b if mini_b > 1 else 1
        self.rallentamente = 10 
        self.w_factor   = 10
        
        self.count_mb   = 0
        self.dw_troppo_grande = False
        self.dw_curr    = 0

        self.S.append(\
        fully_strato((self.conv1_num, self.h2, self.h2),\
        (1,y_len), rand_G, uno = self.uno, precisione = self.precisione,\
        peso_log2 = self.peso_log2, modo_log2 = self.modo_log2))
        
        self.gen_w_factor(slowdown)

        self.z0         = np.zeros((1,self.h0, self.h0), dtype=np.int64)
        self.p1         = np.zeros((self.conv0_num, self.h1, self.h1), dtype=np.int64)
        self.p1_err     = np.zeros((self.conv0_num, self.h1, self.h1), dtype=np.int64)
        self.p2         = np.zeros((self.conv1_num, self.h2, self.h2), dtype=np.int64)      
        self.p2_err     = np.zeros((self.conv1_num, self.h2, self.h2), dtype=np.int64)
        
        self.y          = np.zeros((1,y_len), dtype=np.int64)
        self.y_err      = np.zeros((1,y_len), dtype=np.int64)
        
        self.w0_archiv  = np.empty(self.S[0].w.shape, dtype=np.int64)
        self.w0_archiv[:]  = self.S[0].w
        self.w1_archiv  = np.empty(self.S[1].w.shape, dtype=np.int64)
        self.w1_archiv[:] = self.S[1].w
        self.w2_archiv  = np.empty(self.S[2].shape, dtype=np.int64)
        self.w2_archiv[:] = self.S[2].w
        
        self.file_prefix = ''
        self.gen_filename()
        
        self.y_lev1    = y_lev1
        self.y_lev2    = y_lev1*2
        # self.y_lev0    = y_lev1//4
        # self.y_lev0m   = -(y_lev1//4)
        self.y_lev0    = y_lev1//2        
        self.y_lev0m   = -(y_lev1//2)
        self.y_lev075  = y_lev1//2 + y_lev1//4
        self.y_lev05   = y_lev1//2
   
        self.uscita_vera = 0
        self.uscita_falsa = 0    

    def __str__(self):
        return 'classInt16CNN'
        
    def gen_filename(self, name=''):    
        dt = datetime.now()
        self.file_prefix = "{}_{}{}_{}{}".format(name if name else 'file',\
        dt.month if dt.month>9 else '0'+str(dt.month), dt.day if dt.day>9 else '0'+str(dt.day),\
        dt.hour if dt.hour>9 else '0'+str(dt.hour), dt.minute if dt.minute>9 else '0'+str(dt.minute))
        return 0
        
    def gen_w_factor(self, slowdown):    
        self.rallentamente = 15 if slowdown>15 else (8 if slowdown<8 else slowdown)
        self.w_factor = self.rallentamente
        self.S[0].rallent_wr(self.w_factor)
        self.S[1].rallent_wr(self.w_factor)
        self.S[2].rallent_wr(self.w_factor)
        return 0
        
    def archiviazione_pesi(self):    
        self.w0_archiv[:]   = self.S[0].w
        self.w1_archiv[:]   = self.S[1].w
        self.w2_archiv[:]   = self.S[2].w
        np.savetxt(self.file_prefix+'_w0_archiv.txt', self.S[0].w.reshape(self.S[0].w.size), fmt='%1.3f')
        np.savetxt(self.file_prefix+'_w1_archiv.txt', self.S[1].w.reshape(self.S[1].w.size), fmt='%1.3f')
        np.savetxt(self.file_prefix+'_w2_archiv.txt', self.S[2].w.reshape(self.S[2].w.size), fmt='%1.3f')
        return 0
        
    def caricamento_pesi(self):    
        self.S[0].w_carico(self.w0_archiv)
        self.S[1].w_carico(self.w1_archiv)
        self.S[2].w_carico(self.w2_archiv)
        self.dw_troppo_grande = False
        self.count_mb = 0
        self.S[0].dw.fill(0)
        self.S[1].dw.fill(0)
        self.S[2].dw.fill(0)      
        return 0
        
    def pesi_da_file(self, indirizzo_file):
        try:
            fr = open(indirizzo_file)
        except:
            print('файл {} не обнаружен'.format(indirizzo_file))
            return 0
        else:
            fr.close() 
        a = np.loadtxt(indirizzo_file)
        self.w0_archiv = (np.int64(a)).reshape(self.S[0].w.shape)
        self.S[0].w_carico(self.w0_archiv)
        
        indirizzo_file = indirizzo_file.replace('_w0_archiv', '_w1_archiv', 1)
        a = np.loadtxt(indirizzo_file)
        self.w1_archiv = (np.int64(a)).reshape(self.S[1].w.shape)
        self.S[1].w_carico(self.w1_archiv)
        
        indirizzo_file = indirizzo_file.replace('_w1_archiv', '_w2_archiv', 1)
        a = np.loadtxt(indirizzo_file)
        self.w2_archiv = (np.int64(a)).reshape(self.S[2].shape)
        self.S[2].w_carico(self.w2_archiv)
        return 0 
        
    def feedforward(self, X, Y_num, X_index=-1):
        self.z0[0] = X
        
        self.S[0].diretto(self.z0, self.p1)
        # print(self.p1[0], "p1[0]", self.count_mb)
        # print(self.p1[1], "p1[1]", self.count_mb)
        self.S[1].diretto(self.p1, self.p2)
        # print(self.p2[0], "p2[0]")
        self.S[2].diretto(self.p2, self.y)
        # print(self.y, "y")
        y_argmax = np.argmax(self.y[0,0:self.class_num])

        if X_index >= 0:
            # self.y_err[:] = self.errore_2soglie(Y_num)
            # self.y_err[:] = self.errore_2soglie_limitato(Y_num)
            # self.y_err[:] = self.errore_3soglie(Y_num)
            # self.y_err[:] = self.errore_4soglie(Y_num)
            self.y_err[:] = self.errore_4soglie_limitato(Y_num)
            if y_argmax == Y_num:
                self.uscita_vera += 1
            else:
                self.uscita_falsa += 1  
                
        return y_argmax    
 
    def errore_2soglie(self, true_ix):
        errore_list = np.zeros((self.y_len,), dtype=np.int64)
        for i in range(self.class_num):
            oy = self.y[0, i]
            if i==true_ix:
                if oy < self.y_lev1:
                    errore_list[i] = self.y_lev1 - oy
                else:
                    errore_list[i] = 0
                continue
            errore_list[i] = 0 if oy < self.y_lev0 else self.y_lev0-oy   
        return (errore_list.reshape(1, self.y_len))  
        
    def errore_2soglie_limitato(self, true_ix):
        errore_list = np.zeros((self.y_len,), dtype=np.int64)
        for i in range(self.class_num):
            oy = self.y[0, i]
            if i==true_ix:
                if oy < self.y_lev1:
                    err_1 = self.y_lev1 - oy
                    err_1 = self.y_lev0 if err_1>self.y_lev0 else err_1
                    errore_list[i] = err_1
                else:
                    errore_list[i] = 0
                continue
            err_0 = 0 if oy < self.y_lev0 else self.y_lev0-oy   
            errore_list[i] = self.y_lev0m if err_0 < self.y_lev0m else err_0
        return (errore_list.reshape(1, self.y_len)) 
 
    def errore_3soglie(self, true_ix):
        errore_list = np.zeros((self.y_len,), dtype=np.int64)
        for i in range(self.class_num):
            oy = self.y[0, i]
            if i==true_ix:
                if oy < self.y_lev1:
                    errore_list[i] = self.y_lev1 - oy
                elif oy > self.y_lev2:
                    errore_list[i] = self.y_lev2 - oy
                else:
                    errore_list[i] = 0
                continue
            errore_list[i] = 0 if oy < self.y_lev0 else self.y_lev0-oy   
        return (errore_list.reshape(1, self.y_len))  
        
    def errore_4soglie(self, true_ix):
        errore_list = np.zeros((self.y_len,), dtype=np.int64)
        for i in range(self.class_num):
            oy = self.y[0, i]
            if i==true_ix:
                if oy < self.y_lev1:
                    errore_list[i] = self.y_lev1 - oy
                elif oy > self.y_lev2:
                    errore_list[i] = self.y_lev2 - oy
                continue
            # нулевой выход
            if oy > self.y_lev0:    
                errore_list[i] = self.y_lev0 - oy
            elif oy < self.y_lev0m:
                errore_list[i] = self.y_lev0m - oy
                
        return (errore_list.reshape(1, self.y_len))  
        
    def errore_4soglie_limitato(self, true_ix):
        errore_list = np.zeros((self.y_len,), dtype=np.int64)
        for i in range(self.class_num):
            oy = self.y[0, i]
            if i==true_ix:
                if oy < self.y_lev1:
                    err = self.y_lev1 - oy
                    errore_list[i] = self.y_lev0 if err>self.y_lev0 else err
                elif oy > self.y_lev2:
                    err = self.y_lev2 - oy
                    errore_list[i] = self.y_lev0m if err<self.y_lev0m else err
                continue
            # нулевой выход
            if oy > self.y_lev0:  
                err = self.y_lev0 - oy
                errore_list[i] = self.y_lev0m if err<self.y_lev0m else err
            elif oy < self.y_lev0m:
                err = self.y_lev0m - oy
                errore_list[i] = self.y_lev0 if err>self.y_lev0 else err
        return (errore_list.reshape(1, self.y_len))  
 
    def dw_count(self):
        self.S[2].ritorno(self.y_err, self.p2_err)
        self.S[1].ritorno(self.p2_err, self.p1_err)
        z0_err  = np.empty((1,self.h0, self.h0), dtype=np.int64)
        self.S[0].ritorno(self.p1_err, z0_err)
        # print(self.p2_err[0], 'p2_err[0]', self.count_mb)
        # print(self.p1_err[0], 'p1_err[0]')
        # print(z0_err, 'z0_err')
        
    def backprop(self):
        self.dw_count()
        
        self.count_mb += 1
        if self.count_mb == self.mini_b:
            self.count_mb = 0
            self.S[2].aggiornamento()
            self.S[1].aggiornamento()
            self.S[0].aggiornamento()
        return True
        
    def application(self, X, Y_num, X_index):
        y_fact = self.feedforward(X, Y_num, X_index)
        self.backprop()
        return y_fact

if __name__ == '__main__':
    # from sys import exit as sys_exit
    # import random
    from classSelection import classSelection
    from scipy.io import loadmat
    # mnist = loadmat("d:/Projects_Python/Database/mnist-original.mat")
    mnist = loadmat("./mnist-original.mat")
    mnist_data = (mnist["data"].T).reshape(70000,28,28)
    mnist_data = np.int64(mnist_data)
    mnist_label = mnist["label"][0] 
    
    d_list = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]    
    y_size = len(d_list)
    LUNGEZZA_TOTALE = y_size*6000
    
    LEV_1 = 256*4
    # SLOW = 10
    SLOW = 12
    
    cl_Sel = classSelection()
    cl_Sel.analise(mnist_label)
    cl_Sel.actualization(d_list, all_zero=False)
    train_ctrl_index = cl_Sel.get_train_ctrl()
    
    cl_CNN = classInt16CNN(5,4,3,16,16,y_size,H=28,mini_b=20,slowdown=SLOW,y_lev1=LEV_1)
    # cl_CNN.gen_filename('00')
    # cl_CNN.pesi_da_file('01/e217/01_0306_1142_w0_archiv.txt')
    rand_G = np.random.default_rng(6)

    # ИЗМЕНЯЕМЫЕ ПАРАМЕТРЫ :
    # 8 <= SLOW <= 15               замедление обучения
    # 10 <= cl_CNN.mini_b <= 1000   должен быть кратен 10 
    # UNA_E >= cl_CNN.mini_b        UNA_E кратна cl_CNN.mini_b 
    # EPOCHA >= 1                   количество эпох обучения
    
    
    # UNA_E = cl_CNN.mini_b*10
    # EPOCHA = 2
    UNA_E = LUNGEZZA_TOTALE # 60000 уникальных картинок для обучения
    EPOCHA = 2              # Количество эпох обучения
    # UNA_E = 400
    # EPOCHA = 5
    
    d_counter, d_counter_MAX = 0, y_size-1
    mnist_parte = np.empty((y_size,28,28), dtype=np.int64)
    index_list = np.empty((y_size,), dtype=np.int32)
    d_sequenza = np.arange(y_size, dtype=np.uint16)
    d_ultimo = d_sequenza[-1]+1

    UNA_E = cl_CNN.mini_b if UNA_E<cl_CNN.mini_b else (UNA_E//cl_CNN.mini_b)*cl_CNN.mini_b

    e=0
    while e < EPOCHA:

        cl_CNN.uscita_vera = 0
        cl_CNN.uscita_falsa = 0
        
        for i in range(UNA_E):
            if d_counter==0:
                for k in range(y_size):
                    index, y_mask = cl_Sel.next_index()
                    mnist_parte[k] = mnist_data[index]
                    index_list[k] = index
                while (d_sequenza[-1]==d_ultimo):
                    rand_G.shuffle(d_sequenza)
                d_ultimo = d_sequenza[-1]
                
            y = d_sequenza[d_counter]
            mnist_uno = mnist_parte[y]
            index = index_list[y]
            d_counter = 0 if d_counter==d_counter_MAX else d_counter+1
            
            y_fact = cl_CNN.application(mnist_uno, y, index)
            if cl_CNN.dw_troppo_grande:
                break;
        
        print(cl_CNN.y[0,0:y_size]//10, 'y[' , y, ']')
        print(cl_CNN.y_err[0,0:y_size]//10, 'y_err')
        matr_tuple = cl_CNN.S[0].matrmax(numero=True)
        print('w0_max[{}]\n'.format(matr_tuple[1]), matr_tuple[0])
        matr_tuple = cl_CNN.S[1].matrmax(numero=True)
        print('w1_max[{}]\n'.format(matr_tuple[1]), matr_tuple[0])  
        matr_tuple = cl_CNN.S[2].matrmax(numero=True)
        print('w2_max[{}]\n'.format(matr_tuple[1]), matr_tuple[0])
        print('\nw0=',\
        np.amax(np.abs(cl_CNN.S[0].w)), ' w1=', np.amax(np.abs(cl_CNN.S[1].w)),\
        ' w2=', np.amax(np.abs(cl_CNN.S[2].w)),\
        ' p1=', int(np.amax(np.abs(cl_CNN.p1))),\
        ' p2=', int(np.amax(np.abs(cl_CNN.p2))),\
        ' y=', int(np.amax(cl_CNN.y[0,0:y_size])))

        # print('w0[0] :\n', cl_CNN.S[0].w[0])
        # print('w1_0 :\n', cl_CNN.S[1].w[0,0])       
        # print('w2 :\n', cl_CNN.S[2].w[0])
        
        
        index = 60000
        true_count, fact_check_count = 0, 0
        for i in range(10000):
            # if not (mnist_label[index] in d_list):
                # index += 1
                # continue
            current_float = mnist_label[index]
            for k in range(y_size):
                if d_list[k] == current_float:
                    break;
            else:
                index += 1
                continue
            fact_check_count += 1
            o_max = cl_CNN.feedforward(mnist_data[index],-1)
            if k == o_max:
                true_count += 1
            index += 1
            
        # test_true = 0
        test_true = round(true_count*100/fact_check_count,2)
        train_true = round(cl_CNN.uscita_vera*100/(cl_CNN.uscita_vera+cl_CNN.uscita_falsa), 2)
        print('C{}: true =  {} _ {}%'.format(e, test_true, train_true))
        print('-       -       -       -       -       -       -')
    
        if SLOW > 10:
            SLOW -= 1
            print("SLOW =", 1<<SLOW)
            cl_CNN.gen_w_factor(SLOW)
        
        e += 1
        
    # sys_exit()