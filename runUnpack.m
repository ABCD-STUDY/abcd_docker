function [] = runUnpack(parms)
% function [] = runUnpack(parms)
%   run processing on the local machine
%

s = what('/home/MMPS/batchdirs/DAL_ABCD_unpack/');

cd('/home/MMPS/batchdirs/DAL_ABCD_unpack');
for i=1:length(s.m),
  sprintf('JOB: %s', s.m{i})
  fname = s.m{i};
  fname = fname(1:end-2);
  [status, cmdout] = system(sprintf('matlab -r %s', fname));
  sprintf('Done JOB: %s', s.m{i})
  %a = str2func(fname);
  %a();
end;

exit

