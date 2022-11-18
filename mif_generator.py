import numpy as np
import os

filedir = os.getcwd()+"\\memfiles"
filenames = os.listdir(filedir)

f = open('mem_content.mif', 'w')
head = '''DEPTH = 233302;
WIDTH = 4;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT
BEGIN\n'''
f.write(head)
address = 0
for filename in filenames:
    filepath = filedir + "\\" + filename
    for line in open (filepath, "r"):
        f.write(hex(address)[2:])
        f.write(' : ')
        f.writelines(line[:-1])
        f.write(';\n')
        address = address+1

f.write('END;\n')
f.close()