# -*- coding: utf-8 -*-
# 設定するパラメータ　PL AD DDS の繰り返し回数と　1カウントをどの長さにするかのカウント値部分

import sys
import csv
import xlrd
import openpyxl
import platform
import re
pf = platform.system()

#Linux_path = 'C:/Users/NITGC-E/Desktop/Tokken/Python/Pine64-python--pulse/Pulseprogramer/ver2/pulsedata.xlsm'
Linux_path = 'C:/Users/rayou/Python/pulsedata.xlsm'
Mac_path = '/Users/yokooannosuke/Cording/Pine64-python--pulse/Pulseprogramer/ver2/pulsedata.xlsm'


if pf == 'Windows':
    wb = xlrd.open_workbook(Linux_path)
    sheet1 = wb.sheet_by_name('Pulseパラメータ')
elif pf == 'Darwin':
    wb = xlrd.open_workbook(Mac_path)
    sheet1 = wb.sheet_by_name('Pulseパラメータ')


# Excelファイルの行(row)列(col)の先頭は0行0列
# PLの部分のみについて取り出しとsortを行う
PL1, PL2, PL3 = 'PL1', 'PL2', 'PL3' # PL3→PL2
PLnamelist = [PL1, PL2, PL3]
PL_scset = []
PL_nscset = []
PL_ecset = []
PL_necset = []

for n in range(11):  # 3,7,11を指定すれば繰り返し回数、つまりPLの個数を指定出来る
    if n % 4 == 0:  # sc 0,4,8行目
        # col_valuesの長さは常にsheet.nrowsに等しい 。つまり、sheetの一番下の行数となってしまう
        col_value = sheet1.col_values(int(n))
        del col_value[0:3]
        col_nvalue_PLsc = [s for s in col_value if s != '']  # col_value内の’’を削除
        # print(col_nvalue_PLsc)
        for value in col_nvalue_PLsc:
            PL_scset.append(PLnamelist[int(n/4)])
            PL_scset.append(int(value))
            PL_nscset.append(PL_scset)
            PL_scset = []
        # print(PL_nscset) #PLのsc部分のデータ [[PL1,0],...[PL3,12]]

    elif (n - 2) % 4 == 0:  # ec 2,6,10行目
        col_value = sheet1.col_values(int(n))
        del col_value[0:3]
        col_nvalue_PLec = [s for s in col_value if s != '']
        # print(col_nvalue_PLec)
        for value in col_nvalue_PLec:
            PL_ecset.append('')  # ecの方は何も入れない
            PL_ecset.append(int(value))
            PL_necset.append(PL_ecset)
            PL_ecset = []
        # print(PL_necset)  #PLのec部分のデータ [['',2],...['',18]]

allPLdatalist = PL_nscset + PL_necset
# print(allPLdatalist)  # [['PL1', 0], ['', 2], ... ['', 18]]

##################################################################

# ADの部分のみについて取り出し、sortを行う

AD1, AD2, AD3 = 'AD1', 'AD2', 'AD3'
ADnamelist = [AD1, AD2, AD3]

AD_scset = []
AD_nscset = []
AD_ecset = []
AD_necset = []

for n in range(12, 23):  # 右の値15,19,23を指定すれば繰り返し回数、つまりADの個数を指定出来る
    if n % 4 == 0:  # sc 12,16,20行目
        col_value = sheet1.col_values(int(n))
        del col_value[0:3]
        col_nvalue_ADsc = [s for s in col_value if s != '']
        for value in col_nvalue_ADsc:
            AD_scset.append(ADnamelist[int(n/4 - 3)])
            AD_scset.append(int(value))
            AD_nscset.append(AD_scset)
            AD_scset = []
        # print(AD_nscset)  # PLのsc部分のデータ [[PL1,0],...[PL3,12]]

    elif (n - 2) % 4 == 0:  # ec 14,18,22行目
        col_value = sheet1.col_values(int(n))
        del col_value[0:3]
        col_nvalue_ADec = [s for s in col_value if s != '']
        for value in col_nvalue_ADec:
            AD_ecset.append('')
            AD_ecset.append(int(value))
            AD_necset.append(AD_ecset)
            AD_ecset = []
        # print(AD_necset)  # PLのec部分のデータ [['',2],...['',18]]

allADdatalist = AD_nscset + AD_necset
# print(allADdatalist)  # [['AD1', 10], ['', 1], ... ]

