import os, sys

def cleanbib(inpath):
    strings = ("mendeley-", "abstract =", "abstract=", "issn =", "issn=", "doi =", "doi=", "url =", "url=", "urldate =", "urldate=", "keywords =", "keywords=", "language =","language=", "file =", "file=", "date-", "note=", "note =", "annote=", "annote =", "copyright=", "copyright =")

    bibs = [f for f in os.listdir(inpath) if f.endswith('.bib')]
    outpath = os.path.join(inpath, 'cleanbib')
    if not os.path.exists(outpath):
        os.mkdir(outpath)
    
    for infile in bibs:
        outfile = os.path.join(outpath, infile)
        infile = os.path.join(inpath, infile)
        print(infile)
        print(outfile)
        with open(infile) as bib, open(outfile, 'w') as newbib:
            for line in bib:
                if not any(s in line.lower() for s in strings):
                    newbib.write(line)
                else:
                    while not any(e in line for e in ("}", "},")):
                        line = next(bib)
        bib.close()
        newbib.close()

if __name__ == "__main__":
    cleanbib(sys.argv[1])
