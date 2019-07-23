# -*- coding: utf-8 -*-
"""
Created on Mon Dec 17 11:32:47 2018

@author: zpb4
"""
import argparse
from datetime import datetime,date, timedelta
import os
import numpy as N
import glob
import moviepy.editor as mpy
from PIL import Image


wgetTemplate="wget -O %s %s"
oDir=""
urlTemplate="https://www.ncdc.noaa.gov/gibbs/image/%s/WV/%s"
satellite="GOE-11"

#for i in range(2011,2018,1):
startDate="2010-10-22" #str(i)+"-10-20"
endDate="2010-10-30" #str(i)+"-10-30"
urlStart=urlTemplate % (satellite,startDate)

dStart=datetime.strptime(startDate,'%Y-%m-%d')
dEnd=datetime.strptime(endDate,'%Y-%m-%d')
print(dEnd.date())

delta=dEnd.date()-dStart.date()

day = 0
for j in range(delta.days +1):
        dNow=dStart.date() + timedelta(j)
        for k in range(0,24,3):
            hour=str(k).zfill(2)
            dateStr=dNow.strftime('%Y-%m-%d')+"-"+hour
            file_name="image_"+str(dateStr)+".jpeg"
            url=urlTemplate % (satellite, dateStr)
            wgetCmmnd=wgetTemplate % (file_name,url)
            os.system("echo " + wgetCmmnd)
            os.system(wgetCmmnd)
        if os.stat("image_"+str(dateStr)+".jpeg").st_size == 0:
            os.remove("image_"+str(dateStr)+".jpeg")
        else:
            pass
        try: 
            images =Image.open('image_'+str(dateStr)+'.jpeg')
            new_image = images.crop((0, 0, 0, 0))
#            new_image.save('image_'+str(dateStr)+'.jpeg')
#            new_image = images.resize((x_pixels, y_pixels))
#            new_image.save('image_'+str(dateStr)+'.jpeg')
            new_image.save('image_'+str(dateStr)+'.jpeg')
        except(IOError):
            continue
mp4_name = str(startDate)+'_'+str(endDate)
fps=12
file_list1 = glob.glob('*.jpeg')
list.sort(file_list1, key=lambda x: int(x.split('_')[1].split('.jpeg')[0]))
clip = mpy.ImageSequenceClip(file_list1, fps=fps)
clip.write_videofile('{}.mp4'.format(mp4_name), fps=fps)
#    clip.write_GIF('{}.gif'.format(mp4_name), fps=fps)

dir_name =""
test = os.listdir(dir_name)
for item in test:
    if item.endswith(".jpeg"):
            os.remove(os.path.join(dir_name, item))  

print("All images have been downloaded, sorted, and removed and an mp4 has been created")
