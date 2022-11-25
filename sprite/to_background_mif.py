



import os
# get all txt files in the folder
files = [f for f in os.listdir('.') if os.path.isfile(f) and f.endswith('.txt') and not f.startswith('200')]

# cat all txt files into one txt file
with open('2000.txt', 'w') as f:
    for txt_file in files:
        with open(txt_file, 'r') as txt:
            for line in txt:
                f.write(line)
            txt.close()


def create_mif_head(f):
            f.write('DEPTH = 65536;\n')
            f.write('WIDTH = 4;\n')
            f.write('ADDRESS_RADIX = HEX;\n')
            f.write('DATA_RADIX = HEX;\n')
            f.write('CONTENT\n')
            f.write('BEGIN\n')





output_file1 = "onchip1.mif"
output_file2 = "onchip2.mif"
output_file3 = "onchip3.mif"
output_file4 = "onchip4.mif"
output_files=[output_file1,output_file2,output_file3,output_file4]
txt= open('2000.txt', 'r') 

for i in range(4):
    f=open(output_files[i], 'w')
    create_mif_head(f)
    for k in range(0, 65536):
        line = txt.readline()
        if not line:
            break
        f.write('%04X: %s;\n' % (k, line.strip()))
    f.write('END;\n')
    f.close()




