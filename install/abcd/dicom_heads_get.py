#!/usr/bin/env python3

# Created:  08/28/17 by Octavio Ruiz
# Prev Mod: 03/02/18 by Octavio Ruiz
# Last Mod: 06/04/18 by Octavio Ruiz

import sys, os

import warnings
warnings.simplefilter(action='ignore', category=UserWarning)
import pandas as pd
pd.set_option('display.width', 1024)
pd.set_option('max_colwidth', 180)

import pydicom as dicom
import json


#---------------------------------------------------------------------------------------------------------------------
if len(sys.argv) != 3:
    print('Find all DICOM files under a given directory, including subdirectories;')
    print('read header information from each DICOM file, group by SeriesIDs, and returns result as a JSON string')
    print('to be received by Matlab and translated into a structure.')
    print('                                                                Octavio Ruiz,   2017aug28 - 2018jun04')
    print('Usage:')
    print('  ./dicom_heads_get.py  dir  option')
    print()
    print('Option:')
    print('  js    Output json dictionary with the extracted structure')
    print('  show  Report files and series found, do not print json dictionary')
    # print('  save  save spreadsheet with the extracted structure to local directory')
    print()
    print('Example:')
    print('  ./dicom_heads_get.py  /space/syn05/1/data/MMILDB/DAL_ABCD_TEST/orig/G010_INV0F78WV5U_20161012  js')
    print()
    sys.exit()
else:
    fdir   = sys.argv[1]
    option = sys.argv[2]
#---------------------------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------------------------------------
# Find files under path, read each file's header (if file is DICOM) and construct table with this information, one row per file

Files = [] #pd.DataFrame()
# j = 0    # Used only during Tests

for path, dirnames, fnames in os.walk( fdir, followlinks=True ):

    if option == 'show':
        print()
        print('path:', path)
        print('  len(dirnames) =', len(dirnames),  ',  len(fnames) =', len(fnames) )

    # print('--Test:...')
    # j += 1
    # if j > 3:
    #     print('... :Test--')
    #     break 

    num_files_not_dicom          = 0
    num_dicom_files_not_readable = 0
    msg = ''

    if len(fnames) > 0:
        FileNames = []
        EchoTimes = []
        InstanceNumbers = []
        i = 0
        File1_NameFull = ''

        for fname in fnames:
            fname_full = path + '/' + fname

            try:
                #ds = dicom.dcmread(fname_full)
                # only read the tags we absolutely need, may speed up reading the files
                ds = dicom.dcmread(fname_full, specific_tags=[("0x0020","0x000e"),("0x0020","0x000d"),("0x0020","0x0013"),("0x0018","0x0081"),("0x0020","0x0011")])
            except:
                # File is not a DICOM data set
                num_files_not_dicom += 1
                continue

            # Check that all required fields exist and are readable.
            # Some dicom files headers do not have variable EchoTime; these files are invalid, and should be excluded
            try:
                this_SeriesInstanceUID = ds.SeriesInstanceUID
                this_SeriesNumber      = ds.SeriesNumber
                this_StudyInstanceUID  = ds.StudyInstanceUID
                this_InstanceNumber    = ds.InstanceNumber
                this_EchoTime          = ds.EchoTime
                # If we arrive here, things are good
                msg = ''
            except:
                msg = 'DICOM file has missing fields or is not interpretable'
                this_SeriesInstanceUID = ''
                this_SeriesNumber      = ''
                this_StudyInstanceUID  = ''
                this_InstanceNumber    = ''
                this_EchoTime          = ''
                num_dicom_files_not_readable += 1
                continue

            i += 1
            if i == 1:
                File1_NameFull = fname_full
                SeriesInstanceUID = this_SeriesInstanceUID
                SeriesNumber      = this_SeriesNumber
                StudyInstanceUID  = this_StudyInstanceUID
                InstanceNumber    = this_InstanceNumber
                EchoTime          = this_EchoTime

            # FileNames.append( fname_full )
            # EchoTimes.append( this_EchoTime )
            # InstanceNumbers.append( this_InstanceNumber )

            rec = pd.DataFrame( {'i': i,  'FileName': fname_full,
                                 'SeriesNumber': this_SeriesNumber,  'StudyInstanceUID': this_StudyInstanceUID,
                                 'SeriesInstanceUID': this_SeriesInstanceUID,  'InstanceNumber': this_InstanceNumber,
                                 'EchoTime': this_EchoTime,  'errmsg': msg,  'File1_NameFull': File1_NameFull },  index = [i] )
            #Files = Files.append( rec )
            #print(Files.shape)
            # append to a list
            Files.append(rec)
            
