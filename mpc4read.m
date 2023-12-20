function r = mpc4read(casefile)
%MPC4READ Make matpower case(s) or MatACDC case(s) readable.
%   R = MPC4READ(CASEFILE) loads the case file specified by CASEFILE and
%   converts it into a readable format. Corresponding titles will be added
%   to the columns of main fields. The function supports both string
%   and char inputs for CASEFILE. The function throws an error for invalid
%   inputs.
%
%   The function converts numeric fields into cell arrays and adds column
%   headers for readability.
%
%   Inputs:
%       CASEFILE : string or char specifying the path to the case file, or
%                  a struct representing the case.
%
%   Outputs:
%       R : struct representing the case in a readable format.
%
%   Example:
%       readableCase = mpc4read('case9.m');
%
%   See also LOADCASE, LOADCASEDC, MPC4STD.

%   Author: yjy @ https://github.com/3plus10i
%   Created on: : 2019-02-25



fields = {'bus','gen','branch','busdc','convdc','branchdc','dcbus','vsc','dcline'};
col.bus = {'BUS_I' 	'BUS_TYPE' 	'PD' 	'QD' 	'GS' 	'BS' 	'BUS_AREA' 	'VM' 	'VA' 	'BASE_KV' 	'ZONE' 	'VMAX' 	'VMIN' 	'LAM_P' 	'LAM_Q' 	'MU_VMAX' 	'MU_VMIN' };
col.gen = {'GEN_BUS' 	'PG' 	'QG' 	'QMAX' 	'QMIN' 	'VG' 	'MBASE' 	'GEN_STATUS' 	'PMAX' 	'PMIN' 	'MU_PMAX' 	'MU_PMIN' 	'MU_QMAX' 	'MU_QMIN' 	'PC1' 	'PC2' 	'QC1MIN' 	'QC1MAX' 	'QC2MIN' 	'QC2MAX' 	'RAMP_AGC' 	'RAMP_10' 	'RAMP_30' 	'RAMP_Q' 	'APF' };
col.branch = {'F_BUS' 	'T_BUS' 	'BR_R' 	'BR_X' 	'BR_B' 	'RATE_A' 	'RATE_B' 	'RATE_C' 	'TAP' 	'SHIFT' 	'BR_STATUS' 	'ANGMIN' 	'ANGMAX' 	'PF' 	'QF' 	'PT' 	'QT' 	'MU_SF' 	'MU_ST' 	'MU_ANGMIN' 	'MU_ANGMAX' };
col.busdc = {'BUSDC_I' 	'BUSAC_I' 	'GRIDDC' 	'PDC' 	'VDC' 	'BASE_KVDC' 	'VDCMAX' 	'VDCMIN' 	'CDC' };
col.convdc = {'CONV_BUS' 	'CONVTYPE_DC' 	'CONVTYPE_AC' 	'PCONV' 	'QCONV' 	'VCONV' 	'RTF' 	'XTF' 	'BF' 	'RCONV' 	'XCONV' 	'BASEKVC' 	'VCMAX' 	'VCMIN' 	'ICMAX' 	'CONVSTATUS' 	'LOSSA' 	'LOSSB' 	'LOSSCR' 	'LOSSCI' 	'DROOP' 	'PDCSET' 	'VDCSET' 	'DVDCSET' 	'VMC' 	'VAC' 	'PCCONV' 	'QCCONV' 	'PCLOSS' 	'VMF' 	'VAF' 	'PFIL' 	'QCONVF' 	'QCCONVF' };
col.branchdc = {'F_BUSDC' 	'T_BUSDC' 	'BRDC_R' 	'BRDC_L' 	'BRDC_C' 	'RATEDC_A' 	'RATEDC_B' 	'RATEDC_C' 	'BRDC_STATUS' 	'PFDC' 	'PTDC' };

col.dcbus = {'DC_IDX'	'DC_TYPE'	'DC_U'	'DC_P'	'DC_PG'	'DC_PD'	'DC_ZONE'	'BASE_U'};
col.vsc = {'VSC_IDX'	'VSC_TYPE'	'VSC_U'	'VSC_P'	'PS'	'QS'	'VS'	'AS'	'PC'	'QC'	'VC'	'AC'	'RT'	'XT'	'RC'	'XC'	'BF'	'LOSS_A'	'LOSS_B'	'LOSS_C1(re)'	'LOSS_C2(in)'};
col.dcline = {'FB'	'TB'	'BG'	'DC_STATUS'	'DC_RATE' 'fflow' 'tflow'};

if isstring(casefile)||ischar(casefile)
    try
        r = loadcase(casefile);
    catch
        try
            r = loadcasedc(casefile);
        catch
        end
    end
elseif isstruct(casefile)
    r = casefile;
else
    error('Invaild input %dth. \n', ii);
end
for i=1:length(fields)
    f = fields{i};
    if isfield(r,f)
        if isnumeric(r.(f))
            r.(f) = num2cell(r.(f));
            r.(f)(2:(end+1),:) = r.(f);
            r.(f)(1,:) = col.(f)(1:size(r.(f),2));
        end
    end
end
end