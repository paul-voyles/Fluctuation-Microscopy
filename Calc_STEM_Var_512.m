function [annular_avg_matrix, var_dp_matrix ] = Calc_STEM_Var_512(img, name_var, guide_img, ...
    x_c, y_c, strip_width, x_rect_min, x_rect_max, y_rect_min, y_rect_max, ...
    thickness_start, thickness_end, slope, offset, allow)
%Calc_STEM_Var_512 Calculates STEM variables
% dat = 3D stack of nanodiffraction patterns
% name_var  = output basename string
% guide_img = HAADF simultaneous acquired image
% x_c , y_c = center of diffraction pattern in pixels
% strip_width = width of the bins in the annular average, typically 2
% x_rect_min, x_rect_max, y_rect_min, y_rect_max = box for the beam stop
% thickness_start = minimum thickness in the guide image in nm
% thickness_end = maximum thickness in the guide image in nm
% slope = proptionality between HAADF counts and thickness
% offset = black level in HAADF image
% allow = thickness range in nm to be allowed into variance calculation
% Last modified by Max Burton 05/01/14

% Create container for all annular average data and var_dp information
% annular_avg_matrix = cell(1,size(img, 2));
% var_dp_matrix = cell(1,size(img, 2));

iterations = ceil((thickness_end-thickness_start)/(2*allow));

annular_avg_matrix = cell(iterations, 1);
var_dp_matrix = cell(iterations,1);


% G_Gain provided value
G_Gain = 4.72;

% Determine number of discrete images in data set and set current position to zero
num_images = size(img, 2);

% Determine image dimensions
x_dim = size(img{1}, 1);
y_dim = size(img{1}, 2);


% Fix off by one errors that occur when utilizing values from igor
x_rect_min = x_rect_min + 1;
x_rect_max = x_rect_max + 1;
y_rect_min = y_rect_min + 1;
y_rect_max = y_rect_max + 1;


% Determine pixel quantity of guide image
num_dps = size(guide_img, 1) * size(guide_img, 2);
guide_pix_int = zeros(num_dps,1);

% Create 1D array containing guide image data for all pixels
% NOTE REVISIT FOR NON 10X10 MATRICIES
k = 1;
for i = 1:size(guide_img, 1)
    for j=1:size(guide_img, 2)
        guide_pix_int(k) = guide_img(j, i);
        k = k + 1;
    end
end


% 
currentLayer = 1;
for ii = thickness_start:2*allow:thickness_end
    
    % Determine data information
    thickness = ii;
    int_min = (thickness - allow) * slope + offset;
    int_max = (thickness + allow) * slope + offset;
    
    
    % Look at first layer
    i = 1;
    % Remove data values for those covered by beam stop
    temp_image = img{i};
    for j = x_rect_min:x_rect_max
        for g = y_rect_min:y_rect_max
            temp_image(j, g) = NaN;
        end
    end

    % Perform initial annularAverage to determine dimensions of matrices
    [annularAvg, npix, radius] = annularAverage(temp_image, x_c, y_c, strip_width);
    
    % Create storage matrices to hold annularAverage and annularIntegral data
    AvgXDim = size(annularAvg, 1);
    AvgYDim = size(annularAvg, 2);
    i_square = zeros(AvgXDim, AvgYDim);
    i_ave = zeros(AvgXDim, AvgYDim);
    var_dp = zeros(AvgXDim, AvgYDim);
    i_total = zeros(AvgXDim, AvgYDim);
    
    img_count = 0;
    % Perform annular averge for all images based on 
    for i = 1:num_images
        
        if (guide_pix_int(i) >= int_min)
            if guide_pix_int(i) < int_max
                
                temp_image = img{i};
                
                for j = x_rect_min:x_rect_max
                    for g = y_rect_min:y_rect_max
                        temp_image(j, g) = NaN;
                    end
                end
                
                % Calculate the annular average exluding beam stopper area
                % and stores the annular average data in annularAvg
                [annularAvg, npix, radius] = annularAverage(temp_image, x_c, y_c, strip_width);
                [annularInt, radius] = annularIntegral(temp_image, x_c, y_c, strip_width);
                
                i_square = i_square + annularAvg.^2;
                i_ave = i_ave + annularAvg;
                i_total = addTotal(i_total, annularInt);
                
                img_count = img_count + 1;
                
            end
        end
    end
    
    % Display information regarding data
    dispText(thickness, int_min, int_max, img_count)
    
    % Calculate shot noise
    i_square = i_square / img_count;
    i_ave = i_ave / img_count;
    i_total = i_total / img_count;
    var_dp = i_square./ i_ave.^2 - 1 - G_Gain ./ i_ave ./ npix;
    
    
%     name_var = strcat(name_var0, '_', int2str(thickness), 'nm_', int2str(img_count),'ea');
%     disp(name_var);
    
    % Add annular average and var_dp matrix to set of all layer results
    annular_avg_matrix{currentLayer} = annularAvg;
    var_dp_matrix{currentLayer} = var_dp;
    currentLayer = currentLayer + 1; 
    
end

% Need to pass out var_dp and annular_av for each layer (make graph of?)
% Store data in name_var matrix and export[?]


end

function dispText(thickness, int_min, int_max, img_count)
% Used as bulk function to display debug information
disp(strcat('Thickness = ', int2str(thickness)));
disp(strcat('int_min = ', int2str(int_min)));
disp(strcat('int_max = ', int2str(int_max)));
disp(strcat('number of dps chosen = ', int2str(img_count)));

end



function [i_total] = addTotal(i_total, annularInt)
% Method used to add mismatched arrays in method consistent with igor's system

% Ensure annularInt can be copied into i_total
if size(annularInt) <= size(i_total)
    % Copy full matrix from
    for i = 1:size(annularInt)
        i_total(i) = annularInt(i);
    end
    
    % If annularInt is smaller than i_total, fill remainder of i_total with final value
    % in annularInt
    if size(annularInt) < size(i_total)
        for i = size(annularInt)+1:size(i_total)
            i_total(i) = annularInt(size(annularInt));
        end
    end
else
%   If annularIt is too large, display error
    disp('Error: Matrix Mismatch')
end

end

