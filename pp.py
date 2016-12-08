#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys

number_of_input = len(sys.argv)

if number_of_input < 2:
    print("no input file. abort mission")
    exit()

in_file_name = sys.argv[1]
stressed_file_name = in_file_name+'.sstr'


with open(in_file_name,'rb') as data_file:
    print('converting Polyakov\'s format into ours')
    data = data_file.read()
    data_dec = data.decode('utf8')

with open(stressed_file_name,'w') as stress_file:
    stress_pos = []
    pos_index = 0
    index = 0
    for char in data_dec:
        if char == '\'':
            stress_pos.append(pos_index-1)
        elif char == '"':
            stress_pos.append(pos_index-1)
        elif char == '`':
            pass
        else:
            pos_index += 1
        index += 1 

    stress_pos = sorted(set(stress_pos))

    stress_file.write(str(stress_pos).replace(" ","")[1:-1])