#####################################################################################


# DDSの部分のみについて取り出し、scと40bitデータを16進数に直し分けて格納

DDS1, DDS2 = 'DDS1', 'DDS2'
DDSnamelist = [DDS1, DDS2]

col_nvalue = []
DDS_scset = []
DDS_nscset = []
DDS_40set = []
patternnamelist0 = []
patternnamelist = []
patternnamelist_int = []


if pf == 'Windows':
    wb = xlrd.open_workbook(Linux_path)
    sheet2 = wb.sheet_by_name('AD9956パラメータ')

elif pf == 'Darwin':
    wb = xlrd.open_workbook(Mac_path)
    sheet2 = wb.sheet_by_name('AD9956パラメータ')


bitdata = []  # fourty_bitdataからbitdataに変更
pattern_data = []

for n in range(11):
    if (n==2 or n==7):  # 64bit data nの値を変更
        col_value = sheet2.col_values(int(n))
        del col_value[0:6]
        bitdata.extend(col_value)  # 要素の追加
    
    elif (n==3 or n==8):  # pettern
        col_value = sheet2.col_values(int(n))
        del col_value[0:6]
        pattern_data.extend(col_value)
    pattern_data = [int(f) for f in pattern_data]
# print(bitdata)
# print(pattern_data)

# 64bitのDDSdataを16進数16桁に変換
DDSdata_hex = []  # 16進数10桁のDDSdata
DDSdata = []  # 0埋めした16進数16桁のDDSdata
for data64 in bitdata:  # fourty_data→data64に変更
    hexdata = ''
    n = 0
    while n + 3 < 64:  # 40→64に変更
        four_str = data64[n:n + 4]
        four_int = int("0b"+four_str, 0)  # 2進数four_strを数値に変換
        hex_str = format(four_int, 'x')  # 数値four_intを16進数に変換
        hexdata = hexdata + hex_str
        n += 4
    DDSdata_hex.append(hexdata)  # 4bitずつ16進数に変換

for n in range(len(DDSdata_hex)):
    DDSdata.append(DDSdata_hex[n].zfill(16))
# print(DDSdata)

# bitパターンの辞書を定義
bitdata_dict = {}
for i in range(len(DDSdata)):
    if i < 8:
        bitdata_dict['DDS1' + str(pattern_data[i])] = DDSdata[i]
    else:
        bitdata_dict['DDS2' + str(pattern_data[i])] = DDSdata[i]
# print(bitdata_dict)

DDS1_sc1 = sheet1.col_values(24)
DDS2_sc2 = sheet1.col_values(27)
DDS1_pattern = sheet1.col_values(25)
DDS2_pattern = sheet1.col_values(28)

del DDS1_sc1[0:3], DDS1_pattern[0:3], DDS2_sc2[0:3], DDS2_pattern[0:3]
DDS1_sc1 = [int(s) for s in DDS1_sc1 if s != '']
DDS2_sc2 = [int(s) for s in DDS2_sc2 if s != '']
DDS1_pattern = [int(s) for s in DDS1_pattern if s != '']
DDS2_pattern = [int(s) for s in DDS2_pattern if s != '']
print(DDS1_pattern)  # createDDS40bits.pyを実行するとpatternデータがプログラム上消えるバグ
print(DDS2_pattern)  # Excelのpatternを参照なしで使用すると解決する

DDS1data_new = []
for i in range(len(DDS1_sc1)):
    DDS1name = 'DDS1' + str(DDS1_pattern[i])
    DDS1data = [DDS1name, DDS1_sc1[i]]
    DDS1data_new.append(DDS1data)
# print(DDS1data_new)
DDS2data_new = []
for i in range(len(DDS2_sc2)):
    DDS2name = 'DDS2' + str(DDS2_pattern[i])
    DDS2data = [DDS2name, DDS2_sc2[i]]
    DDS2data_new.append(DDS2data)
# print(DDS2data_new)


DDSdata = DDS1data_new + DDS2data_new
DDSdata_new = sorted(DDSdata, key=lambda DDSdata: DDSdata[1])  # ソート
# print(DDSdata_new)


####################################################################################################

# PL,AD,DDSの統合を行う

allPLADDDSdatalist = allPLdatalist + allADdatalist + DDSdata_new
allPLADDDSdatalist.sort(key=lambda count: count[1])  # count順になるようにsort
# print(allPLADDDSdatalist)


