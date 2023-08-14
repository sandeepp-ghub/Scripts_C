#!/proj/mkit/pkgs/minfra/python/3.9.6_v1/bin/python
import os, argparse, glob, re

parser = argparse.ArgumentParser()
parser.add_argument('--file', type=str, required=False) 
parser.add_argument('--bucket_size', type=float, required=False) 
args = parser.parse_args()
cwd = os.getcwd()

# default to relative path to highlight_fails file within track if --file not specified
if args.file:
  rpt_fname = args.file
  if not os.path.isfile(rpt_fname):
     print(f'Error: File {rpt_fname} does not exist!')
     quit()
else:
  rpt_glob = glob.glob('pgv.signoff.dynamic.top/dynamic_run/adsRpt/psi_highlight_fails')
  if not rpt_glob:
      print(f'Error: Could not detect report file name in current track, try --file option')
      quit()
  rpt_fname = max(rpt_glob, key=os.path.getctime)

# default to half percent bucket size
bucket_size = ''
if args.bucket_size:
    bucket_size = args.bucket_size
else:
    bucket_size = 0.5

print(f'{cwd}\n')
print(f'Found PGV failure report: {rpt_fname}')
print(f'Using bucket size of {bucket_size}')

f = open(rpt_fname, 'r')
lines = f.readlines()
count = 0
failures = {}
rpt_style = "voltus"
for line in lines:
  if re.match(".*RUN_TYPE", line):
    rpt_style = "combined"

  if re.match("set inst_name",line):
    count+=1
    if count == 1:
      print(f'Detected report style: {rpt_style}\n')
    if rpt_style == "voltus":
      # pull out % number and convert to float
      percent = re.sub('.*\((.*)%\)', r'\1', line)
      percent = float(percent.strip(' "'))
    elif rpt_style == "combined":
      # compute % number
      percent = re.sub('.*MIN_EIV:\s+(.*)V\s+.*', r'\1', line)
      percent = float(percent.strip(' "'))
      percent = (0.825-percent)/0.825*100
      percent = round(percent, 2)
    else:
      print(f'Error: style {style} not supported.  Valid options are voltus and combined.')
      
    # determine bucket
    bucket = int(percent/bucket_size)
      
    #print(f'{count}: {bucket}: {percent}')
    if failures.get(bucket) is not None:
      failures[bucket] += 1
    else:
      failures[bucket] = 1
        
for key in failures:
  print (f'{key*bucket_size}% -- {(key+1)*bucket_size}%: {failures[key]}')
