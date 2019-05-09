from __future__ import print_function
import argparse
import textwrap
import os
import re
import csv
import math

def msp_split(i, o, n):
    spec_total = lcount('NAME', i)
    spec_lim = math.ceil(spec_total/float(n))
    spec_c = 0
    filelist = []
    header = ''
    print('spec_lim', spec_lim)
    with open(i, 'r') as msp_in:
        for i in range(1, n+1):
            with open(os.path.join(o, 'file{}.msp'.format(str(i).zfill(len(str(n))))), 'w+') as msp_out:
                while spec_c <= spec_lim:
                    if header:
                        msp_out.write(header)
                        header = ''
                    line = msp_in.readline()

                    if not line:
                        break  # end of file

                    if re.match('^NAME:.*$', line, re.IGNORECASE):
                        header = line
                        spec_c += 1
                    else:
                        msp_out.write(line)
                spec_c = 1 

    return filelist

def lcount(keyword, fname):
    with open(fname, 'r') as fin:
        return sum([1 for line in fin if keyword in line])

def main():

    p = argparse.ArgumentParser(prog='PROG',
                                formatter_class=argparse.RawDescriptionHelpFormatter,
                                description='''split msp files''',
                                )

    p.add_argument('-i', dest='i', help='msp file', required=True)
    p.add_argument('-o', dest='o', help='out dir', required=True)
    p.add_argument('-n', dest='n',)


    args = p.parse_args() 

    if not os.path.exists(args.o):
        os.makedirs(args.o)
    print('in file', args.i)
    print('out dir', args.o)
    print('nm files', args.n)

    msp_split(args.i, args.o, int(args.n))


if __name__ == '__main__':
    main()

