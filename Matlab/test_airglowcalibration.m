% Testing the star calibration for the all-sky airglow imager
% 1) Read the image and to define the locations of stars in the image
% 2) Run the calibration parameter optimisation routine
% 3) Plot results

clear

filename=fullfile('..','Test_images/','W8446B18_2020-12-11_20-09-36.img');
img=readairglow(filename);

imagesc(sqrt(img))
axis image
colormap('gray')
title('KHO airglow imager 2020/12/11 20:09:36UT')

minvalue=min(img,[],'all');
maxvalue=max(img,[],'all');

% A quick test whether the image was read in correctly
if minvalue~=51
    error('Minimum pixel intensity value not 51 as expected!')
end

if maxvalue~=64941
    error('Minimum pixel intensity value not 64941 as expected!')
end

%--------------------------------------------------
% Label a couple of identified stars/planets
% - we used Stellarium to compute a sky chart
%   for Longyearbyen at the date & time of the image
% - stars in the image have been identified
% - the azimuth and altitude (above horizon) have been manually
%   collected from Stellarium by clicking on the the identified stars
% - the pixel locations (row, column) for each star have been manually
%   determined by zooming in onto the images

starNames={'Vega','Capella','Dubhe','Deneb','Mirfak','Agol', ...
    'Almach','Mirach','Eltanin', 'Merak','Phecda','Alioth', ...
    'Alkaid','Polaris','Aldebaran','Betelgeuse','Pollux', ...
    'Caph','Shedar','Kochab'};

% Stellarium shows the azimuth in degrees, minutes and seconds
% so the azimuths and altitudes need to be converted to decimal
% degrees

starAz=[306+43/60+8.5/3600, ... 
    129+20/60+54.9/3600, ... % minutes and seconds
    39+23/60+25.7/3600, ...
    280+16/60+42.6/3600, ...
    163+13/60+38.7/3600, ...
    169+36/60+17.2/3600, ...
    189+45/60+35/3600, ...
    205+24/60+45.2/3600, ...
    318+57/60+39.9/3600, ...
    41+58/60+14.7/3600, ...
    32+18/60+41.9/3600, ...
    19+49/60+42.3/3600, ...
    9+50/60+38.9/3600, ...
    0+20/60+22/3600, ...
    147+19/60+14.9/3600, ...
    128+9/60+34.5/3600, ...
    95+56/60+43.6/3600, ...
    233+15/60+11.8/3600, ...
    221+5/60+33/3600, ...
    357+52/60+10.2/3600];

starAlt=[32+21/60+29.8/3600, ...
    54+19/60+5.4/3600, ...
    53+24/60+36.1/3600, ...
    44+27/60+50.8/3600 ...
    61+21/60+7.1/3600, ...
    52+40/60+17/3600, ...
    54+5/60+7.8/3600, ...
    46+34/60+19.5/3600, ...
    43+13/60+43.7/3600, ...
    48+17/60+24.3/3600, ...
    44+4/60+7.8/3600, ...
    44+58/60+6/3600, ...
    37+39/60+41.3/3600, ...
    78+52/60+7.6/3600, ...
    26+38/60+25.9/3600, ...
    14+54/60+31.6/3600, ...
    29+53/60+17.5/3600, ...
    59+16/60+47.1/3600, ...
    66+23/60+40.8/3600, ...
    62+18/60+47.9/3600];

starCol=[340, 206, 138, 380, 274, 299, 332, 376, 294, ...
    120, 119, 142, 148, 237, 237,159,89,334,334,214]; % X

starRow=[72, 361, 195, 150, 346, 377, 346, 337, 90, 195, ...
    166, 140, 105, 211, 454, 460,356,259,277,158]; % Y


%----------------------------
% Do the star calibration

[zenithRow, zenithCol, k, rotAngle]= ...
    starcalibration(size(img),starAlt,starAz, starRow, starCol);

fprintf('-------------------------------------------------------\n')
fprintf('        Zenith = (%.1f,%.1f)\n',zenithRow,zenithCol);
fprintf('             k = %.1f [pixel/deg]\n',k);
fprintf('Rotation angle = %.1f (%.1f deg)\n', rotAngle, rotAngle*180/pi); 


%------------------------------------------------------------------
% Do a quick plot of the final results.

hold on
plot(zenithCol,zenithRow,'go')
plot(starCol, starRow, 'ro','markersize',10)
text(starCol+15, starRow, starNames,'color','r')

% Compute where the stars are in the image based on the calibration
% parameters to visualise the calibration results

theta=starAz*pi/180;
d=k*(90-starAlt);
newStarRow=zenithRow-d.*cos(theta+rotAngle);
newStarCol=zenithRow-d.*sin(theta+rotAngle);

plot(zenithCol,zenithRow,'go')
for i=1:length(starAz)
    plot([zenithCol newStarCol(i)],[zenithRow newStarRow(i)],'g')
end

% Plot a thick long line towards north and east

d=k*45; % 45 degrees from the horizon

northRow=zenithRow-d*cos(rotAngle);
northCol=zenithCol-d*sin(rotAngle);
plot([zenithCol northCol],[zenithRow northRow],'b','linewidth',3)
text(northCol,northRow-15,'NORTH','color','b')

eastRow=zenithRow-d*cos(pi/2+rotAngle);
eastCol=zenithCol-d*sin(pi/2+rotAngle);
plot([zenithCol eastCol],[zenithRow eastRow],'b','linewidth',3)
text(eastCol,eastRow+15,'EAST','color','b')

hold off