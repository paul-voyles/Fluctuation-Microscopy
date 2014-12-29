function [ annular_avg_cell, var_dp_cell ] = readFEM(binX, binY, strip_width, ...
    thickness_start, thickness_end, slope, offset, allow)
%READFEM Container used to call other functions for reading FEM data
% binX - x Dimensions of bin file
% binY - y Dimensions of bin file
% Outputs as cell matrices for each layer inspected

% Import two data files
guide_img = importBin(binX, binY); 
[img, FileName] = importSER();

% Used to determine center of SER file for annular average, and block beam stop
[x_c, y_c, x_rect_min, x_rect_max, y_rect_min, y_rect_max] = findCenter(img{1});

% Calculate annular_avg and var_dp
[annular_avg_cell, var_dp_cell] = Calc_STEM_Var_512(img, FileName, guide_img, ...
    x_c, y_c, strip_width, x_rect_min, x_rect_max, y_rect_min, y_rect_max, ...
    thickness_start, thickness_end, slope, offset, allow);

end

