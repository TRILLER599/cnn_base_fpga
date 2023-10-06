#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
from classSocketControl import classSocketControl

def to1b(d):
    return (d).to_bytes(1, byteorder="little",signed=True if d<0 else False)
def to2b(d):
    return (d).to_bytes(2, byteorder="little",signed=True if d<0 else False)
def to3b(d):
    return (d).to_bytes(3, byteorder="little",signed=True if d<0 else False)
def to4b(d):
    return (d).to_bytes(4, byteorder="little",signed=True if d<0 else False)
def toLb(d, L):
    return (d).to_bytes(L, byteorder="little",signed=True if d<0 else False)
def fprint(s):
    print(s)

class classGestioneFunzionale:
    def __init__(self, pyCNN, mnist_data, cl_Sel, i_class_num, rand_G, fpga=False):
        if fpga:
            self.sock_udp = classSocketControl(1.0, True)
            self.sock_udp.bind()
        else:
            self.sock_udp = classSocketControl(300.0, False)

        self.mnist_data = mnist_data
        self.cl_Sel = cl_Sel
        self.i_class_num = i_class_num
        self.rand_G = rand_G
        
        self.img_dir = pyCNN.h0
        self.class_num = pyCNN.class_num
        self.MINIB = pyCNN.mini_b
        self.rallentamente = pyCNN.rallentamente
        self.profondita = len(pyCNN.S)
        self.mux_funzerrore = 3
        
        self.w_archiv = []
        self.w_buf = []
        self.type_origine = []
        self.shape_origine = []
        self.pesi_archiviazione(pyCNN)
        
        self.EPOCHA = self.i_class_num*6000
        self.INDEX_BUF_MAX = 1024
        self.D_WIDTH = 1
        self.d_index_ultimo = self.class_num
        self.d_sequenza = np.arange(self.i_class_num, dtype=np.uint16)
        
        self.minib_t = 0

        self.pacco_ricevuto = -1
        self.pacco_spedito = -1

        self.Y = np.array([pyCNN.y_lev0, pyCNN.y_lev1, pyCNN.y_lev2,
        pyCNN.y_lev0m, pyCNN.y_lev05, pyCNN.y_lev075,\
        pyCNN.y_lev1//4, 0], dtype=np.int32) # 6-й элемент, это ограничитель
        self.rete_errori = np.zeros((6,), dtype=np.uint16)
        self.true_false = np.zeros((2,), dtype=np.uint32)
        self.gia_fatto = 0
        
        self.cmd_ultimo = 0
        self.cmd_list = np.zeros((16,), dtype=np.uint16)
        self.cmd_counter = 0
        
        self.percento_max = (0, 96.0)
        
    def __str__(self):
        return 'classGestioneFunzionale'

    def pesi_archiviazione(self, riferenza=False):
        if riferenza:
            for un_strato in riferenza.S:
                lung = un_strato.w.size
                if un_strato.name == 'fully':
                    self.w_archiv.append(np.int32(un_strato.w.T).reshape(lung,))
                else:
                    self.w_archiv.append(np.int32(un_strato.w).reshape(lung,))
                self.w_buf.append(np.empty((lung,), dtype=np.int32))
                self.type_origine.append(un_strato.name)
                self.shape_origine.append(un_strato.w.shape)               
               
    # основное управляющее слово
    def p0(self, num_cmd=16384): # значение по-умолчанию это reset
        #    отправляем всем    команда         номер отправленного пакета
        sb = to2b(32768) +      to2b(num_cmd) + to4b(self.pacco_spedito+1)
        self.cmd_ultimo = num_cmd
        self.cmd_list[self.cmd_counter] = num_cmd
        self.cmd_counter = 0 if self.cmd_counter==15 else self.cmd_counter+1
        return sb

    def caricare_pesi(self):
        un_pacco_max = 2044
        for strato in range(self.profondita):
            inizio = 0
            quantita = self.w_archiv[strato].shape[0]
            while True:
                sb = self.p0(2) # команда загрузки весов
                terminare = inizio+un_pacco_max
                if terminare > quantita:
                    terminare = quantita
                    w_num = terminare-inizio
                    sb += to2b(w_num)
                    sb += (to2b(strato) + to4b(0))
                    sb += self.w_archiv[strato][inizio:].tobytes()
                    sb += toLb(0, 8192-len(sb))
                else:
                    sb += to2b(un_pacco_max)
                    sb += (to2b(strato) + to4b(0))
                    sb += self.w_archiv[strato][inizio:terminare].tobytes()
                # запрос-ответ
                risposta = self.sock_udp.eho_client(sb)
                self.pacco_spedito += 1
                if self.controllo_ricezione_base(risposta):
                    return -1
                if (terminare==quantita):
                    break
                inizio = terminare
        return 0 
        
    def ricaricare_pesi(self, dall_archivio=False):
        un_pacco_max = 2044
        equal = True
        for rw in range(2):
            for strato in range(self.profondita):
                inizio = 0
                quantita = self.w_archiv[strato].shape[0]
                while True:
                    sb = self.p0(2) # команда загрузки весов
                    terminare = inizio+un_pacco_max
                    if terminare > quantita:
                        terminare = quantita
                        w_num = terminare-inizio
                        sb += to2b(w_num)
                        sb += (to2b(strato) + to4b(0))
                        if dall_archivio:
                            sb += self.w_archiv[strato][inizio:].tobytes()
                        else:
                            sb += self.w_buf[strato][inizio:].tobytes()
                        sb += toLb(0, 8192-len(sb))
                    else:
                        sb += to2b(un_pacco_max)
                        sb += (to2b(strato) + to4b(0))
                        if dall_archivio:
                            sb += self.w_archiv[strato][inizio:terminare].tobytes()
                        else:
                            sb += self.w_buf[strato][inizio:terminare].tobytes()
                    # запрос-ответ
                    risposta = self.sock_udp.eho_client(sb)
                    self.pacco_spedito += 1
                    if self.controllo_ricezione_base(risposta):
                        return -1
                        
                    if dall_archivio or rw==0:
                        self.w_buf[strato][inizio:terminare] = np.frombuffer(\
                        risposta[16:16+(terminare-inizio)*4], dtype=np.int32)
                    if (terminare==quantita):
                        break
                    inizio = terminare
                if dall_archivio and rw==1 and equal:
                    equal = np.array_equal(self.w_archiv[strato],\
                    self.w_buf[strato])
                    if equal==False:
                        e_ix = 0
                        for i in range(quantita):
                            if self.w_archiv[strato][i]!=self.w_buf[strato][i]:
                               e_ix = i
                               break;
                        print("errore_index =", e_ix)
                        e_ix = 0 if e_ix<4 else e_ix-4
                        print("w_archiv[{}][{}:{}] = {}".format(strato,\
                        e_ix, e_ix+8, self.w_archiv[strato][e_ix:e_ix+8]))
                        print("w_buf[{}][{}:{}] = {}".format(strato,\
                        e_ix, e_ix+8, self.w_buf[strato][e_ix:e_ix+8]))
                        # print("strato[{}] {}=[{};{}], {}=[{};{}]"\
                        # .format(strato, "w_archiv[0;-1]",\
                        # self.w_archiv[strato][0], self.w_archiv[strato][-1],\
                        # "w_buf[0;-1]",\
                        # self.w_buf[strato][0], self.w_buf[strato][-1]))
                # 2023_09_11 Start
                if (not dall_archivio) and rw==1:
                    self.w_archiv[strato][:] = self.w_buf[strato]
                # 2023_09_11 End 
                
        if dall_archivio:
            if equal:
                return 0
            fprint('errore: начальная загрузка весов происходит не корректно')
            return -2        
        # print((self.w_buf[0].reshape(4,5,5))[0])
        # print((self.w_buf[1].reshape(16,4,3,3))[0,0])
        # print(((self.w_buf[2].reshape(16,400)).T)[0])
        return 0
    
    def peso_print(self, p_print=0):
        if not p_print:
            return 0
        if p_print==1:
            p_str = ""
            for i in range(2):
                imax = np.argmax(np.abs(self.w_buf[i]))
                p_str += ("conv_"+str(i)+"["+str(imax)+"] = "+str(self.w_buf[i][imax])+"    ")
            imax = np.argmax(np.abs(self.w_buf[2]))
            p_str += ("fully_max["+str(imax)+"] = "+str(self.w_buf[2][imax]))
            print(p_str)
            return 0
        for i in range(2):
            imax = np.argmax(np.abs(self.w_buf[i]))
            matr = self.shape_origine[i][-1]
            matr_2 = matr*matr
            matr_num = imax//(matr_2)
            print("conv_"+str(i)+"["+str(imax)+"] = "+str(self.w_buf[i][imax]))
            print(self.w_buf[i][matr_2*matr_num:matr_2*(matr_num+1)]\
            .reshape(matr,matr))
        imax = np.argmax(np.abs(self.w_buf[2]))
        print("fully_max["+str(imax)+"] =", self.w_buf[2][imax]) 
        return 0
        
    def peso_0_print(self):
        for i in range(2):
            matr = self.shape_origine[i][-1]
            matr_2 = matr*matr
            print("conv_"+str(i)+"[0]:")
            print(self.w_buf[i][0:matr_2].reshape(matr,matr))
        print("fully[0] =", self.w_buf[2][0:16]) 
        return 0
    
    def controllo_ricezione_base(self, risposta, lunghezza=0):
        # int(w_strato[iw])
        # int.from_bytes(rec_w[iml:ist], "little", signed=True)
        if type(risposta) is int:
            fprint('errore: ответ от хоста не получен ')
            fprint((self.cmd_list, self.cmd_counter))
            return True
        risp_lung = len(risposta)
        if not(risp_lung in {32,1024,8192}):
            fprint('errore: длина принятого пакета равна '+str(risp_lung))
            fprint((self.cmd_list, self.cmd_counter))
            return True
        if risposta[3]&128:
            fprint('errore: код ошибки '+\
            str(int.from_bytes(risposta[8:10], "little")))
            fprint((self.cmd_list, self.cmd_counter))
            return True
        pacco_ricevuto = int.from_bytes(risposta[4:8], "little")
        if self.pacco_spedito != pacco_ricevuto:
            fprint('errore: был отправлен пакет с номером {}, а ответ {} {}'\
            .format(self.pacco_spedito, 'получен с номером', pacco_ricevuto))
            fprint((self.cmd_list, self.cmd_counter))
            return True
        if lunghezza!=0 and risp_lung!=lunghezza:
            fprint('errore: длина ответа на команду {} равна {} != {}'\
            .format(self.cmd_ultimo, risp_lung, lunghezza))
            fprint((self.cmd_list, self.cmd_counter))
            return True
        return False
        
    def end(self):
        self.sock_udp.send(self.p0()+toLb(0,1016))
        self.sock_udp.close()
        
    def rst(self):
        self.sock_udp.send(self.p0()+toLb(0,1016))
        
    def istruzione_1(self, modalita=0):
        sb = self.p0(1)
        sb += (to2b(self.class_num) + to2b(self.MINIB))
        sb += (to2b(self.rallentamente) + to2b(self.profondita))
        sb += to4b(self.img_dir*self.img_dir)
        sb += (to1b(modalita) + to1b(self.mux_funzerrore) + to2b(0))
        sb += self.Y.tobytes()
        sb += toLb(0, 1024-len(sb))
        # запрос-ответ
        risposta = self.sock_udp.eho_client(sb)
        self.pacco_spedito += 1
        if self.controllo_ricezione_base(risposta, 1024):
            return -1
        self.rete_errori[:] = np.frombuffer(risposta[16:28], dtype=np.uint16)
        e_bool = 0
        for i in range(self.rete_errori.shape[0]):
            if self.rete_errori[i] != 0:
                fprint('errore: получена ошибка {} в {} слое нейросети'\
                .format(self.rete_errori[i], i))
                e_bool = 1
        if int.from_bytes(risposta[48:50], "little") != 0:
            fprint('errore: обнаружен флаг срабатывания вочдога = '+\
            str(int.from_bytes(risposta[48:50], "little")))
            fprint((self.cmd_list, self.cmd_counter))
            return -2
        self.true_false[:] = np.frombuffer(risposta[272:280], dtype=np.uint32)
        return e_bool
        
    def epocha(self, num=1, peso_print=0):
        if (self.MINIB % self.i_class_num) != 0:
            new_minib = ((self.MINIB//self.i_class_num)+1)*self.i_class_num
            fprint('размер минибатча изменён с {} на {} так как\n{} {}'\
            .format(self.MINIB, new_minib,\
            'число входных классов равно', self.i_class_num))
            self.MINIB = new_minib
        if (self.EPOCHA % self.MINIB) != 0:
            new_epocha = ((self.EPOCHA//self.MINIB)+1)*self.MINIB
            fprint('размер эпохи изменён с {} на {} так как\n{} {}'\
            .format(self.EPOCHA, new_epocha,\
            'размер минибатча равен', self.MINIB))
            self.EPOCHA = new_epocha
    
        if self.istruzione_1()<0: # загрузка настроек
            return -1;
        # создание массивов данных и индексов
        index_arr = np.empty((self.EPOCHA,), dtype=np.uint16)
        data_arr = np.empty((self.EPOCHA, self.img_dir, self.img_dir),\
        dtype=(np.int8 if self.D_WIDTH==1 else (np.int16 if self.D_WIDTH==2 else np.int32)))
        
        # обучение указанное количество эпох
        for i in range(num):
            resp = self.epocha_1(index_arr, data_arr)
            if resp<0:
                fprint('errore: ошибка обмена на эпохе ' + str(i))
                return resp;
            elif resp>0:
                # fprint('вызывается обработчик ошибок слоёв нейросети {} {}'\
                # .format('на эпохе', i))
                return resp;
            else:
                tf_num = self.true_false.sum()
                if tf_num==0:
                    fprint('errore: на эпохе '+str(i)+' функция ошибки '+\
                    'не посылала сигналы true/false')
                    return -1;
                else:
                    percento = round(self.true_false[0]*100/tf_num, 2)
                    if percento > self.percento_max[1]:
                        fprint('C{}: {} _ {} _ max'\
                        .format(self.gia_fatto+i, percento, tf_num))
                        self.percento_max = (self.gia_fatto+i, percento)
                    else:
                        fprint('C{}: {} _ {}'\
                        .format(self.gia_fatto+i, percento, tf_num))
                self.true_false.fill(0)
            # печать весов    
            if peso_print:
                if self.ricaricare_pesi():
                    return -1
                self.peso_print(peso_print)
        self.gia_fatto += num
        return 0
        
    def epocha_1(self, index_arr, data_arr):
        self.data_gen(index_arr, data_arr)
        if self.formazione(index_arr, data_arr):
            return -1
        # print('обучение на эпохе завершено')
        return self.istruzione_1()
        
    def data_gen(self, ix_arr, d_arr):
        d_counter = 0
        d_counter_MAX = self.i_class_num-1
        un_parte = np.empty((self.i_class_num, self.img_dir, self.img_dir),\
        dtype=d_arr.dtype)
        for i in range(ix_arr.shape[0]):
            if d_counter==0:
                for k in range(self.i_class_num):
                    index, y_mask = self.cl_Sel.next_index()
                    un_parte[k] = self.mnist_data[index]
                while (self.d_sequenza[-1]==self.d_index_ultimo):
                    self.rand_G.shuffle(self.d_sequenza)
                self.d_index_ultimo = self.d_sequenza[-1]
            ix_corretto = self.d_sequenza[d_counter]
            ix_arr[i] = ix_corretto
            # d_arr[i] = un_parte[ix_corretto]*256
            d_arr[i] = un_parte[ix_corretto]
            d_counter = 0 if d_counter==d_counter_MAX else d_counter+1

    def formazione(self, ix_arr, d_arr):
        index_max = self.INDEX_BUF_MAX if self.INDEX_BUF_MAX<4088 else 4088
        # print(index_max)
        index_max = (index_max//self.MINIB)*self.MINIB
        # print(index_max)
        quantita = ix_arr.shape[0]
        start, stop = 0, 0
        while stop != quantita:
            stop = quantita if start+index_max>quantita else start+index_max
            self.index_invio(ix_arr, start, stop)
            # print(start, stop)
            # print('индексы отпаралены')
            if self.data_invio(d_arr, start, stop):
                # print('ошибка времени обучения')
                return -1
            start = stop
        return 0
            
    def index_invio(self, ix_arr, start, stop):  
        sb = self.p0(3)
        sb += (to2b(stop-start) + toLb(0, 6))
        sb += ix_arr[start:stop].tobytes()
        lung = len(sb)
        resta = 1024-lung if lung<= 1024 else 8192-lung
        self.sock_udp.send(sb+toLb(0,resta) if resta!=0 else sb)
        self.pacco_spedito += 1
        # print('передача индексов, пакет №', self.pacco_spedito)
        
    def data_invio(self, d_arr, start, stop):  
        PACCO_D_MAX = 8176
        sb1 = to1b(self.D_WIDTH) + toLb(0,5)

        img_lunghezza = self.img_dir*self.img_dir*self.D_WIDTH
        sbuf, sbuf_lung = b'', 0
        while (sbuf_lung<PACCO_D_MAX) and (start<stop):
            sbuf += d_arr[start].tobytes()
            sbuf_lung += img_lunghezza
            start += 1
        
        if sbuf_lung > PACCO_D_MAX:
            sb = self.p0(4)+ to2b(PACCO_D_MAX//self.D_WIDTH)+ sb1+ sbuf[:PACCO_D_MAX]
            
            sbuf = sbuf[PACCO_D_MAX:]
            sbuf_lung -= PACCO_D_MAX
        else:
            resta_lung = PACCO_D_MAX-sbuf_lung
            sb_resta = toLb(0, resta_lung) if resta_lung>0 else b''
            sb = self.p0(4)+ to2b(sbuf_lung//self.D_WIDTH)+ sb1+ sbuf+ sb_resta

            sbuf = b''
            sbuf_lung = 0
            
        self.sock_udp.send(sb)
        self.pacco_spedito += 1
        
        for i in range(start, stop):
            sbuf += d_arr[i].tobytes()
            sbuf_lung += img_lunghezza
            if sbuf_lung > PACCO_D_MAX:
                sb = self.p0(4)+ to2b(PACCO_D_MAX//self.D_WIDTH)+ sb1+ sbuf[:PACCO_D_MAX]
                sbuf = sbuf[PACCO_D_MAX:]
                sbuf_lung -= PACCO_D_MAX
                # проверка ответа на предыдущий send() перед отправкой
                risposta = self.sock_udp.recv()
                if self.controllo_ricezione_base(risposta, 32):
                    return -1
                self.sock_udp.send(sb)
                # print('4_1', self.sock_udp.send(sb))
                self.pacco_spedito += 1
        
        risposta = self.sock_udp.recv()
        if self.controllo_ricezione_base(risposta, 32):
            return -1
        
        if sbuf_lung:
            resta_lung = PACCO_D_MAX-sbuf_lung
            sb_resta = toLb(0, resta_lung) if resta_lung!=0 else b''
            sb = self.p0(4) + to2b(sbuf_lung//self.D_WIDTH)+sb1+sbuf+sb_resta

            risposta = self.sock_udp.eho_client(sb)
            self.pacco_spedito += 1
            if self.controllo_ricezione_base(risposta, 32):
                return -1
        return 0
            
if __name__ == '__main__':
    # w0 = np.int64(np_round(9*rand_G.random((2, 3, 3), dtype=np.float32)))
    a = np.arange(6, dtype=np.int16)
    # a *= -1
    # print(a, 'a')
    # b = np.empty((6,), dtype=np.int64)
    # b[:] = a
    # print(b)
    # print(np.array_equal(a,b), a.dtype, b.dtype)
    b = b''
    print(type(b), len(b), id(b))
    b += a.tobytes()
    print(type(b), len(b), id(b), b)
    b += b''
    print(type(b), len(b), id(b))
    # a = toLb(-10, 10)
    # print(id(a), a)
    # a += toLb(5, 0)
    # print(id(a), a)
    # np.array(x, dtype=np.float32)
    # print(siz)
    # w1 = w0.reshape(siz)
    # print(w1.shape)
    # print(w1)
      