function content = readcsv(filename)
%READCSV Read CSV file to a cell array.
%   content = READCSV(filename) reads the CSV file specified by the
%   filename and returns its content in a cell array.
%   
%   If the file has more than 100,000 lines, this function throw an error.
%
%   Input:
%   - filename: Name of the CSV file to be read.
%
%   Output:
%   - content: Cell array containing the data from the CSV file.
%
%   Example:
%   content = readcsv('data.csv');
%   
%   See also: READCELL, FOPEN, FGETL, STRSPLIT.

%   Author: yjy @ https://github.com/3plus10i
%   Created on: 2022-08-10

content = cell(16,16);
fid = fopen(filename);
for row = 1:1e5
    line = fgetl(fid);
    if line == -1
        content = content(1:row-1,1:col);
        fclose(fid);
        return
    end
    sline = strsplit(line,',');
    col = length(sline);
    content(row,1:col) = sline;
end
fclose(fid);
error('Too many lines!')
end