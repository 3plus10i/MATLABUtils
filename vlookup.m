function value = vlookup(key, celltable, indexv, indexk)
%VLOOKUP Performs a lookup similar to Excel's VLOOKUP function.
%   value = VLOOKUP(key, celltable, indexv, indexk) searches for a key in
%   the specified celltable and returns the corresponding value from the
%   specified indexv column. If the key is not found, an empty array is
%   returned.
%
%   If the indexk argument is not provided, it defaults to 2.
%
%   Input arguments:
%   - key: The value to search for in the celltable. It could be a number
%   or a char array.
%   - celltable: A cell array representing the table to search in.
%   - indexv: The index of the column from which to return values.
%   - indexk: (Optional) The index of the column to search for the key. 
%             Defaults to 1 if not provided.
%
%   Output:
%   - value: The value corresponding to the key in the specified column.
%            Returns an empty array if the key is not found.
%
%   Example:
%   value = vlookup('LookupKey', celltable, 2, 1);
%
%   See also: EQ, STRCMP.

%   Author: yjy @ https://github.com/3plus10i
%   Created on: 2023-02-01


if nargin < 4
    indexk = 2;
end
value = [];
eq_ = @eq;
if ischar(key)
    eq_ = @strcmp;
end
for ii = 1:size(celltable,1)
    if eq_(celltable{ii,indexk},key)
        value = celltable{ii,indexv};
        return
    end
end
end