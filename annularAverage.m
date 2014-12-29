function [annular_avg, npix, radius] = annularAverage(img, xx, yy, strip_width)
%annularAverage Finds annular average of provided image
% img - Matrix containing all image file layers
% xx - x coordinate of circle centre
% yy - y coordinate of circle centre
% strip_width - pixel number of strip to inspect
% annular_avg - annular average output
% npix - number of pixels in annular average
% radius - radius of annular average
% Last modified by Max Burton 05/01/14


% Determine dimensions of input matrices
rows = size(img,1);
cols = size(img, 2); 

% Determine radius
radius = max (max (xx, abs(xx-rows)), max(yy, abs(yy-cols)));
radius = floor (radius / strip_width);

% Make the output and pixel-counting wave
annular_avg = zeros(radius,1);
npix = zeros(radius,1); 


% Perform the annular average
for i = 1:rows
    for j = 1:cols
        
        if ( isfinite(img(i, j)))
            
            rpix = round ( sqrt( ((i-1)-xx).^2 + ((j-1)-yy).^2) / strip_width); % round() in igor
            if (rpix < radius)
                            
                
                if (rpix < radius)
                    rpix = rpix + 1; % fix off by one error when adding to matrices
                    annular_avg(rpix) = img(i, j) + annular_avg(rpix);
                    npix(rpix) = npix(rpix) + 1;
                end
               
               
            end
        end
    end
end

% Divide annular average integral by npix
for i = 1:size(annular_avg)
    annular_avg(i) = annular_avg(i) / npix(i);
end


end
