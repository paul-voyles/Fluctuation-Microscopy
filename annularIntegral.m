function [annular_int, radius] = annularIntegral(img, xx, yy, strip_width)
%annularIntegral Finds annular integral of provided image
% img - Matrix containing all image file layers
% xx - x coordinate of circle centre
% yy - y coordinate of circle centre
% strip_width - pixel number of strip to inspect
% annular_avg - annular average output
% radius - radius of annular average
% Set values for x and y values of centre coordinates
% Last modified by Max Burton 05/01/14

% Determine dimensions of input matrices
rows = size(img,1);
cols = size(img, 2); 

% Determine radius
radius = min (min (xx, abs(xx-rows)), min(yy, abs(yy-cols)));
radius = floor (radius / strip_width);

% output and pixel counting matrix
annular_int = zeros(radius,1);

% Perform the annular integral
for i = 1:rows
    for j = 1:cols
        
        if ( isfinite(img(i, j)))
            
            rpix = round ( sqrt( ((i-1)-xx).^2 + ((j-1)-yy).^2) / strip_width); % round() in igor
            if (rpix < radius)
                            
                
                if (rpix < radius)
                    rpix = rpix + 1; % fix off by one error when adding to matrix
                    annular_int(rpix) = img(i, j) + annular_int(rpix);
                end
               
               
            end
        end
    end
end

end