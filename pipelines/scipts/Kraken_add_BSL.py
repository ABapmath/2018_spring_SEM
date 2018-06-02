#!/usr/bin/python
import sys, getopt
def main(argv):
    report = ''
    bsl = ''
    out = ''
    try:
        opts, args = getopt.getopt(argv,"h",["report=","bsl=","out="])
    except getopt.GetoptError:
        print '  error: arguments names are not applicable'
        print '  usage:'
        print '  Kraken_add_BSL.py --report <Report> --bsl <tax_id_to_BSL> --out <Report_new>'
        print '  use -h for help message'
        sys.exit()
    for opt, arg in opts:
        if opt == '-h':
            print '  uses <tax_id_to_BSL> to add information to <Report> and print into <Report_new>'
            print '  usage:'
            print '  Kraken_add_BSL.py --report <Report> --bsl <tax_id_to_BSL> --out <Report_new>'
            sys.exit()
        elif opt in ("--report"):
            report = arg
        elif opt in ("--bsl"):
            bsl = arg
        elif opt in ("--out"):
            out = arg
    if report == '' or bsl == '' or out == '':
        print '  error: some arguments are not specified'
        print '  usage:'
        print '  Kraken_add_BSL.py --report <Report> --bsl <tax_id_to_BSL> --out <Report_new>'
        print '  use -h for help message'
        sys.exit()
    BSL_dict = {}
    with open(bsl, 'r') as bsl_file:
        for line in bsl_file:
             if len(line) <= 2:
                 continue
             line = line[:-1]
             l = line.split('\t')
             BSL_dict[l[0]] = l[1]
    with open(report,'r') as rep_file, open(out,'w') as out_file:
         for line in rep_file:
             l = line.split('\t')
             if len(l) < 6:
                 continue
             Taxid = l[4]
             BSL = '('
             if Taxid in BSL_dict:
                 BSL += BSL_dict[Taxid]
             BSL += ')'
             out_file.write('\t'.join(l[:5])+'\t'+BSL+'\t'+'\t'.join(l[5:]))
if __name__ == "__main__":
    main(sys.argv[1:])

