unique template features/docker/pipework;

#Copy some needed files
include {'components/filecopy/config'};

prefix '/software/components/filecopy/services/';

'{/usr/bin/pipework}/config' = file_contents('features/docker/pipework');
'{/usr/bin/pipework}/perms' = '0755';


