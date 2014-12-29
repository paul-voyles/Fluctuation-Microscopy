function [binOut] = importBin(dimX, dimY)
%ZBIN imports Bin file from TIA
% file - path to file
% dimX - X matrix dimensions of bin file
% dimY - Y matrix dimensions of bin file 
% Last modified by Max Burton 05/01/14

% Import file from file path
[FileName,PathName] = uigetfile('*.bin');
[fileID, fileMessage] = fopen([PathName FileName], 'rb');

% If cannot find file, display error message
if fileID == -1
    disp(FileName)
    error(['Could not open file: ' fileMessage])
end

% Define beginning of file
fseek(fileID,0,'eof');
fseek(fileID,0,-1);


% Shift ten bytes to skip header
emptyCell = fread(fileID,1,'int32');
emptyCell = fread(fileID,1,'int32');
emptyCell = fread(fileID,1,'int16');


% Read data
binOut = fread(fileID,[dimX dimY],'float32');

end