#Functions to convert relative humidity (%) to specific humidity (kg/kg) given temperature in either
#deg C or K.


#Referenc
#[1]file:///H:/Tutorials_Cheat%20Sheets_Guides/Humidity_Conversion_Formulas_B210973EN-F.pdf
#[2]https://en.wikipedia.org/wiki/Density_of_air


#[1]Calculate partial pressure of water vapor, Pws at given temp
#Pws = A * 10^(m*T / T + Tn) [T in C]
#for -20C < T < 50 C: A - 6.116441, m - 7.591386, Tn - 240.7263    -- error 0.083%
#for -70C < T < 0C: A - 6.114742, m - 9.778707, Tn - 273.1466   -- erro 0.052%

#[2]Calculate partial pressure of dry air, Pd
#Pd = P - Pws, where P is absolute (ambient) pressure

#[2]Calculate density of air mass, Pam
#pam = Pd / (Rd*T) + Pv / (Rv * T) where Rd = 287.058 J/(kg*K) and Rv = 461.495 J/(kg*K), [T in K]

#[1]Calculate Vapour pressure, Pw
#Pw = Pws * RH

#[1]Calculate absolute humidity, ah [kg / m3], C - 0.00216679 kgK/J, [T in K]
#ah = C* Pw / T

#[1]Calculate specific humidity
#q = ah / pam

#function 1 taking temp in deg C, pl in hPa, and rh in %

rh_to_sh_C<-function(Tc,pl,rh){
  #Tc - deg C
  #pl - hPa
  #rh - %
  K<-273.15 #C in K
  Tk<-Tc + K #convert to K
  if (Tk<253.15) A<-6.114742 ; m<-9.778707 ; Tn<-273.1466 #coeffs for Pws approx, -70 to -20C
  if (Tk>=253.15) A<-6.116441 ; m<-7.591386 ; Tn<-240.7263 #coeffs for Pws approx, -20 to 50C
  Rd<-287.058 #R for dry air
  Rw<-461.495 #R for water vapor
  C<-0.00216679 #coeff for ah approx
  
  Pws <- A*10^((m*Tc)/(Tc+Tn)) #[hPa]
  Pw <- Pws*(rh/100) #chg % to frac, #[hPa]
  Pd <- pl-Pw #[hPa]
  p_am <- (Pd*100) / (Rd*Tk) + (Pw*100) / (Rw*Tk) #[Pa]
  ah <- C * 100 * Pw / Tk #conversion from [hPa] to [Pa], [kg/m3]
  q <- ah / p_am #[kg/kg]
}


#function 2 taking temp in K, pl in hPa, and rh in %
rh_to_sh_K<-function(Tk,pl,rh){
  #Tc - deg C
  #pl - hPa
  #rh - %
  if (Tk<253.15) A<-6.114742 ; m<-9.778707 ; Tn<-273.1466 #coeffs for Pws approx, -70 to -20C
  if (Tk>=253.15) A<-6.116441 ; m<-7.591386 ; Tn<-240.7263 #coeffs for Pws approx, -20 to 50C
  Rd<-287.058 #R for dry air
  Rw<-461.495 #R for water vapor
  C<-0.00216679 #coeff for ah approx
  K<-273.15
  Tc<-Tk - K
  
  Pws <- A*10^((m*Tc)/(Tc+Tn)) #[hPa]
  Pw <- Pws*(rh/100) #[hPa]
  Pd <- pl-Pw #[hPa]
  p_am <- (Pd*100) / (Rd*Tk) + (Pw*100) / (Rw*Tk) #[Pa]
  ah <- C * 100 * Pw / Tk #conversion from [hPa] to [Pa], [kg/m3]
  q <- ah / p_am #[kg/kg]
}


#########################################################END################################################