#################################################################################################
# allPLADDDSdatalistの被り部分を統合

allPLADDDSdatalist_new = []

i = 0
while i < len(allPLADDDSdatalist):
    j = 1
    while i + j < len(allPLADDDSdatalist):
        if allPLADDDSdatalist[i + j][1] != allPLADDDSdatalist[i][1]:
            break
        allPLADDDSdatalist[i][0] = allPLADDDSdatalist[i][0] + \
            allPLADDDSdatalist[i + j][0]
        j += 1
    allPLADDDSdatalist_new.append(allPLADDDSdatalist[i])
    i = i + j
# print(allPLADDDSdatalist_new)

#################################################################################################

# 対象とカウント値に分割
targetlist0 = []
countlist0 = []
target_list = []
count_list = []

char_DDS = "DDS"

for n in range(len(allPLADDDSdatalist_new)):
    targetlist0.append(allPLADDDSdatalist_new[n][0])
    countlist0.append(allPLADDDSdatalist_new[n][1])
# print(targetlist0)  # ['PL1', '', 'PL1', '', 'AD1', '']
# print(countlist0)  # [0, 2, 5, 9, 10, 11]


DDSname = ["DDS11", "DDS12", "DDS13", "DDS14",
           "DDS15", "DDS16", "DDS17", "DDS18", "DDS21", "DDS22", "DDS23", "DDS24", "DDS25", "DDS26", "DDS27", "DDS28"]


for i in range(len(targetlist0)):
    DDSname_list, PLname, ADname = [], [], []
    if char_DDS in targetlist0[i]:
        DDSname_list = re.findall("DDS" + '[0-9]{2}', targetlist0[i])
        PLname = re.findall("PL" + '[0-3]{1}', targetlist0[i])
        ADname = re.findall("AD" + '[0-3]{1}', targetlist0[i])
        """
        print(DDSname_list)
        print(PLname)
        print(ADname)
        print("-----------------------------")
        """
        if len(PLname) != 0:
            target_list.append(PLname[0])
            count_list.append(countlist0[i])
        else:
            pass
        if len(ADname) != 0:
            target_list.append(ADname[i])
            count_list.append(countlist0[i])
        else:
            pass

        for j in range(len(DDSname_list)):
            target_list.append(DDSname_list[j])
            count_list.append(countlist0[i])

    else:
        target_list.append(targetlist0[i])
        count_list.append(countlist0[i])

# print(target_list)
# print(count_list)


# カウント値操作部分
countlist = []
for k in range(len(count_list)):
    # *100:[1count : 1us] *10000:[1count : 100us] *100000000[1count :1s]
    if char_DDS in target_list[k]:
        if count_list[k] == 0:
            countlist.append(0)
        else:
            countlist.append((count_list[k] * 100)-40)
    else:
        countlist.append(count_list[k] * 100)
    countlist[k] = format(countlist[k], 'b').zfill(32)  # 2進数に変換して32桁になるように0埋め
countlist.sort()
print(countlist)  # カウント値 32桁の2進数表記
#################################################################################################


# 対象操作部分

targetPL1, targetPL2, targetPL3 = [],  [], []
targetAD1, targetAD2, targetAD3 = [], [], []
targetDDS11, targetDDS12, targetDDS13, targetDDS14, targetDDS15, targetDDS16, targetDDS17, targetDDS18 = [
], [], [], [], [], [], [], []
targetDDS21, targetDDS22, targetDDS23, targetDDS24, targetDDS25, targetDDS26, targetDDS27, targetDDS28 = [
], [], [], [], [], [], [], []


