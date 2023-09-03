#!/usr/bin/env python
import pydicom as dicom
import os
import sys, getopt

try:
    opts, args = getopt.getopt(sys.argv[1:],"hi:",["idir="])
except getopt.GetoptError:
    print('%s -i <input directory>' % os.path.basename(__file__))
    sys.exit(2)
for opt, arg in opts:
    if opt == '-h':
       print('%s -i <input directory>' % os.path.basename(__file__))
       sys.exit()
    elif opt in ("-i", "--idir"):
       filepath = arg
valid_dicom_count=0
for dirName, subdirList, fileList in os.walk(filepath):
    for dcm in fileList:
        try:
            ds = dicom.dcmread(os.path.join(dirName,dcm))
            if ds.SOPClassUID != '1.2.840.10008.5.1.4.1.1.4':
                continue
            if not hasattr(ds,'ImageType'):
                continue
            if not hasattr(ds,'InstanceNumber'):
                continue
            if hasattr(ds,'PixelData'):
                valid_dicom_count+=1
        except:
            pass
print(valid_dicom_count)
