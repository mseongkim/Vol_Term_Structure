%Estimate parameters of multi factor stochastic model from observed market data
%Codes are only for generating fitted model volatilties without adding seasonality 

close all; clear all;
tic

filename = 'marketdata.xlsx';
subset = importdata(filename);

Date = subset.textdata(3:end,1); 
Today = datetime('today');
formatOut = 'mm/dd/yy';
Today_Str = datestr(Today,formatOut);
Date_Str = datestr(Date,formatOut);
Time = (datenum(Date_Str) - datenum(Today_Str) - 1)./365;
 
formatOut = 'mm/dd';
Date_Str_Short = datestr(Date,formatOut);
Date_Number = str2num(Date_Str_Short);
market_index = 1:1:1 % choose a market   
Vol(:,:) = subset.data(:,market_index(1):market_index(end)); 
wid = size(Time,1);
len = size(market_index,2);
 
x_all = zeros(len,3);
residual = zeros(len,1); 
model_vol = zeros(wid,len);
for index = 1:len
    all_data = Vol(:,index); 
    T0_all = Time;
    %nonlinear least-square with three parameters estimation_all data
    objective = @(x)sqrt((((x(1)^2)/(2*x(3)).*(1-exp(-2*x(3).*T0_all))) + x(2)^2.*T0_all)./T0_all) - all_data;
    x0 = [0.3,0.1,3];
    x_all(index,:) = lsqnonlin(objective,x0,0,100);
    [~,resnorm] = lsqnonlin(objective,x0,0,100);
    residual(index,:) = resnorm;
    model_vol(:,index) = sqrt((((x_all(index,1)^2)/(2*x_all(index,3)).*(1-exp(-2*x_all(index,3).*T0_all)))...
                              + x_all(index,2)^2*T0_all)./T0_all);                     
end
 
plot(T0_all,all_data,'b')
hold on;
plot(T0_all,model_vol,'k*')
xlabel('Time to Maturity(Month)')
ylabel('Annualized Vol(%)')
legend('Market Vol','Model Vol')
title('Implied Volatility Term Structure(1)')

toc

