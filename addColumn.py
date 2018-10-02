#!/usr/bin/python

import sys
import array
import itertools
import numpy
import re
import math

#Read in the list you would like to add another column to
if sys.argv[1] == "-" :
    myFile = sys.stdin
else :
    try :
        myFile = open(sys.argv[1], 'rU')
    except :
        print 'run: \n\nFile 1 not found\n'
        exit()

#Specify the column to match to the second file
colF1 = int(sys.argv[2])

#Read in the list you would like to query
try :
    myFile2 = open(sys.argv[3], 'rU')
except :
    print 'run: \n\nFile 2 not found\n'
    exit()

#Specify the column in the second file to match to
McolF2 = int(sys.argv[4])

#Specify the column in the second file to return
RcolF2 = int(sys.argv[5])

#Read in the placement of the new column
place = sys.argv[6]

#Read through the database or query file recording entries in dictionary
i=0
for line in iter(myFile2) :

    #Ignore comment lines
    if line[0] != "#" :
         i+=1

    #For the first row, initialise the dictionary
    if i==1 :
        #split the line into fields 
        fields = line[:-1].split("\t", line.count("\t"))
        #Make the dictionary
        myDict = {fields[McolF2-1]:[fields[RcolF2-1]]}

    #For other rows, add to the dictionary
    if i > 1 :
        #split the line into fields
        fields = line[:-1].split("\t", line.count("\t"))
        #Add to the dictionary
        try: 
            myDict[fields[McolF2-1]].append(fields[RcolF2-1])
        except:
            myDict.update({fields[McolF2-1]:[fields[RcolF2-1]]})

#Close the file
myFile2.close()

#Iterate through the file
for line in iter(myFile) :

    #split the line into fields
    fields = line[:-1].split("\t", line.count("\t"))

    #Split up the conlumn entry according to commas
    IDs=fields[colF1-1].split(",", line.count(","))

    #For each of the IDs, query the dictionary
    newIDs = []
    for ID in IDs :
        if ID == "-" :
            newIDs.append("-")
        else :
            try :
                i=0
                entry=""
                for val in myDict[ID] :
                    i+=1
                    entry = entry + val
                    if i < len(myDict[ID]) :
                        entry = entry+","
                newIDs.append(entry)
            except :
                newIDs.append("-")

    #Make into a comma seperated list
    i=0
    entry=""
    for ID in newIDs :
        i+=1
        entry = entry + ID
        if i < len(newIDs) :
            entry = entry+","

    #Return the line with the new IDs as the last column
    if place == "last" :
        print '%s\t%s' % (line[:-1], entry)
    elif place == "replace" :
        fields[colF1-1] = entry
        print '\t'.join(str(p) for p in fields)
    else :
        print '%s\t%s' % (entry, line[:-1])

if sys.argv[1] != "-" :
    myFile.close()
