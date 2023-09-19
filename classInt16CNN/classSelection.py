#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# from sys import exit as sys_exit
# from scipy.io import loadmat

class classSelection:
    def __init__(self, test_index=60000):
        self.test_index = test_index
        self.label_list = []
        self.label_start = []
        self.label_stop = []
        self.label_current = []
        self.probe_index_list = []
        self.probe_mask = []
        self.probe_len = 0
        self.idle_index_list = []
        self.idle_len = 0
        self.all_zero = False
        self.mux_probe = True
        self.cur_probe = 0
        self.cur_idle = 0
        self.label_pos = 0
        
    def __str__(self):
        return 'classSelection'
        
    def analise(self, label):
        cur_label = label[0]
        self.label_list = [cur_label]
        self.label_start = [0]
        for i in range(self.test_index):
            if cur_label != label[i]:
                cur_label = label[i]
                if cur_label in self.label_list:
                    return False
                self.label_list.append(cur_label)
                self.label_start.append(i)
                self.label_stop.append(i-1)
        self.label_stop.append(self.test_index-1)
        self.label_current = self.label_start.copy()
        self.probe_len = len(self.label_list)
        self.probe_index_list = [i for i in range(self.probe_len)]
        self.probe_mask = [0 for i in range(self.probe_len)]
        return True      
        
    def actualization(self, actual_labels, all_zero=False, restart=False):
        mask = []
        for i in actual_labels:
            if not (i in self.label_list):
                return False
        self.probe_index_list = []
        self.idle_index_list = []
        self.probe_mask = []
        for i in range(len(self.label_list)):
            if self.label_list[i] in actual_labels:
                self.probe_index_list.append(i)
                mask.append(1.0)
                self.probe_mask.append(0)
            else:
                self.idle_index_list.append(i)
                mask.append(0.0)
        self.probe_len = len(self.probe_index_list)
        self.idle_len = len(self.idle_index_list)
        self.all_zero = all_zero if self.idle_len!=0 else False
        self.mux_probe = True
        
        if restart:
            self.label_current = self.label_start.copy()
            self.cur_probe = 0
            self.cur_idle = 0
        return mask   

    def next_index(self, lot_error=False):
        probe_mask = self.probe_mask.copy()
        if self.mux_probe:
            i = self.probe_index_list[self.cur_probe]
            probe_mask[self.cur_probe] = 1
            self.cur_probe += 1
            if lot_error:
                if self.cur_probe >= self.probe_len:
                    self.cur_probe = 0
                if self.all_zero:
                    self.mux_probe = not self.mux_probe   
            else:
                if self.cur_probe >= self.probe_len:
                    self.cur_probe = 0
                    if self.all_zero:
                        self.mux_probe = not self.mux_probe
        else:
            i = self.idle_index_list[self.cur_idle]
            self.cur_idle += 1
            if self.cur_idle >= self.idle_len:
                self.cur_idle = 0
            self.mux_probe = not self.mux_probe
        self.label_pos = i
        index = self.label_current[i]
        if index == self.label_stop[i]:
            self.label_current[i] = self.label_start[i]
        else:
            self.label_current[i] = index + 1
        return index, probe_mask
        
    def get_train_ctrl(self):
        train_ctrl_list = []
        for pi in self.probe_index_list:
            for i in range(self.label_start[pi], self.label_stop[pi]+1):
                train_ctrl_list.append(i)
        return train_ctrl_list
        
if __name__ == '__main__':
    print('classSelection')
    # mnist = loadmat("../Database/mnist-original.mat") 