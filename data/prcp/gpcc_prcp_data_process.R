##Process GPCC data
cd /volumes/toshiba ext/project1/data/prcp/raw

#rename all files with '.' instead of '_'
rename -n 's/_/./g' *.nc

#concat first guess files
start=2009
end=2018

for ((i=start; i<=end; i++)) 
  do        
y=$i'01'
ncrcat -n 12,6,1 first.guess.daily.$y.nc  gpcc_fg.$i.nc
done
#add in 2019 (3 files) manually
ncrcat -n 3,6,1 first.guess.daily.201901.nc gpcc_fg.2019.nc
#combine subsets of data
ncrcat -n 11,4,1 gpcc_fg.2009.nc gpcc_fg.20092019.nc
ncrcat -n 35,4,1 full.data.daily.v2018.1982.nc  gpcc_fdv2018_19822016.nc
ncrcat -n 3,4,1 gpcc_fg.2017.nc gpcc_fg.20172019.nc
#pull out lat/lon and variable (precip) of interest, rename first guess to match full data
ncks -d lat,30.,60. -d lon,-140.,-115. -v precip gpcc_fdv2018_19822016.nc -O gpcc_fd_wc_prcp_19822016.nc
ncks -d lat,30.,60. -d lon,-140.,-115. -v p gpcc_fg.20172019.nc -O gpcc_fg_wc_prcp.20172019.nc
ncrename -h -O -v p,precip gpcc_fg_wc_prcp.20172019.nc
#concat full final file
ncrcat gpcc_fd_wc_prcp_19822016.nc gpcc_fg_wc_prcp.20172019.nc gpcc_wc_prcp.1982_2019.nc
