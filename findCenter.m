function [x_c, y_c, x_rect_min, x_rect_max, y_rect_min, y_rect_max] = ...
    findCenter(img)
%FINDCENTER Used to determine both circle center and beam stop coordinates for 
% input SER images
% Last modified by Max Burton 05/01/14

% Create initial image figure and determine dimensional properties
figure;
imagesc(img);
colormap(gray);
imgsize = size(img);
xdim = imgsize(1);
ydim = imgsize(2);


% Determines location of circle for annular average
selection = char('n');
while selection ~= 'y'
    disp(strcat('Click the center of the circle first, then the outer radius'));
    
    imagesc(img);
    colormap(gray);
    
%   Get inputs and ensure values are integers
    [x,y] = ginput(2);
    x(1) = round(x(1));
    x(2) = round(x(2));
    y(1) = round(y(1));
    y(2) = round(y(2));
    
    
    radius = ((x(1)-x(2)).^(2) + (y(1)-y(2)).^(2)).^(1/2);
    drawCircle(x(1), y(1),radius);
    
    selection = strcat(input('Correct circle? (y/n) \n', 's'));
end
% Extract coordiantes for circle center
x_c = x(1);
y_c = y(1);


% Determines area for beam stop to remove values
selection = char('n');
while selection ~= 'y'
    disp(strcat('Select opposite corners of rectangle'));
    
    imagesc(img);
    colormap(gray);

%   Get inputs and ensure values are integers
    [x,y] = ginput(2);
    x(1) = round(x(1));
    x(2) = round(x(2));
    y(1) = round(y(1));
    y(2) = round(y(2));
    
    x_rect_min = min(x(1), x(2)); 
    x_rect_max = max(x(1), x(2));
    y_rect_min = min(y(1), y(2));
    y_rect_max = max(y(1), y(2));
    
    
%   Place rectangle at outmost bounds if near edge
    [x_rect_min, x_rect_max, y_rect_min, y_rect_max] = ...
        redimensionRectangle(x_rect_min, x_rect_max, y_rect_min, y_rect_max, xdim, ydim);
    
    rectangle('Position',[x(1) y(1) (x_rect_max - x_rect_min)...
        (y_rect_max - y_rect_min)], 'LineWidth',1, 'EdgeColor','b');

    
    selection = strcat(input('Correct rectangle? (y/n) \n', 's'));
end





end


function drawCircle(xCoord,yCoord,r)
% Draws circle on image figure
hold on

th = 0:pi/50:2*pi;

xunit = r * cos(th) + xCoord;
yunit = r * sin(th) + yCoord;

circle = plot(xunit, yunit);

hold off

end


function [x_rect_min, x_rect_max, y_rect_min, y_rect_max] = ...
   redimensionRectangle(x_rect_min, x_rect_max, y_rect_min, y_rect_max, xdim, ydim)
% Ugly implementation to ensure points close to edge get placed on edge
if x_rect_max > .98 * xdim
    x_rect_max = xdim;
end

if x_rect_min < 0.2 * xdim
    x_rect_min = 1;
end
    
if y_rect_max > .98 * ydim
    x_rect_max = xdim;
end

if y_rect_min < 0.1 * ydim
    x_rect_min = 1;
end
end