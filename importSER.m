function [img, FileName] = importSER()
% Function to import SER file
% Last modified by Max Burton 05/01/14

% Import file from file path
[FileName,PathName] = uigetfile('*.ser');
[fileID, fileMessage] = fopen([PathName FileName], 'rb');

% If cannot find file, display error message
if fileID == -1
    disp(FileName)
    error(['Could not open file: ' fileMessage])
end

% Position read at beginning of file
fseek(fileID, 0, 'eof');
fseek(fileID, 0, -1);

% Read file header
byteOrder = fread(fileID, 1, 'int16');
SeriesID = fread(fileID, 1, 'int16');
SeriesVersion = fread(fileID, 1, 'int16');
DataTypeID = fread(fileID, 1, 'int32');
TagTypeID = fread(fileID, 1, 'int32');
TotalNumberElements = fread(fileID, 1, 'int32');
ValidNumberElements = fread(fileID, 1, 'int32');
OffsetArrayOffset = fread(fileID, 1, 'int32');
NumberDimensions = fread(fileID, 1, 'int32');


% Assuming two dimensional data; output information for each axis
for i = 1:2
    DimensionSize = fread(fileID, 1, 'int32');
    CalibrationOffset = fread(fileID, 1, 'float64');
    CalibrationDelta = fread(fileID, 1, 'float64');
    CalibrationElement = fread(fileID, 1, 'int32');
    DescriptionLength = fread(fileID, 1, 'int32');
    Description = fread(fileID, DescriptionLength, '*char');
    UnitsLength = fread(fileID, 1, 'int32');
    Units = fread(fileID, UnitsLength, '*char');
end

% Position read at end of array offset
fseek(fileID, OffsetArrayOffset, -1);
DataOffsetArray = fread(fileID, TotalNumberElements, 'int32');
tagOffsetArray = fread(fileID, TotalNumberElements, 'int32');

% Check data type and retrieve data information. Place in data matrix
if DataTypeID == hex2dec('4122')
    for i=1:ValidNumberElements
        
        % Separate out elements
        fseek(fileID,DataOffsetArray(i),-1);
        calibrationOffsetX = fread(fileID,1,'float64');
        calibrationDeltaX = fread(fileID,1,'float64');
        calibrationElementX = fread(fileID,1,'int32');
        calibrationOffsetY = fread(fileID,1,'float64');
        calibrationDeltaY = fread(fileID,1,'float64');
        calibrationElementY = fread(fileID,1,'int32');
        
        % Determine Data type
        dataType = fread(fileID,1,'int16');
        Type = getType(dataType);
        
        % Find array size and use to extract image data
        arraySizeX = fread(fileID,1,'int32');
        arraySizeY = fread(fileID,1,'int32');
        img{i} = fread(fileID,[arraySizeX arraySizeY],Type);
        serCalibration(:,i) = [calibrationDeltaX calibrationDeltaY]';
        
    end
end


end


% Determine file type
function Type = getType(dataType)
	switch dataType
		case 1
			Type = 'uint8';
		case 2
			Type = 'uint16';
		case 3
			Type = 'uint32';
		case 4
			Type = 'int8';
		case 5
			Type = 'int16';
		case 6
			Type = 'int32';
		case 7
			Type = 'float32';
		case 8
			Type = 'float64';
		otherwise
			error('Invalid data file')
	end

end