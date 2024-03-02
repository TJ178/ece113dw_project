#   Generates a memory file samples.mem that can be used in RTL simulation.
#   Takes in any wav audio file and converts it into a format readable by $readmemb

import argparse
import numpy as np
from scipy.io import wavfile as wave

parser = argparse.ArgumentParser(description="Generates samples.mem file for a given input file")
parser.add_argument("-n", "--bitwidth", type = int, help = "Number bits per sample", required=True)
parser.add_argument('filename')
args = parser.parse_args()

rate, data = wave.read(args.filename)

sample_bits = data[0].nbytes*8
print("sample bit width:", sample_bits)
print("Frames:", data.shape[0])

precision = 2**args.bitwidth
oldprecision = 2**(sample_bits)

min_val = np.iinfo(type(data[0])).min

data = np.float64(data)
data -= min_val
data = np.int16(data / oldprecision * precision)

form =  "0" + str(args.bitwidth) + "b"
with open("samples.mem", "w") as f:
    f.write("// " + args.filename + "\n")
    f.write("// " + str(sample_bits) + "-bit samples converted to " + str(args.bitwidth) + "-bit samples\n")
    for i in data:
        o = format(int(i), form)
        f.write(o+ "\t//" + str(i) + "\n")
