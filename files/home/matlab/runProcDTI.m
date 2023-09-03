function [] = runProcDTI(parms)
% function [] = runProcDTI(parms)
%   run processing on the local machine
%

s = what('/home/MMPS/batchdirs/DAL_ABCD_proc_DTI/');

cd('/home/MMPS/batchdirs/DAL_ABCD_proc_DTI');
for i=1:length(s.m),
  sprintf('now exectuting %s', s.m{i})
  fname = s.m{i};
  fname = fname(1:end-2);
  [status,cmdout] = system(sprintf('matlab -r %s', fname))
  sprintf('done %s', s.m{i}) 
  %a = str2func(fname);
  %a();
end;

exit
