#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
from math import sqrt as math_sqrt

class fully_strato:
    def __init__(self, i_shape, o_shape, rand_G,\
    peso_log2=0, modo_log2="arrot", reNu_t=0, shift=16, precisione=20):
        self.name = 'fully'
        if not (type(i_shape) is tuple):
            print('i_shape должен быть кортеж')
        if not (type(o_shape) is tuple):
            print('o_shape должен быть кортеж')
        self.i_shape = i_shape
        self.o_shape = o_shape
        self.peso_log2 = peso_log2
        self.modo_log2 = modo_log2
        self.reNu_t = reNu_t
        self.shift = shift
        self.shift_a = 1<<(shift-1)
        self.precisione = precisione
        self.precisione_a = 1<<(self.precisione-1)
        self.w_factor = 10
        self.i_lung = 1
        self.o_lung = 1
        self.make_lungezza()
        self.shape = (self.i_lung, self.o_lung)

        self.w = np.int64(256*(rand_G.random(self.shape, dtype=np.float32)\
        -0.5)*math_sqrt(2/self.i_lung))

        self.w_lungo = self.w << self.precisione
        self.w_log2 = np.empty(self.shape, dtype=np.int64)
        self.dw = np.zeros(self.shape, dtype=np.int64)
        self.img_dir = np.empty((1, self.i_lung), dtype=np.int64)
        
        if reNu_t:
            self.fattore_rit = np.empty((1, self.o_lung), dtype=np.float32)
        
        if reNu_t==1:
            self.reNu = lambda a: a if a>0 else a*0.0625
            self.reNu_mult = lambda a: 1 if a>0 else 0.0625  
        elif reNu_t==9:
            self.reNu = lambda a: a if a>0 else 0
            self.reNu_mult = lambda a: 1 if a>0 else 1    
        else:
            self.reNu = lambda a: a
            self.reNu_mult = lambda a: 1
        self.reNu_back = lambda e, m: e*m
            
        self.np_reNu = np.frompyfunc(self.reNu, 1, 1)
        self.np_reNu_Mult = np.frompyfunc(self.reNu_mult, 1, 1)
        self.np_reNu_Back = np.frompyfunc(self.reNu_back, 2, 1)
        
        self.natur2log = lambda a: a.bit_length()
        self.np_natur2log = np.frompyfunc(self.natur2log, 1, 1)
        
        self.w_log2[:] = self.arrot2log(self.w) if self.peso_log2 else self.w
        
    def __str__(self):
        return 'fully_strato'
        
    def arrot2log(self, a):
        if self.modo_log2=="tronc":
            b = np.abs(a)
            c = np.sign(a)
            stb = np.int8(self.np_natur2log(b))
            stb -=1
            stb *= np.abs(c)
            return c<<stb
        b = np.abs(a)
        c = np.sign(a)  # находим знаки входных данных
        stb = np.int8(self.np_natur2log(b)) #
        stb -=1 # так как формируем выходное значение сдвиго влево( 1<<X )
        b >>= (stb-1) # сдвигаем для получения ПРЕДПОСЛЕДНЕГО бита в 0-м разряде
        b &= 1 # определяем, является ли предпоследный бит значащим
        stb += b # если является, то добавляем 1 к сдвигу для выходного значения
        return c<<stb
        
    def make_lungezza(self):
        for i in self.i_shape:
            self.i_lung *= i
        for i in self.o_shape:
            self.o_lung *= i

    def diretto(self, img_in, img_out):
        self.img_dir[:] = img_in.reshape(1, self.i_lung)
            
        if self.reNu_t:
            # data_dot = (np.dot(self.img_dir, self.w_log2)+32768)>>16
            data_dot = (np.dot(self.img_dir, self.w_log2)+self.shift_a)\
            >> self.shift
            self.fattore_rit[:] = self.np_reNu_mult(data_dot)
            img_out[:] = self.np_reNu(data_dot).reshape(self.o_shape)
        else:
            img_out[:] = ((np.dot(self.img_dir, self.w_log2)+self.shift_a)\
            >> self.shift).reshape(self.o_shape)

    def ritardo(self, err_in, err_out):
        err_in_flat = err_in.reshape(1, self.o_lung)  
        if self.reNu_t:
            err_in_flat *= self.fattore_rit
            
        self.dw += np.dot(self.img_dir.T, err_in_flat)
        
        err = np.dot(err_in_flat, self.w_log2.T)
        # далее округляем
        err_out[:] = ((err + (np.sign(err)>>1) + self.shift_a)\
        >> self.shift).reshape(self.i_shape)
        
    def aggiornamento(self):
        r_shift = self.w_factor + self.shift - self.precisione
        if r_shift>0:
            r_shift_a = 1<<(r_shift-1)
            self.w_lungo += (self.dw+(np.sign(self.dw)>>1)+r_shift_a) >> r_shift
        elif r_shift<0:
            r_shift = -r_shift
            self.w_lungo += self.dw << r_shift
        else:
            self.w_lungo += self.dw

        self.w[:] = (self.w_lungo + self.precisione_a)>> self.precisione
        self.w_log2[:] = self.arrot2log(self.w) if self.peso_log2 else self.w
        self.dw.fill(0)
        
    def w_carico(self, w_nuovo):
        self.w[:] = w_nuovo
        self.w_lungo[:] = self.w << self.precisione
        self.w_log2[:] = self.arrot2log(self.w) if self.peso_log2 else self.w

    def matrmax(self, non_abs=0, numero=0):
        ix = np.argmax(self.w) if non_abs else np.argmax(np.abs(self.w))
        ix0 = ix//self.o_lung
        if numero:
            return (self.w[ix0], ix)
        return self.w[ix0]
        
if __name__ == '__main__':
    print('fully')
    