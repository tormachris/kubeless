#!/usr/bin/env python3
import csv
import os
import pprint
import numpy as np
import matplotlib.pyplot as plt

#Returns array of csv files in current directory
def getFiles():
    files = [f for f in os.listdir('.') if os.path.isfile(f)]
    return[ f for f in files if f.endswith('.csv') ]

def processFile(fname):
    with open(fname) as f:
        lines=[]
        data=csv.reader(f)
        fields=data.next()
        for row in data:
            items=zip(fields,row)
            item={}
            for(name,value) in items:
                item[name]=value.strip()
            lines.append(item)
        return lines

def processor(lines):
    responseCodes={}
    responsePerSec={}
    responesTimes=[line['response-time'] for line in lines]
    maxResponse=max(responesTimes)
    minResponse=min(responesTimes)
    for line in lines:
        sec=line['response-time'] // 1
        if responsePerSec[sec] == None:
            responsePerSec[sec]=1
        else:
            responsePerSec[sec]=responsePerSec[sec]+1
        code=line['status-code']
        if responseCodes[code]==None:
            responseCodes[code]=1
        else:
            responseCodes[code]=responseCodes[code]+1
    print("Maximum response time was ",maxResponse)
    print("Minimum response time was ",minResponse)
    pprint(responseCodes)
    pprint(responesTimes)

def processAllFiles():
    files=getFiles()
    for f in files:
        lines=processFile(f)
        processor(lines)

if __name__ == "__main__":
    processAllFiles()
