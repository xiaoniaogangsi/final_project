import os

f = open('zero_initialization.txt', 'w')
zeros = int(input('How many zeros do you want to generate? '))
for i in range(zeros):
    f.write('0\n')
f.close()
