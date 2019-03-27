function changeDirNames(dirName)

allSubDirs = AllSubDirs(dirName);
for i = 1:length(allSubDirs)    
    subsubDirs = AllSubDirs(allSubDirs);
    for j = 1:length(subsubDirs)
        thisDir = allSubDirs(j);
        thisDirName = thisDir.name;
        if ~strcmp(thisDirName,'Dina')
            oldname = fullfile(dirName,thisDir.name);
            newname = [fullfile(dirName,thisDir.name) '1-4'];
            movefile(oldname,newname);
        end
    end
end

function sub_dirs = AllSubDirs(dirName)
dirResult = dir(dirName);
allDirs = dirResult([dirResult.isdir]);
sub_dirs = allDirs(3:end);
