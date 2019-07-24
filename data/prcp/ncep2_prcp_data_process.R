
#CL script
cd /Users/zachbrodeur/desktop/p1_data/prcp
OUTPUT_DIRECTORY=$PWD

start=1984
end=2019
for ((i=start; i<=end; i++)); do                 
  wget -O $OUTPUT_DIRECTORY/prate.$i.nc "ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis2/gaussian_grid/prate.sfc.gauss.$i.nc"
  ncks -d lat,30.,60. -d lon,220.,245. -v prate prate.$i.nc -O prate_o.$i.nc
  rm -R $OUTPUT_DIRECTORY/prate.$i.nc
done


ncrcat -n 36,4,1 prate_o.1984.nc  prate_wc.19842019.nc
rm -R $OUTPUT_DIRECTORY/prate_o*.nc

#native lons
[1] 219.375 221.250 223.125 225.000 226.875 228.750 230.625 232.500 234.375 236.250 238.125 240.000 241.875 243.750 245.625
#native lats
[1] 59.9986 58.0939 56.1893 54.2846 52.3799 50.4752 48.5705 46.6658 44.7611 42.8564 40.9517 39.0470 37.1422 35.2375 33.3328
[16] 31.4281 29.5234

#regrid to match GPCC
cat > mygrid << EOF
gridtype = lonlat
xsize = 25
ysize = 30
xfirst = -139.5
xinc = 1.0
yfirst = 30.5
yinc = 1.0
EOF

cdo remapbil,mygrid prate_wc.19842019.nc prate_wc_rg.19842019.nc

[1] -139.5 -138.5 -137.5 -136.5 -135.5 -134.5 -133.5 -132.5 -131.5 -130.5 -129.5 -128.5 -127.5 -126.5 -125.5 -124.5 -123.5
[18] -122.5 -121.5 -120.5 -119.5 -118.5 -117.5 -116.5 -115.5

[1] 30.5 31.5 32.5 33.5 34.5 35.5 36.5 37.5 38.5 39.5 40.5 41.5 42.5 43.5 44.5 45.5 46.5 47.5 48.5 49.5 50.5 51.5 52.5 53.5
[25] 54.5 55.5 56.5 57.5 58.5 59.5


############################################END############################################
