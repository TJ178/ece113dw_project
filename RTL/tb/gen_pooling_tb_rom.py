import numpy as np
import argparse
import skimage.measure

parser = argparse.ArgumentParser(description="Generates split ROM for cnn testbench given an input csv")
parser.add_argument("-n", "--bitwidth", type = int, help = "Number of bits per value", required=True)
parser.add_argument("-s", "--split", type = int, help = "Number of layers to split to", required=True)
parser.add_argument("-p", "--pooling_size", type = int, help = "Prints maxpool by pooling size if supplied", required=False)
parser.add_argument('filename')
args = parser.parse_args()

data = np.loadtxt(args.filename, dtype="int", delimiter=",")
print(data.shape)

data2 = np.zeros((args.split, int(np.ceil(data.shape[0] / args.split) * data.shape[1])))
print(data2.shape)

if(args.pooling_size):
    print(skimage.measure.block_reduce(data, (args.pooling_size,args.pooling_size), np.max))

for idx in range(data2.shape[0]):
    cut = data[idx::args.split].flatten()
    if(cut.shape[0] != data2.shape[1]):
        cut = np.append(cut, np.zeros((data2.shape[1] - cut.shape[0],)))
    data2[idx] = cut

for idx, row in enumerate(data2):
    with open("pooling_rom" + str(idx) + ".mem", "w") as f:
        f.write("// Pooling test ROM # " + str(idx) + "\n")
        for d in row:
            f.write("{:016b}".format(int(d)))
            f.write(" //")
            f.write(str(d))
            f.write("\n")