import os

filedir = os.getcwd()+"\\memfiles"
filenames = os.listdir(filedir)

f = open('mem_content.mif', 'w')
head = '''DEPTH = 64530;
WIDTH = 16;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT
BEGIN\n'''
f.write(head)
address = 0
counter = 0
for filename in filenames:
    filepath = filedir + "\\" + filename
    for line in open (filepath, "r"):
        if (counter == 0):
            addr = hex(address)[2:]
            for i in range(0, 4-len(addr)):
                addr = '0' + addr
            f.write(addr)
            f.write(' : ')
            f.writelines(line[:-1])
        else:
            f.writelines(line[:-1])
        if (counter < 3):
            counter = counter+1
        else:
            address = address+1
            f.write(';\n')
            counter = 0
if (counter != 0):
    for i in range(0, 4-counter):
        f.write('0')
    f.write(';\n')
f.write('END;\n')
f.close()