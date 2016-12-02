#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys

number_of_input = len(sys.argv)

if number_of_input < 2:
    print("no input file. abort mission")
    exit()

in_file_name = sys.argv[1]
our_format_file_name = in_file_name+'.ours'


with open(in_file_name,'rb') as data_file:
    print('converting Polyakov\'s format into ours')
    data = data_file.read()
    data_dec = data.decode('cp1251')
    remove_chars = dict.fromkeys(map(ord,'\"\''),None)
    data_simplified = data_dec.translate(remove_chars)

with open(our_format_file_name,'w') as out_file:
    data_out = ''
    pos_index = 0
    syl_length = 0
    for char in data_simplified:
        if char == '\r':
            data_out = data_out + str(pos_index) + ' ' + str(syl_length) + ' ? '
            pos_index += syl_length
            syl_length = 0
        else:
            syl_length += 1
    out_file.write(data_out)
