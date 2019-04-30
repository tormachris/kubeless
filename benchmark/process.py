#!/usr/bin/env python3
import csv
import os
from pprint import pprint
import numpy as np
import matplotlib.pyplot as plt

#Returns array of csv files in current directory
def getFiles():
    files = [f for f in os.listdir('.') if os.path.isfile(f)]
    return[ f for f in files if f.endswith('.csv') ]

def processFile(fname):
    with open(fname,'r') as f:
        lines=[]
        data=csv.reader(f)
        fields=next(data)
        responseCodes={}
        responsePerSec={}
        responseTimes=[]
        for row in data:
            items=zip(fields,row)
            item={}
            for(name,value) in items:
                item[name]=value.strip()
            sec=int(item['offset'].split('.')[0])
            if sec not in responsePerSec:
                responsePerSec[sec]=1
            else:
                responsePerSec[sec]=responsePerSec[sec]+1
            code=item['status-code']
            if code not in responseCodes:
                responseCodes[code]=1
            else:
                responseCodes[code]=responseCodes[code]+1
            responseTimes.append(item['response-time'])
        maxResponse=max(responseTimes)
        minResponse=min(responseTimes)
        print("Maximum response time was ",maxResponse)
        print("Minimum response time was ",minResponse)
        pprint(responseCodes)
        pprint(responsePerSec)

def processAllFiles():
    files=getFiles()
    for f in files:
        print("Processing ", f)
        processFile(f)

if __name__ == "__main__":
    processAllFiles()
