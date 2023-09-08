# LEMI_Utils
Utility to read the Ukraine LVIV LEMI-417 instrument time series binary files in Matlab

A bunch of simple scripts to read the Ukraine LEMI-417 binary file... Note this supports the loading of multiple files at once. 
BUT, there is no guarantee that the stitching of multiple files is correct, samples could be missing in between the files (say, the previous file ends at 11:59, but the next file starts at 12:01) 

## The instrument

A Ukraine Long-period magnetotellurics system, which was quite popular in China. Please see their website for details:
[https://www.isr.lviv.ua/lemi417.htm]

## DATA FORMAT

Note that, unfortunately, LEMI-417 only conserves two digits float in their binary files (i.e. the resolution is 0.01 mV/km for E and 0.01 nT for B). This may lead to some precision loss from the equipment level. Not sure if their newer equipment will do better on that part. 

for a detailed description of the file format, see: Zhang et al., 2020 for further information (in Chinese)

ZHANG Wei, HU Lei, ZHANG Zhao-Bo. Raw data format analysis of LEMI-417 earth deep electromagnetic field observation system. Geophysical and Geochemical Exploration, 2020, (4): 810-815. [doi:10.11720/wtyht.2020.1485]

see also my toy 1D occam code for MT inversion

[https://github.com/dong-hao/occam1dmt]


## Something like a disclaimer

This was one of many toy codes I fiddled with when I was a student - I hope this could be useful to our students nowadays in the EM community. 
Those who want to try this script are free to use it on academic/educational cases. But of course, I cannot guarantee the script to be working properly and calculating correctly (although I wish so). Have you any questions or suggestions, please feel free to contact me (but don't you expect that I will reply quickly!).  

## HOW TO GET IT
```
git clone https://github.com/dong-hao/LEMI_Utils/ your_local_folder
```

## UNITS
Note that the internal unit for electrical field is mV/km, while the unit for the magnetic field is nT.  

## HOW TO GET UPDATED
```
cd to_you_local_folder
git pull 
```

## Contact

DONG Hao –  donghao@cugb.edu.cn

China University of Geosciences, Beijing 

Distributed under the GPL v3 license. See ``LICENSE`` for more information.

[https://github.com/dong-hao/LEMI_Utils]

## Contributing

Those who are willing to contribute are welcomed to try - but I probably won't have the time to review the commits frequently (not that I would expect there will be any). 

1. Fork it (<https://github.com/dong-hao/LEMI_Utils/fork>)
2. Create your feature branch (`git checkout -b feature/somename`)
3. Commit your changes (`git commit -am 'Add some features'`)
4. Push to the branch (`git push origin feature/somename`)
5. Create a new Pull Request - lather, rinse, repeat 
