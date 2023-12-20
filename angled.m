function argd = angled(z)
%ANGLED Compute the phase angle of complex number Z in degrees.
%   ARGD = ANGLED(Z) computes the phase angle of the complex number Z in
%   degrees. The function supports both scalar and array inputs for Z.
%
%   Inputs:
%       Z : complex number or array of complex numbers.
%
%   Outputs:
%       ARGD : phase angle of Z in degrees.
%
%   Example:
%       angleInDegrees = angled(1 + 1i);
%
%   See also ANGLE.


%   Author: yjy @ https://github.com/3plus10i
%   Created on: 2019-09-14

argd = angle(z)./pi.*180;