#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
from scipy.ndimage import correlate, convolve

class conv_strato:
    def __init__(self, i_shape, conv_size, conv_num, rand_G, maxpool=1,\
    peso_log2=0, modo_log2="arrot", reNu_t=0, shift=16, precisione=20):
        self.name = 'conv'
        if not ((type(i_shape) is tuple) and (len(i_shape)==3)):
            print('i_shape должен быть кортеж длиной 3')       
        self.i_shape = i_shape
        self.conv_size = conv_size
        self.conv_num = conv_num
        self.maxpool = maxpool
        self.peso_log2 = peso_log2
        self.modo_log2 = modo_log2
        self.reNu_t = reNu_t
        self.shift = shift
        self.shift_a = 1<<(shift-1) if shift>0 else 0
        self.precisione = precisione
        self.precisione_a = 1<<(self.precisione-1)
        self.w_factor = 10
        
        self.prec_num = i_shape[0]
        self.h_dir = i_shape[2]
        self.h_dopoConv = self.h_dir-conv_size+1
        if self.h_dopoConv//maxpool != self.h_dopoConv/maxpool:
            print('[h_dopoConv={}] должен быть крaтен [maxpool={}]'\
            .format(self.h_dopoConv, maxpool))   
        self.h_rit = self.h_dopoConv//maxpool
        
        self.w = np.int64(256*(rand_G.random((conv_num,\
        self.prec_num, conv_size, conv_size), dtype=np.float32)-0.5))

        self.w_lungo = self.w << self.precisione
        self.w_log2 = np.empty((conv_num, self.prec_num, conv_size, conv_size), dtype=np.int64)
        self.dw = np.zeros((conv_num, self.prec_num, conv_size, conv_size), dtype=np.int64)
        self.img_dir = np.empty(i_shape, dtype=np.int64)
        
        if (maxpool>1) or (reNu_t > 0):
            self.fattore_rit = np.empty((conv_num, self.h_dopoConv, self.h_dopoConv), dtype=np.float32)
        
        if reNu_t==1:
            self.reNu = lambda a: a if a>0 else a*0.0625
            self.reNu_mult = lambda a: 1 if a>0 else 0.0625   
        elif reNu_t==9:
            self.reNu = lambda a: a if a>0 else 0
            self.reNu_mult = lambda a: 1 if a>0 else 0   
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
        return 'conv_strato'
    
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
        stb -=1 # так как формируем выходное значение сдвигом влево( 1<<X )
        b >>= (stb-1) # сдвигаем для получения ПРЕДПОСЛЕДНЕГО бита в 0-м разряде
        b &= 1 # определяем, является ли предпоследный бит значащим
        stb += b # если является, то добавляем 1 к сдвигу для выходного значения
        return c<<stb
        
    def diretto(self, img_in, img_out):
        self.img_dir[:] = img_in
        
        if self.reNu_t>0:
            if self.maxpool>1:
                self.diretto_pool_attiv(self.img_dir, img_out)
            else:
                self.diretto_attiv(self.img_dir, img_out)
        elif self.maxpool>1:
            self.diretto_pool(self.img_dir, img_out)
        else:
            self.diretto_base(self.img_dir, img_out)
            
    def diretto_pool_attiv(self, img_in, img_out):
        img_convUno = np.empty((self.h_dir, self.h_dir), dtype=np.int64)
        decrease = self.conv_size//2
        for i in range(self.conv_num):
            img_convUno.fill(0)
            for k in range(self.prec_num):
                # img_convUno += ((correlate(img_in[k], self.w_log2[i,k],\
                # mode='constant',cval=0,origin=[-decrease,-decrease])\
                # +32768)>> 16)
                img_convUno += ((correlate(img_in[k], self.w_log2[i,k],\
                mode='constant',cval=0,origin=[-decrease,-decrease])\
                + self.shift_a)>> self.shift)
            
            img_locale = img_out[i]
            fattore_loc = self.fattore_rit[i]
            fattore_loc.fill(0)
            for r in range(self.h_rit):
                r_sin = r*self.maxpool
                r_des = r_sin+self.maxpool
                c_sin, c_des = 0, self.maxpool
                for c in range(self.h_rit):
                    quadro = img_convUno[r_sin:r_des, c_sin:c_des]
                    max_index = np.argmax(quadro)
                    r_q, c_q = max_index//self.maxpool, max_index%self.maxpool
                    max_data = quadro[r_q, c_q]
                    fattore_loc[r_sin+r_q, c_sin+c_q] = self.reNu_mult(max_data)
                    img_locale[r,c] = max_data
                    c_sin = c_des
                    c_des += self.maxpool
            img_locale[:] = self.np_reNu(img_locale)
            
    def diretto_attiv(self, img_in, img_out):
        img_convUno = np.empty((self.h_dir, self.h_dir), dtype=np.int64)
        decrease = self.conv_size//2
        for i in range(self.conv_num):
            img_convUno.fill(0)
            for k in range(self.prec_num):
                img_convUno += ((correlate(img_in[k], self.w_log2[i,k],\
                mode='constant',cval=0,origin=[-decrease,-decrease])\
                + self.shift_a) >> self.shift)

            self.fattore_rit[i] = self.np_reNu_mult(img_convUno[:self.h_rit,\
            :self.h_rit])
            img_out[i] = self.np_reNu(img_convUno[:self.h_rit,:self.h_rit])

    def diretto_pool(self, img_in, img_out):
        img_convUno = np.empty((self.h_dir, self.h_dir), dtype=np.int64)
        decrease = self.conv_size//2
        for i in range(self.conv_num):
            img_convUno.fill(0)
            for k in range(self.prec_num):
                img_convUno += ((correlate(img_in[k], self.w_log2[i,k],\
                mode='constant',cval=0,origin=[-decrease,-decrease])\
                + self.shift_a) >> self.shift)
                
            img_locale = img_out[i]
            fattore_loc = self.fattore_rit[i]
            fattore_loc.fill(0)
            for r in range(self.h_rit):
                r_sin = r*self.maxpool
                r_des = r_sin+self.maxpool
                c_sin, c_des = 0, self.maxpool
                for c in range(self.h_rit):
                    quadro = img_convUno[r_sin:r_des, c_sin:c_des]
                    max_index = np.argmax(quadro)
                    r_q = max_index//self.maxpool
                    c_q = max_index%self.maxpool
                    max_data = quadro[r_q, c_q]
                    fattore_loc[r_sin+r_q, c_sin+c_q] = 1
                    img_locale[r,c] = max_data
                    c_sin = c_des
                    c_des += self.maxpool
    
    def diretto_base(self, img_in, img_out):
        img_convUno = np.empty((self.h_dir, self.h_dir), dtype=np.int64)
        decrease = self.conv_size//2
        for i in range(self.conv_num):
            img_convUno.fill(0)
            for k in range(self.prec_num):
                img_convUno += ((correlate(img_in[k], self.w_log2[i,k],\
                mode='constant',cval=0,origin=[-decrease,-decrease])\
                + self.shift_a) >> self.shift)

            img_out[i] = img_convUno[:self.h_rit,:self.h_rit]
 
    def ritardo(self, err_in, err_out):
        if self.maxpool>1:
            self.ritardo_pool_attiv(self.img_dir, err_in, err_out)
        elif self.reNu_t>0:
            self.ritardo_attiv(self.img_dir, err_in, err_out)
        else:
            self.ritardo_base(self.img_dir, err_in, err_out) 
        
    def ritardo_pool_attiv(self, img_in, err_in, err_out):
        fattore_rit_int = np.empty((self.conv_num, self.h_dopoConv, self.h_dopoConv), dtype=np.int64)
        for i in range(self.conv_num):
            e_lungo = np.repeat(err_in[i], self.maxpool, axis=1)
            e_lungo = np.repeat(e_lungo, self.maxpool, axis=0)
            fattore_rit_int[i] = e_lungo*self.fattore_rit[i]
            for k in range(self.prec_num):
                self.dw[i,k] += correlate(img_in[k], fattore_rit_int[i],\
                mode='constant', cval=0, origin=[-self.h_rit,-self.h_rit])\
                [:self.conv_size, :self.conv_size]
        
        e_lungo = np.zeros((self.h_dir, self.h_dir), dtype=np.int64)
        back = np.empty((self.h_dir, self.h_dir), dtype=np.int64)
        decrease = self.conv_size//2
        for i in range(self.prec_num):
            back.fill(0)
            for k in range(self.conv_num):
                e_lungo[:self.h_dopoConv,:self.h_dopoConv] = fattore_rit_int[k]
                # back += np.int64(self.np_piu1(convolve(e_lungo, self.w_log2[k,i],\
                # mode='constant',cval=0, origin=[-decrease,-decrease])\
                # +self.shift_b))>> self.shift
                conv_uno = convolve(e_lungo, self.w_log2[k,i], mode='constant',\
                cval=0, origin=[-decrease,-decrease])
                # перед суммой делаем округление
                back += (conv_uno+(np.sign(conv_uno)>>1)+self.shift_a)>>self.shift

            err_out[i] = back
            
    def ritardo_attiv(self, img_in, err_in, err_out):
        fattore_rit_int = np.empty((self.conv_num, self.h_dopoConv, self.h_dopoConv), dtype=np.int64)
        for i in range(self.conv_num):
            fattore_rit_int[i] = err_in[i]*self.fattore_rit[i]
            for k in range(self.prec_num):
                self.dw[i,k] += correlate(img_in[k], fattore_rit_int[i],\
                mode='constant', cval=0, origin=[-self.h_rit,-self.h_rit])\
                [:self.conv_size, :self.conv_size]
        
        e_lungo = np.zeros((self.h_dir, self.h_dir), dtype=np.int64)
        back = np.empty((self.h_dir, self.h_dir), dtype=np.int64)
        decrease = self.conv_size//2
        for i in range(self.prec_num):
            back.fill(0)
            for k in range(self.conv_num):
                e_lungo[:self.h_dopoConv,:self.h_dopoConv] = fattore_rit_int[k]
                conv_uno = convolve(e_lungo, self.w_log2[k,i], mode='constant',\
                cval=0, origin=[-decrease,-decrease])
                # перед суммой делаем округление
                back += (conv_uno+(np.sign(conv_uno)>>1)+self.shift_a)>>self.shift

            err_out[i] = back
          
    def ritardo_base(self, img_in, err_in, err_out):
        for i in range(self.conv_num):
            back = err_in[i]
            for k in range(self.prec_num):
                self.dw[i,k] += correlate(img_in[k], back,\
                mode='constant', cval=0, origin=[-self.h_rit,-self.h_rit])\
                [:self.conv_size, :self.conv_size]
        
        e_lungo = np.zeros((self.h_dir, self.h_dir), dtype=np.int64)
        back = np.empty((self.h_dir, self.h_dir), dtype=np.int64)
        decrease = self.conv_size//2
        for i in range(self.prec_num):
            back.fill(0)
            for k in range(self.conv_num):
                e_lungo[:self.h_dopoConv,:self.h_dopoConv] = err_in[k]
                conv_uno = convolve(e_lungo, self.w_log2[k,i],\
                mode='constant', cval=0, origin=[-decrease,-decrease])
                # перед суммой делаем округление
                back += (conv_uno+(np.sign(conv_uno)>>1)+self.shift_a)>>self.shift
            err_out[i] = back
        
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
        dev0 = self.prec_num * self.conv_size * self.conv_size
        ix0 = ix//dev0
        ix1 = (ix%dev0)//(self.conv_size * self.conv_size)
        matrice = np.empty((self.conv_size, self.conv_size), dtype=np.int64)
        matrice[:] = self.w[ix0,ix1]
        if numero:
            return (matrice, ix)
        return matrice
        
if __name__ == '__main__':
    import numpy as np
    
    natur2log = lambda a: a.bit_length()
    np_natur2log = np.frompyfunc(natur2log, 1, 1)
    
    def arrot2log(a):
        b = np.abs(a)
        c = np.sign(a)  # находим знаки входных данных
        stb = np.int8(np_natur2log(b)) #
        stb -=1 # так как формируем выходное значение сдвигом влево( 1<<X )
        b >>= (stb-1) # сдвигаем для получения ПРЕДПОСЛЕДНЕГО бита в 0-м разряде
        b &= 1 # определяем, является ли предпоследный бит значащим
        stb += b # если является, то добавляем 1 к сдвигу для выходного значения
        return c<<stb
    
    c = np.arange(13, dtype=np.int64) 
    c -= 13
    
    r = arrot2log(c)
    print(c)
    print(r)
    