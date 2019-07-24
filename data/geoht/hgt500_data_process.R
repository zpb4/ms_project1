cd /Users/scottsteinschneider/Documents/USACE_WGEN/Data/hgt_NCEP_Reanalysis_2
OUTPUT_DIRECTORY=$PWD

start=1979
end=2017
for ((i=start; i<=end; i++)); do                 
  wget -O $OUTPUT_DIRECTORY/hgt.$i.nc "ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis2.dailyavgs/pressure/hgt.$i.nc"
  ncks -d lat,20.,70. -d level,500. -v hgt hgt.$i.nc -O hgt500NHem.$i.nc
  rm -R $OUTPUT_DIRECTORY/hgt.$i.nc
done

ncrcat -n 39,4,1 hgt500NHem.1979.nc  hgt.500N.Hem19792017.nc
rm -R $OUTPUT_DIRECTORY/hgt500NHem*.nc

