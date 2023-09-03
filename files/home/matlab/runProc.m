function [] = runProc(parms)
% function [] = runProc(parms)
%   run processing on the local machine
%

batchdirs_folder = sprintf('/home/MMPS/batchdirs/DAL_ABCD_proc')
s = what(batchdirs_folder);

cd(batchdirs_folder);
for i=1:length(s.m),
  sprintf('now executing: %s', s.m{i})
  fname = s.m{i};
  fname = fname(1:end-2);
  [status,cmdout] = system(sprintf('matlab -r %s', fname));
  sprintf('finished: %s', s.m{i})
  %a = str2func(fname);
  %a();
end;

exit
