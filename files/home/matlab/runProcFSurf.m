function [] = runProcFSurf(parms)

%   run processing on the local machine

s = dir('/home/MMPS/batchdirs/DAL_ABCD_fsurf/*.csh');
%batchdirs_folder = sprintf('/home/MMPS/batchdirs/DAL_ABCD_fsurf')
%s = what(batchdirs_folder);

cd('/home/MMPS/batchdirs/DAL_ABCD_fsurf');
for i=1:length(s),
  sprintf('now executing: %s', s(i).name)
  fname = s(i).name;
  %fname = fname(1:end-2);
  [status, cmdout] = system(sprintf('csh %s', fname));
  sprintf('DONE: %s', s(i).name)

  
end;

exit
