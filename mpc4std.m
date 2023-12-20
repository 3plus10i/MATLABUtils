function s = mpc4std(r)
%MPC4STD Transform readable MATPOWER case(s) or MatACDC case(s) to standard format.
%   S = MPC4STD(R) takes a struct S representing a readable matpower case
%   or MatACDC case and transforms it into a standard format. The function
%   supports only struct inputs for R. The function throws an error for 
%   invalid inputs.
%
%   Though the function is not depended no tools from MATPOWER or MatACDC,
%   this function is an assistant tool when user is using those toolboxes.
%   Thanks for the contributors of MATPOWER and MatACDC.
%
%   The function supports the following fields: 'bus', 'gen', 'branch',
%   'busdc', 'convdc', 'branchdc'.
%
%   Inputs:
%       R : struct representing the readable case.
%
%   Outputs:
%       S : struct representing the case in standard format.
%
%   Example:
%       standardCase = mpc4std(readableCase);
%
%   See also MPC4READ.

%   Author: yjy @ https://github.com/3plus10i
%   Created on: 2019-02-25

fields = {'bus','gen','branch','busdc','convdc','branchdc'};
% col.bus = {'BUS_I' 	'BUS_TYPE' 	'PD' 	'QD' 	'GS' 	'BS' 	'BUS_AREA' 	'VM' 	'VA' 	'BASE_KV' 	'ZONE' 	'VMAX' 	'VMIN' 	'LAM_P' 	'LAM_Q' 	'MU_VMAX' 	'MU_VMIN' };
% col.gen = {'GEN_BUS' 	'PG' 	'QG' 	'QMAX' 	'QMIN' 	'VG' 	'MBASE' 	'GEN_STATUS' 	'PMAX' 	'PMIN' 	'MU_PMAX' 	'MU_PMIN' 	'MU_QMAX' 	'MU_QMIN' 	'PC1' 	'PC2' 	'QC1MIN' 	'QC1MAX' 	'QC2MIN' 	'QC2MAX' 	'RAMP_AGC' 	'RAMP_10' 	'RAMP_30' 	'RAMP_Q' 	'APF' };
% col.branch = {'F_BUS' 	'T_BUS' 	'BR_R' 	'BR_X' 	'BR_B' 	'RATE_A' 	'RATE_B' 	'RATE_C' 	'TAP' 	'SHIFT' 	'BR_STATUS' 'ANGMIN' 	'ANGMAX' 	'PF' 	'QF' 	'PT' 	'QT' 	'MU_SF' 	'MU_ST' 		'MU_ANGMIN' 	'MU_ANGMAX' };
% col.busdc = {'BUSDC_I' 	'BUSAC_I' 	'GRIDDC' 	'PDC' 	'VDC' 	'BASE_KVDC' 	'VDCMAX' 	'VDCMIN' 	'CDC' };
% col.convdc = {'CONV_BUS' 	'CONVTYPE_DC' 	'CONVTYPE_AC' 	'PCONV' 	'QCONV' 	'VCONV' 	'RTF' 	'XTF' 	'BF' 	'RCONV' 	'XCONV' 	'BASEKVC' 	'VCMAX' 	'VCMIN' 	'ICMAX' 	'CONVSTATUS' 	'LOSSA' 	'LOSSB' 	'LOSSCR' 	'LOSSCI' 	'DROOP' 	'PDCSET' 	'VDCSET' 	'DVDCSET' 	'VMC' 	'VAC' 	'PCCONV' 	'QCCONV' 	'PCLOSS' 	'VMF' 	'VAF' 	'PFIL' 	'QCONVF' 	'QCCONVF' };
% col.branchdc = {'F_BUSDC' 	'T_BUSDC' 	'BRDC_R' 	'BRDC_L' 	'BRDC_C' 	'RATEDC_A' 	'RATEDC_B' 	'RATEDC_C' 	'BRDC_STATUS' 	'PFDC' 	'PTDC' };

assert(isstruct(r),'Inviald input %dth.\n')
s=r;
for i=1:length(fields)
    f = fields{i};
    if isfield(s,f)
        if iscell(s.(f))
            s.(f) = cell2mat(s.(f)(2:end,:));
        end
    end
end
end
