%% Housekeeping 
clear; 
clc; 
close all;  

%%Important wind data 
wind_data = xlsread('Wind_data.xls'); 
speed = wind_data(:,1); %wind speed 
direction = wind_data(:,3); %wind direction 
power = wind_data(:,5); %power generated 
n = length(speed); % the number of speed 
tm = (1:1:n)./ n * 12; % time   

%%plotting wind speed m/s Month 
figure() 
plot(tm,speed) 
xlabel('Time (month)') 
ylabel('Wind Speed (m/s)') 
title('Wind Speed') 
legend('Time') 

%%plotting wind power kW Month 
figure() 
plot(tm,power) 
xlabel('Time (month)') 
ylabel('Wind Power (kW)') 
title('Wind Power') 
legend('Time')   

%%Histogram 
%frequency distribution of wind speed
M_speed = max(speed); %max speed 
bin_s = (0:1:M_speed);%bin vector 
v_bin = histc(speed, bin_s); %Grouping of speed data into bins 
figure() 
bar(v_bin)% generate bar chart 
xlabel('Wind Speed (m/s)') 
ylabel('Frequency (n)') 
title('Frequency Distribution of Wind Speed') 
legend('Wind Speed')
  
%frequency distribution of wind power
M_power = max(power); %max speed 
bin_p = (0:1:M_power);%bin vector 
p_bin = histc(power, bin_p); %Grouping of speed data into bins 
figure() 
bar(p_bin)% generate bar chart 
xlabel('Power (kW)') 
ylabel('Frequency (n)') 
title('Frequency Distribution of Wind Power') 
legend('Wind Power')   

%%wind Rose 
figure() 
pax = polaraxes; 
polarhistogram(deg2rad(direction(speed<25)),60 , 'displayname', '20-25 m/s') 
hold on 
polarhistogram(deg2rad(direction(speed<20)),60 , 'facecolor','red','displayname', '15-20 m/s') 
polarhistogram(deg2rad(direction(speed<15)),60 , 'facecolor','yellow','displayname', '10-15 m/s') 
polarhistogram(deg2rad(direction(speed<10)),60 , 'facecolor','green','displayname', '5-10 m/s') 
polarhistogram(deg2rad(direction(speed<5)),60 , 'facecolor','blue','displayname', '0-5 m/s')  

legend('Show') 
title('Wind Rose') 
  
pax.ThetaDir = "clockwise"; % sets direction for displaying angles clockwise 
pax.ThetaZeroLocation = "top"; % fixed angle 0 at the top pf the graph   

%Displaying wind direction 
text(deg2rad(0),max(pax.RTick),'N') 
text(deg2rad(45),max(pax.RTick),'NE') 
text(deg2rad(90),max(pax.RTick),'E') 
text(deg2rad(135),max(pax.RTick),'SE') 
text(deg2rad(180),max(pax.RTick),'S') 
text(deg2rad(225),max(pax.RTick),'SW') 
text(deg2rad(270),max(pax.RTick),'W') 
text(deg2rad(315),max(pax.RTick),'NW')    

%%standard deviation and mean velocity 
Stdwind = wind_data(:,2); %standard of the 10 minutes samples 
S = std(Stdwind);%stand deviation of dataset 
v_mean = mean(speed); % mean wind speed 
v_std = v_mean*S;   

%%shape and scale factor 
k = (0.9874/(v_std/v_mean))^1.0983; 
c = ((1/n)*sum(speed.^k))^(1/k); 

%%calculate and visualize the Weibull probability density function (PDF) for wind speeds 
weibull_dist = (k/c)*(speed/c).^(k-1).*exp(-(speed/c).^k); 
figure() 
plot(speed,weibull_dist, '.') 
xlabel('Wind Speed (m/s)') 
ylabel('Weibull Distribution') 
title('Weibull Distribution vs Speed') 
legend('Wind Speed') 
 

%%calculate and visualize the Weibull probability density function (PDF)
%%for wind speeds bins
weibull_dist = (k/c)*(bin_s/c).^(k-1).*exp(-(bin_s/c).^k); 
figure() 
plot(bin_s,weibull_dist, '-x') 
xlabel('Wind Speed Bins (m/s)') 
ylabel('Weibull Distribution') 
title('Wind Weibull Distribution of Speed Bins') 
legend('Wind Speed Bins') 
  

%% Vestas V52 Power Curve 
Vestas_V52 = xlsread('VestasV52.xlsx'); 
power_V52 = Vestas_V52(:,2); %power 
bin_s2 = Vestas_V52(:,1); %storing speed data 
figure() 
plot(bin_s2, power_V52,'g','LineWidth',2) 
title('Vestas V52 Power Curve') 
xlabel('Vestas V52 Speed Bins (m/s)') 
ylabel('Vestas V52 Wind Power(kW)') 
  

%%AEO Calculations 
Energy = power.*(1/6); % convert the power into energy every 10 minutes 
AEO_measured = sum(Energy); 
disp(['The actual measured annual energy output is: ', num2str(AEO_measured), 'kwh']); 
bin_s2 = sort(bin_s2); 
v_bin2 = histc(speed, bin_s2); %Grouping of speed data into bins from our wind turbine power curve 
Energy_P1 = power_V52.*v_bin2.*(1/6);  %total expected energy output at each speed of power curve 
AEO_Predicted =  sum(Energy_P1); 
disp(['The expect measured annual energy output is: ', num2str(AEO_Predicted), 'kwh']); 
  

%Energy bins 
M_Energy = max(Energy); %max Energy 
bin_s3 = (0:1:M_Energy);%bin vector 
v_Energy = histc(Energy, bin_s3); %Grouping of energy data into bins 
figure() 
bar(v_Energy)% generate bar chart 
xlabel('Wind Energy (kWh)') 
ylabel('Frequency (n)') 
title('Frequency Distribution of Wind Energy') 
legend('Wind Energy') 

  
%Capacity factor 
cp=[ AEO_measured/(365*24*850)]*100 
disp(['The Capacity factor is: ', num2str(cp), '%']); 

  