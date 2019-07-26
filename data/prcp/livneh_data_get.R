
start=1950
end=2013

for ((i=start; i<=end; i++)) 
  do        
  y=$i'01'
  ncrcat -n 12,6,1 livneh_NAmerExt_15Oct2014.$y.nc  livneh.$i.nc
  done

ncrcat -n 64,4,1 livneh.1950.nc livneh.1950_2013.nc

ncrcat -n 30,4,1 livneh.1984.nc livneh.1984_2013.nc

ncks -d lat,30.,53. -d lon,-125.,-115. -v Prec livneh.1984_2013.nc -O livneh_wc_tp.1984_2013.nc

cat > mygrid << EOF
gridtype = lonlat
xsize = 10
ysize = 23
xfirst = -124.5
xinc = 1.0
yfirst = 30.5
yinc = 1.0
EOF

cdo remapbil,mygrid livneh_wc_tp.1984_2013.nc livneh_wc_tp_rg.1984_2013.nc
