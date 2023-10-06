#!/usr/bin/env python3
# -*- coding: utf-8 -*-

if __name__ == '__main__':
    from sys import exit as sys_exit
    import numpy as np
    rand_G = np.random.default_rng(6)
    from scipy.io import loadmat
    from classSelection import classSelection
    from classInt16CNN_Transfer_00_Base import classInt16CNN  
    from pyGestioneFunzionale import classGestioneFunzionale
    
    mnist = loadmat("./mnist-original.mat")
    mnist_data = (mnist["data"].T).reshape(70000,28,28)
    mnist_label = mnist["label"][0]
    d_list = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
    
    cl_Sel = classSelection()
    cl_Sel.analise(mnist_label)
    cl_Sel.actualization(d_list, all_zero=False)
    
    LEV_1 = 256*4
    SLOW = 12
    FPGA = 1 # True==1 Fase==0
    cl_CNN = classInt16CNN(5,4,3,16,16,len(d_list),H=28,mini_b=40,slowdown=SLOW,y_lev1=LEV_1)
    funz = classGestioneFunzionale(cl_CNN, mnist_data, cl_Sel, len(d_list), rand_G, FPGA)
    
    # funz.MINIB = 40
    # funz.EPOCHA = funz.MINIB*1
    # funz.EPOCHA = funz.MINIB*20
    funz.EPOCHA = 60000
    
    # if funz.caricare_pesi():
        # print("отправка завершения 0")
        # funz.end()
        # sys_exit()
    if funz.ricaricare_pesi(True):
        print("отправка завершения 0")
        funz.end()
        sys_exit()
    funz.peso_0_print()
    
    # if funz.epocha(3, peso_print=1):
        # funz.end()
        # print("отправка завершения 1")
        # sys_exit()
    # for i in range(6):
    for i in range(20):
        res = funz.epocha(10, peso_print=0)
        if res<0:
            print("отправка завершения 1")
            funz.end()
            sys_exit() 
            
        if res:
            if funz.ricaricare_pesi(True):
                print("отправка завершения 2")
                funz.end()
                sys_exit()
            funz.peso_print(1)
            if funz.rallentamente==15:
                print("обучение не продвигается")
                funz.end()
                sys_exit()
            
            funz.rallentamente=12 if funz.rallentamente<12 else funz.rallentamente+1
            print("rallentamente =", funz.rallentamente)
            continue
        
        funz.ricaricare_pesi() 
        funz.peso_print(1) # 0-не печатает, 1-печатает кратко, 2-полная статистика
        # funz.peso_0_print()
        if funz.rallentamente > 10:
            funz.rallentamente -= 1
            
            
            
    # funz.ricaricare_pesi() 
    funz.peso_0_print()
    funz.peso_print(2)
    # funz.ricaricare_pesi(True) 
    
    print('C{}: {} _ MAX'.format(funz.percento_max[0], funz.percento_max[1]))
    
    funz.end()
    # funz.sock_udp.close()
    