# now concat all frames
Files = pd.concat(Files, axis = 0, ignore_index=True)
#print(Files.shape)

# end for fname in fnames

Files = Files[['i', 'FileName', 'SeriesNumber', 'StudyInstanceUID', 'SeriesInstanceUID', 'InstanceNumber', 'EchoTime', 'errmsg', 'File1_NameFull']]
Files = Files.sort_values( by=['FileName', 'SeriesInstanceUID'] )

if option == 'show':
    print('Files.iloc[[0,-1]]:' )
    print( Files.iloc[[0,-1]], '\n')
    print('Files.shape =', Files.shape )
    print('num_files_not_dicom =', num_files_not_dicom )
    print('num_dicom_files_not_readable =', num_dicom_files_not_readable )

if option == 'save':
    print()
    fname = 'dicoms_table.csv'
    print('Here I would save table to:', fname )   # Files.to_csv( fname )
    print()
#---------------------------------------------------------------------------------------------------------------------



# for j, ser in enumerate( Series_List['SeriesInstanceUID'] ):

#     subset = Files[ Files['SeriesInstanceUID'] == ser ]




#---------------------------------------------------------------------------------------------------------------------
# Group file information by Series ID; construct a new table, one row per series

Series_List = Files.drop_duplicates( subset=['StudyInstanceUID', 'SeriesInstanceUID'], keep='first' )
Series_List.index = Series_List.reset_index().index + 1

if option == 'show':
    print()
    print('Found %.0f instances of Study-Series IDs\n' % len(Series_List) )
    print('Series_List')
    # print( Series_List )
    print( Series_List[['StudyInstanceUID', 'SeriesInstanceUID']] )
    print()


for j in range(0,len(Series_List)):
    stud = Series_List.iloc[j]['StudyInstanceUID']
    ser  = Series_List.iloc[j]['SeriesInstanceUID']
 
    subset = Files[ (Files['StudyInstanceUID'] == stud) & (Files['SeriesInstanceUID'] == ser) ]

    rec = pd.DataFrame( {
        'SeriesInstanceUID': subset['SeriesInstanceUID'].iloc[0],
        'SeriesNumber':      subset['SeriesNumber'].iloc[0],
        'StudyInstanceUID':  subset['StudyInstanceUID'].iloc[0],
        'InstanceNumber':    subset['InstanceNumber'].iloc[0],
        'EchoTime':          subset['EchoTime'].iloc[0],
        'FileNames':        [subset['FileName'].tolist()],
        'EchoTimes':        [subset['EchoTime'].tolist()],
        'InstanceNumbers':  [subset['InstanceNumber'].tolist()],
        'errmsg':           '' },  index = [j] )

    if j == 0:
        Series = rec
    else:
        #Series = Series.append( rec )
        Series = pd.concat([Series, rec], axis=0, ignore_index=True)

Series = Series[['SeriesInstanceUID', 'SeriesNumber', 'StudyInstanceUID', 'InstanceNumber', 'EchoTime', 'FileNames', 'EchoTimes', 'InstanceNumbers', 'errmsg']]


if option == 'show':
    print('               Series:')
    for j in range(0, len(Series) ):
        if j < 4  or  ( j >= 4 and j < (len(Series)-4) ):
            print('j =', j+1 )
            print( Series.iloc[j] )
            print("len('FileNames','EchoTimes','InstanceNumbers'): ", 
                    len(Series.iloc[j]['FileNames']), len(Series.iloc[j]['EchoTimes']), len(Series.iloc[j]['InstanceNumbers']) )
            print()

    print()
#---------------------------------------------------------------------------------------------------------------------



#---------------------------------------------------------------------------------------------------------------------
# Export Series information into a JSON string, written to the standard output.
# This text is intended to be received by a Matlab program, that will translate it into an structure array.

# Hagler, Donald.  Tuesday, February 20, 2018 2:38 PM :
# ... the directory names are not the same as the Series UIDs... because of the multi-band recon creating new SeUIDs.
# I have changed this, so in the future, they will have their original SeUIDs.
# So, it would be the wrong thing to sort by the SeUID in this case. So, please sort them by the order in the file list.

if option == 'js':
    table_js = Series.to_json(orient='index')
    print( table_js )

# elif option == 'save':
#     # print( table.iloc[ list(range(0,3)) + list(range(-3,0)) ] )
#     print( table )
#     fname = 'dicoms_table.csv'
#     print('Saving table to:', fname )
#     table.to_csv( fname )
#---------------------------------------------------------------------------------------------------------------------




#---------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------

# sers_list = Files['SeriesInstanceUID'].unique()

# if option == 'show':
#     print('sers_list')
#     print( sers_list, '\n')

# for j, ser in enumerate( sers_list ):
