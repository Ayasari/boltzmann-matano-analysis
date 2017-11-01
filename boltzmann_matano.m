clc; clear; close all;

%%%%%%%read data from excel
filename = 'Lab1_diffusion';
sheet = 1;
xlRange = 'A2:B21';
cu_diff = xlsread(filename,sheet,xlRange);

%%%%%%%%important values
t = 312*60*60; %time in seconds
x = (cu_diff(:,1))'; %marker distance
y = (cu_diff(:,2)/100)'; %fraction Cu diffused
step = 1e-5; %%step size
interval = 0:step:0.0019;

%%%%%%%%create spline fit
spl = spline(x,[0 y 1]); %using clamped interpolation

%%%%%%%%%%%find matano interface by seeing where integration under left and right
%%sides of the curve are equal
matano = 0;
max = .0019;
for i=interval
    left = ppval(spl,(0:step:i+step));
    right = ppval(spl,(i+step:step:max));
    lefttrap = trapz(left);
    inverse = 1.-right;
    righttrap = trapz(inverse);
    tol = abs(lefttrap-righttrap);
    if tol<.3
        matano = i;
    end
end

%%%%%%%%%plot data with spline fit
figure
plot(x,y,'o',interval,ppval(spl,interval),'LineWidth',1.25)
xlabel('Marker Distance (m)')
ylabel('Cu Fraction')
title('Cu diffused for 312 hours at 1054 \circC') %\circ gives degree symbol

%%%%%%%%plot matano interface
ylims = get(gca, 'ylim');
hold on
plot([matano matano], ylims, 'LineWidth', 1.25)

%%%%%%find tangents to the curve (fluxes?)
dxdc = fnder(spl); %dc/dx
%since we know that y==.33 at x==4e-4
%and we know that y==.71 at x==6e-4
tan33 = 1/fnval(dxdc,4e-4);%dx/dc = tangent to spline fit at .33
tan71 = 1/fnval(dxdc,6e-4);

%%%%%%integration from matano to y==.33 and y==.71
%x bounds in order to find y bound
distance33 = interval(1:find(interval==4e-4));
distance71 = interval(61:end); %%find wasn't working, but the x value for y=.71 is at index 61

%y bounds
bounds33 = ppval(spl,distance33);
bounds71 = ppval(spl,distance71);

interval = interval-matano;
x0 = find(interval==0);

%integration using trapz
x33 = interval(1:x0);
integral33 = trapz([bounds33 repmat(.33,1,size(x33,2)-size(bounds33,2))] , x33); 
%repmat matrix concat makes trapz accurate over the full distance from the
%curve to the Motano interface
x71 = interval(x0:end);
integral71 = -trapz([repmat(.71,1,size(x71,2)-size(bounds71,2)) bounds71] , x71); %negative because integration is other direction

%%%%%%%%Find interdiffusion coefficients!!!!
D33 = (-1/(2*t))*(tan33)*(integral33)
D71 = (-1/(2*t))*(tan71)*(integral71)
