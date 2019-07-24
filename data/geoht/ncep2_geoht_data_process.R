
#CL script
cd /Users/zachbrodeur/desktop/geoht
OUTPUT_DIRECTORY=$PWD

start=1984
end=2019
var=hgt

for ((i=start; i<=end; i++)) 
  do                 
wget -O $OUTPUT_DIRECTORY/$var.$i.nc "ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis2/pressure/$var.$i.nc"
ncks -d lat,20.,60. -d lon,200.,260. -v $var $var.$i.nc -O $var.out.$i.nc
rm -R $OUTPUT_DIRECTORY/$var.$i.nc
done

ncrcat -n 36,4,1 $var.out.1984.nc  $var.wc.19842019.nc
rm -R $OUTPUT_DIRECTORY/$var.out*.nc

cat > mygrid << EOF
gridtype = lonlat
xsize = 61
ysize = 41
xfirst = 200
xinc = 1.0
yfirst = 60
yinc = -1.0
EOF

cdo remapbil,mygrid $var.wc.19842019.nc $var.wc.rg.19842019.nc

lvl=500
ncks -d level,$lvl. hgt.wc.rg.19842019.nc -O hgt.wc.rg.$lvl.19842019.nc

gzip -k *.nc  #as desired to compress files but keep the originals
#native grids
#[1] 60.0 57.5 55.0 52.5 50.0 47.5 45.0 42.5 40.0 37.5 35.0 32.5 30.0 27.5 25.0 22.5 20.0

#[1] 200.0 202.5 205.0 207.5 210.0 212.5 215.0 217.5 220.0 222.5 225.0 227.5 230.0 232.5 235.0 237.5 240.0 242.5 245.0 247.5
#[21] 250.0 252.5 255.0 257.5 260.0

#regridded
#[1] 60 59 58 57 56 55 54 53 52 51 50 49 48 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21
#[41] 20

#[1] 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229
#[31] 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259
#[61] 260

############################################END############################################
