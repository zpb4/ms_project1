
#CL script
cd /Users/zachbrodeur/desktop/p1_data/prcp
OUTPUT_DIRECTORY=$PWD

start=1984
end=2019
for ((i=start; i<=end; i++)); do                 
  wget -O $OUTPUT_DIRECTORY/prate.$i.nc "ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis2/gaussian_grid/prate.sfc.gauss.$i.nc"
  ncks -d lat,29.,60. -d lon,219.,246. -v prate prate.$i.nc -O prate_o.$i.nc
  rm -R $OUTPUT_DIRECTORY/prate.$i.nc
done


ncrcat -n 36,4,1 prate_o.1984.nc  prate_wc.19842019.nc
rm -R $OUTPUT_DIRECTORY/prate_o*.nc

cat > mygrid << EOF
gridtype = lonlat
xsize = 25
ysize = 30
xfirst = 139.5
xinc = 1.0
yfirst = 30.5
yinc = 1.0
EOF

cdo remapbil,mygrid prate_wc.19842019.nc prate_wc_rg.19842019.nc



############################################END############################################