targetPL1 = ['1' if 'PL1' in tl else '0' for tl in target_list]
targetPL2 = ['1' if 'PL2' in tl else '0' for tl in target_list]
targetPL3 = ['1' if 'PL3' in tl else '0' for tl in target_list]
targetAD1 = ['1' if 'AD1' in tl else '0' for tl in target_list]
targetAD2 = ['1' if 'AD2' in tl else '0' for tl in target_list]
targetAD3 = ['1' if 'AD3' in tl else '0' for tl in target_list]
targetDDS11 = ['1' if 'DDS11' in tl else '0' for tl in target_list]
targetDDS12 = ['1' if 'DDS12' in tl else '0' for tl in target_list]
targetDDS13 = ['1' if 'DDS13' in tl else '0' for tl in target_list]
targetDDS14 = ['1' if 'DDS14' in tl else '0' for tl in target_list]
targetDDS15 = ['1' if 'DDS15' in tl else '0' for tl in target_list]
targetDDS16 = ['1' if 'DDS16' in tl else '0' for tl in target_list]
targetDDS17 = ['1' if 'DDS17' in tl else '0' for tl in target_list]
targetDDS18 = ['1' if 'DDS18' in tl else '0' for tl in target_list]
targetDDS21 = ['1' if 'DDS21' in tl else '0' for tl in target_list]
targetDDS22 = ['1' if 'DDS22' in tl else '0' for tl in target_list]
targetDDS23 = ['1' if 'DDS23' in tl else '0' for tl in target_list]
targetDDS24 = ['1' if 'DDS24' in tl else '0' for tl in target_list]
targetDDS25 = ['1' if 'DDS25' in tl else '0' for tl in target_list]
targetDDS26 = ['1' if 'DDS26' in tl else '0' for tl in target_list]
targetDDS27 = ['1' if 'DDS27' in tl else '0' for tl in target_list]
targetDDS28 = ['1' if 'DDS28' in tl else '0' for tl in target_list]


bitsdata_32 = []

for j in range(len(targetPL1)):
    v_data = targetDDS28[j] + targetDDS27[j] + targetDDS26[j] + targetDDS25[j] + targetDDS24[j] + targetDDS23[j] + targetDDS22[j] + targetDDS21[j] + \
        targetDDS18[j] + targetDDS17[j] + targetDDS16[j] + targetDDS15[j] + targetDDS14[j] + targetDDS13[j] + targetDDS12[j] + targetDDS11[j] + \
        targetAD3[j] + targetAD2[j] + targetAD1[j] + \
        targetPL3[j] + targetPL2[j] + targetPL1[j]
    bitsdata_32.append(v_data.zfill(32))  # 32桁 000000・・・・あれば1 なければ0表示
print(bitsdata_32)

###################################################################################################

# データ連結部分
# データを16進数に変換
# bitsdata[32bit] + countlist[32bit]を合体させ64bitのデータを生成

Pulsedata = []

for i in range(len(bitsdata_32)):
    pulsedata = (bitsdata_32[i] + countlist[i])
    Pulsedata.append(pulsedata)
print(Pulsedata)  # 64ビットの[bitsdata + countlist0]

Pulsedata_hex = []
for sixfour_bits in Pulsedata:
    hexdata = ''
    n = 0
    while n + 3 < 64:
        four_str = sixfour_bits[n:n+4]
        four_int = int("0b"+four_str, 0)
        hex_str = format(four_int, 'x')
        hexdata = hexdata + hex_str
        n = n + 4
    Pulsedata_hex.append(hexdata)  # 4bitずつ16進数に変換
# print(Pulsedata_hex)  # 64bitのPulsedataを16bitの16進数に変換


################################################################################################

# アドレスデータ部分
addresslist = []
for d in range(17 + len(Pulsedata_hex)):
    addresslist.append(format(d, 'x').zfill(5))
# print(addresslist)  # 5桁の16進数表記


#############################################################################################

# 全データを指定の二次元配列の形に直す部分
csvdata = []
csvdata0 = []
csvdata1 = []
dictvalue = []
# print(bitdata_dict)

for dict_value in bitdata_dict.values():
    dictvalue.append(dict_value)
# print(dictvalue)

loop_count_list = sheet1.col_values(30)  # 31→30に変更
del loop_count_list[0]
loop_count_list = [int(s) for s in loop_count_list if s != '']
loop_count = loop_count_list[0]
loop_count_hex = format(loop_count, 'x')
csv_first_data = str(loop_count_hex).zfill(16)

csvdata = [[addresslist[0], csv_first_data]]

for i in range(len(dictvalue)):
    csvdata_until_dds = [addresslist[i + 1], dictvalue[i]]
    csvdata.append(csvdata_until_dds)
# print(csvdata)  # DDSの部分までのCSV

for j in range(len(Pulsedata_hex)):
    csvdata_pulse = [addresslist[17 + j], Pulsedata_hex[j]]
    csvdata.append(csvdata_pulse)
# print(csvdata)  # 全CSVdata


# CSVファイル生成部分

with open("Outdata_for_FPGA.csv", "w")as f:
    writer = csv.writer(f, lineterminator="\n")
    writer.writerows(csvdata)
print('finished!')
print('何かキーを押してください')
input()