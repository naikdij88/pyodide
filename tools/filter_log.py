import sys
import re

for line in sys.stdin.readlines():
    line = line.rstrip()
    skip = False
    if re.match(".*\.js:[0-9]+:[0-9]+$", line):
        skip = True
    for token in ["Object", " action", " prev state", " next state"]:
        if line.startswith(token):
            skip = True
            break
    if not skip:
        print(line)
