
fname_lmk = 'zcu111_lmk04208_10M.txt'
fname_lmzA = 'zcu111_lmx2594_chA.txt'
fname_lmzB = 'zcu111_lmx2594_chB.txt'
fname_lmzC = 'zcu111_lmx2594_chC.txt'

with open('../zcu111_clock_config.h','w') as dfid:
    dfid.write('#ifndef _ZCU111_CLOCK_CONIFG_H_\n')
    dfid.write('#define _ZCU111_CLOCK_CONIFG_H_\n')

    dfid.write('\n')

    dfid.write('#define LMK04208_count 26\n')
    dfid.write('#define LMX2594_count 113\n')

    dfid.write('\n')

    dfid.write('static unsigned int LMK04208_CK_def[LMK04208_count] = {\n')
    with open(fname_lmk,'r') as rfid:
        for i in range(26):
            ln = rfid.readline()
            sval = (ln.split('\t')[1])[0:-1]
            dfid.write('%s%s' % (sval, ',' if i < 25 else '\n'))
    dfid.write('};\n')

    dfid.write('\n')

    dfid.write('static unsigned int LMX2594_CKs_def[3][LMX2594_count] = {\n')
    dfid.write('{')
    with open(fname_lmzA, 'r') as rfid:
        for i in range(113):
            ln = rfid.readline()
            sval = (ln.split('\t')[1])[0:-1]
            dfid.write('%s%s' % (sval, ',' if i < 112 else '},\n'))
    dfid.write('{')
    with open(fname_lmzB, 'r') as rfid:
        for i in range(113):
            ln = rfid.readline()
            sval = (ln.split('\t')[1])[0:-1]
            dfid.write('%s%s' % (sval, ',' if i < 112 else '},\n'))
    dfid.write('{')
    with open(fname_lmzC, 'r') as rfid:
        for i in range(113):
            ln = rfid.readline()
            sval = (ln.split('\t')[1])[0:-1]
            dfid.write('%s%s' % (sval, ',' if i < 112 else '}\n'))
    dfid.write('};\n')

           
    dfid.write('\n')

    
    dfid.write('#endif\n')
    

