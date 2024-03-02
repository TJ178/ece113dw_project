import numpy as np
import argparse
import math

parser = argparse.ArgumentParser(description="Generates window.mem file for a given bit-width")

parser.add_argument("-m", "--mag_bits", type = int, help = "Number of magnitude bits", required=True)
parser.add_argument("-f", "--frac_bits", type = int, help = "Number of fraction bits", required=True)
parser.add_argument("-n", "--window_size", type = int, help = "Number of samples in a window", required=True)

args = parser.parse_args()

def round(i, precision):
    o = i
    if (o / precision) - math.floor(o / precision) >= 0.85:
        return math.ceil(o / precision) * precision
    else:
        return math.floor(o / precision) * precision

precision = 2**(-args.frac_bits)

vals = np.hamming(args.window_size)


form =  "0" + str(args.frac_bits+1) + "b"
with open("window.mem", "w") as f:
    for i in vals:
        o = int(round(i,precision)*2**(args.frac_bits))
        o = format(o, form)
        f.write(o+ "\t//" + str(round(i,precision)) + "\n")
