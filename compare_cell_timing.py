#!/proj/mkit/pkgs/minfra/python/3.9.6_v1/bin/python3

import gzip
import sys
import re
import matplotlib.pyplot as plt

slack1 = {}
slack2 = {}
allpins = {}
typ = {}
lines = {}
diffs = {}

def read_report(num):
    global slack1
    global slack2
    global allpins
    global typ
    if re.search(".gz$", sys.argv[num]):
        print(f"parsing {sys.argv[num]} as gzip")
        x = gzip.open(sys.argv[num], mode="rt")
    else:
        print(f"parsing {sys.argv[num]} as not gzip")
        x = open(sys.argv[num])
    with x as datain:
        for line in datain:
            m = re.search("signoff.sta/([^\/]+)\S+rpt:([io]\S+) (\S+) (\S+)", line)
            if m:
                ep = m.group(4)
                test = m.group(2)
                view = m.group(1)
                allpins[f"{view} {test}>{ep}"] = 1
                if num == 1:
                    slack1[f"{view} {test}>{ep}"] = m.group(3)
                elif num == 2:
                    slack2[f"{view} {test}>{ep}"] = m.group(3)
                continue
            m = re.search("^([io]\S+) (\S+) (\S+)", line)
            if m:
                ep = m.group(3)
                test = m.group(1)
                allpins[f"{test}>{ep}"] = 1
                if num == 1:
                    slack1[f"{test}>{ep}"] = m.group(2)
                elif num == 2:
                    slack2[f"{test}>{ep}"] = m.group(2)
                continue

read_report(1)
read_report(2)

xlist = []
ylist = []
count = 0
with open('output.txt', 'w') as f:
    for key in allpins.keys():
#        print(f"{slack1[key]} {slack2[key]} {key}")
        line = ""
        if slack1.get(key) is None:
            print(f"{slack2[key]} missing {key} from file 1", file=f)
            continue
    #     $slack1{$key} = 0.001;
        if slack2.get(key) is None:
            print(f"{slack1[key]} missing {key} from file 2", file=f)
            continue
    #     $slack2{$key} = 0.001;
        if (slack1.get(key) == "N/A" and slack2.get(key) == "N/A"):
            print(f"{key} is N/A", file=f)
            continue
        if (slack1.get(key) == "N/A" or slack2.get(key) == "N/A"):
            print(f"ERROR  {slack1[key]} {slack2[key]} on {key} ", file=f)
            continue

        slack1[key] = float(slack1[key])
        slack2[key] = float(slack2[key])
        if slack1.get(key) < -200000:
            print(f"{slack2[key]} too big {key} from file 1", file=f)
            continue
    #     $slack1{$key} = 0.001;
        if slack2.get(key) < -200000:
            print(f"{slack1[key]} too big {key} from file 2", file=f)
            continue
    #     $slack2{$key} = 0.001;
        count += 1
        xlist.append(slack1[key])
        ylist.append(slack2[key])
        diff = slack1[key] - slack2[key]
        if abs(diff) > -1:
            lines[key] = f"{slack1[key]} {slack2[key]} {diff} {key}"
            diffs[key] = diff

    diffs2 = []
    for key in sorted(diffs, key=diffs.get):
        print(lines[key], file=f)
        diffs2.append(diffs[key])

plt.style.use('seaborn')
fig, (diffplot, hist, xyplot) = plt.subplots(ncols=3)
diffplot.plot(diffs2)
diffplot.set_title("diffs", fontsize=20)
diffplot.set_xlabel("path", fontsize=15)
diffplot.set_ylabel("diff (file1-file2)", fontsize=15)
xyplot.scatter(xlist, ylist)
hist.hist(diffs2)
plt.savefig('output.png')
#plt.show()
print(f"found {count} points to compare")
