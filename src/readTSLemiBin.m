function [alldata, Fs, dnum1, dnum2] = readTSLemiBin(cfile, cpath, ConvFactors) 
% a simple script to read the Ukraine LEMI-417 binary file...
% note this supports the loading of multiple files at once, BUT,  
% there is no guarantee that the stitching of multiple files is correct, 
% samples could be missing in between the files (say, the previous file
% ends at 11:59, but the next file starts at 12:01) 
% see: Zhang et al., 2020 for details of the LEMI data format (in Chinese)
% doi:10.11720/wtyht.2020.1485
% 
% DONG Hao, 2023, in Nyingchi
% 
% cfile:       binary data files (can be a cell with multiple files)
% cpath:       path to the file
% ConvFactors: conversion factor (correction if there are some mistakes in
%              the station acquisition, should be all ones in default)
% alldata:     nsample by nchannel (7) array of em data
% Fs:          sampling frequency, as read from the file
% dnum1:       Matlab datenum of the starting time
% dnum2:       Matlab datenum of the ending time
if nargin < 3
    % three magnetic and four electrical channels
    ConvFactors = [1, 1, 1, 1, 1, 1, 1];
end
if iscell(cfile)
    nsite = length(cfile);
else
    nsite = 1;
end

if nsite > 1
    fid = fopen([cpath,cfile{1}], 'rb');
    fseek(fid,0,'eof');
    fsize = ftell(fid);
    % each data segment has only 512 bytes, with 16 records
    nblock = floor(fsize/512);
    fseek(fid,0,'bof');
    nsample = nblock * 16;
    % allocate for current segment
    dataSeg=zeros(nsample,30);
    % array to store the time tag of all blocks
    timeBlock = zeros(nblock,1);
    alldata = zeros(nsample,7);
    for i=0:1:nblock-1
        % read the tag
        tag = fread(fid,32,'uchar');
        YY = floor(tag(6)/16)*10 + mod(tag(6),16);
        MM = floor(tag(7)/16)*10 + mod(tag(7),16);
        DD = floor(tag(8)/16)*10 + mod(tag(8),16);
        hh = floor(tag(9)/16)*10 + mod(tag(9),16);
        mm = floor(tag(10)/16)*10 + mod(tag(10),16);
        ss = floor(tag(11)/16)*10 + mod(tag(11),16);
        fs = tag(26); %averaging setup in lemi
        timeBlock(i+1) = datenum(2000+YY,MM,DD,hh,mm,ss);
        % read the data segment 
        dataSeg(i*16+1:(i+1)*16,:) = fread(fid,[30,16],'uchar')'; 
    end
    fclose(fid);
    Fs = 4/fs;
    % now convert to real values 
    for ichannel = 1 : 3 % Bx, By, Bz， 24 bit
            alldata(:,ichannel) = dataconc24(dataSeg(:,(ichannel-1)*3+1)+...
                dataSeg(:,(ichannel-1)*3+2)*256+...
                dataSeg(:,(ichannel-1)*3+3)*256*256)*ConvFactors(ichannel); 
    end
    for ichannel = 4 : 7 % Ex1, Ey1, Ex2, Ey2, 32 bit
            alldata(:,ichannel) = dataconc32(dataSeg(:,9+(ichannel-4)*4+1)+...
                dataSeg(:,9+(ichannel-4)*4+2)*256+...
                dataSeg(:,9+(ichannel-4)*4+3)*256*256+...
                dataSeg(:,9+(ichannel-4)*4+4)*256*256*256)*ConvFactors(ichannel); 
    end
    fprintf('finished loading data file...\n');
    fprintf('Sampling frequency = %8.3f Hz\n', Fs);
    dnum1= timeBlock(1);
    % plus the last data segment length
    dnum2= timeBlock(end) + 16/Fs/86400;
    fprintf('starting time = %s \n', datestr(dnum1));
    fprintf('ending time   = %s \n', datestr(dnum2));
    fprintf('totally %d records (%6.3f days) loaded\n', nsample, nsample/86400/Fs);
    for isite = 2 : nsite
        fid = fopen([cpath,cfile{isite}], 'rb');
        fseek(fid,0,'eof');
        fsize = ftell(fid);
        % each data segment has only 512 bytes, with only 16 records
        nblock = floor(fsize/512);
        fseek(fid,0,'bof');
        nsample = nblock * 16;
        % allocate for current segment
        dataSeg=zeros(nsample,30);
        % array to store blocks 
        timeBlock = zeros(nblock,1);
        tdata = zeros(nsample,7);
        for i=0:1:nblock-1
            % read the tag
            tag = fread(fid,32,'uchar');
            YY = floor(tag(6)/16)*10 + mod(tag(6),16);
            MM = floor(tag(7)/16)*10 + mod(tag(7),16);
            DD = floor(tag(8)/16)*10 + mod(tag(8),16);
            hh = floor(tag(9)/16)*10 + mod(tag(9),16);
            mm = floor(tag(10)/16)*10 + mod(tag(10),16);
            ss = floor(tag(11)/16)*10 + mod(tag(11),16);
            fs = tag(26); %averaging setup in lemi
            timeBlock(i+1) = datenum(2000+YY,MM,DD,hh,mm,ss);
            % read the data segment 
            dataSeg(i*16+1:(i+1)*16,:) = fread(fid,[30,16],'uchar')'; 
        end
        fclose(fid);
        Fs = 4/fs;
        % now convert to real values 
        for ichannel = 1 : 3 % Bx, By, Bz， 24 bit
                tdata(:,ichannel) = dataconc24(dataSeg(:,(ichannel-1)*3+1)+...
                    dataSeg(:,(ichannel-1)*3+2)*256+...
                    dataSeg(:,(ichannel-1)*3+3)*256*256)*ConvFactors(ichannel); 
        end
        for ichannel = 4 : 7 % Ex1, Ey1, Ex2, Ey2, 32 bit
                tdata(:,ichannel) = dataconc32(dataSeg(:,9+(ichannel-4)*4+1)+...
                    dataSeg(:,9+(ichannel-4)*4+2)*256+...
                    dataSeg(:,9+(ichannel-4)*4+3)*256*256+...
                    dataSeg(:,9+(ichannel-4)*4+4)*256*256*256)*ConvFactors(ichannel); 
        end
        alldata = [alldata; tdata];
        fprintf('finished loading data file...\n');
        fprintf('Sampling frequency = %8.3f Hz\n', Fs);
        dnumt= timeBlock(1);
        if abs(dnumt - dnum2) > 1e-4
            % there is a time gap between the two files 
            error('start time in current file is not consistent with the previous end time, abort')
        end
        % plus the last data segment length
        dnum2= timeBlock(end) + 16/Fs/86400;
        fprintf('starting time = %s \n', datestr(timeBlock(1)));
        fprintf('ending time   = %s \n', datestr(dnum2));
        fprintf('totally %d records (%6.3f days) loaded\n', nsample, nsample/86400/Fs);
    end
else
    fid = fopen([cpath,cfile], 'rb');
    fseek(fid,0,'eof');
    fsize = ftell(fid);
    % each data segment has only 512 bytes, with only 16 records
    nblock = floor(fsize/512);
    fseek(fid,0,'bof');
    nsample = nblock * 16;
    % allocate for current segment
    dataSeg=zeros(nsample,30);
    % array to store blocks 
    timeBlock = zeros(nblock,1);
    alldata = zeros(nsample,7);
    for i=0:1:nblock-1
        % read the tag
        tag = fread(fid,32,'uchar');
        YY = floor(tag(6)/16)*10 + mod(tag(6),16);
        MM = floor(tag(7)/16)*10 + mod(tag(7),16);
        DD = floor(tag(8)/16)*10 + mod(tag(8),16);
        hh = floor(tag(9)/16)*10 + mod(tag(9),16);
        mm = floor(tag(10)/16)*10 + mod(tag(10),16);
        ss = floor(tag(11)/16)*10 + mod(tag(11),16);
        fs = tag(26); %averaging setup in lemi
        timeBlock(i+1) = datenum(2000+YY,MM,DD,hh,mm,ss);
        % read the data segment 
        dataSeg(i*16+1:(i+1)*16,:) = fread(fid,[30,16],'uchar')'; 
    end
    fclose(fid);
    Fs = 4/fs;
    % now convert to real values 
    for ichannel = 1 : 3 % Bx, By, Bz， 24 bit
            alldata(:,ichannel) = dataconc24(dataSeg(:,(ichannel-1)*3+1)+...
                dataSeg(:,(ichannel-1)*3+2)*256+...
                dataSeg(:,(ichannel-1)*3+3)*256*256)*ConvFactors(ichannel); 
    end
    for ichannel = 4 : 7 % Ex1, Ey1, Ex2, Ey2, 32 bit
            alldata(:,ichannel) = dataconc32(dataSeg(:,9+(ichannel-4)*4+1)+...
                dataSeg(:,9+(ichannel-4)*4+2)*256+...
                dataSeg(:,9+(ichannel-4)*4+3)*256*256+...
                dataSeg(:,9+(ichannel-4)*4+4)*256*256*256)*ConvFactors(ichannel); 
    end
    fprintf('finished loading data file...\n');
    fprintf('Sampling frequency = %8.3f Hz\n', Fs);
    dnum1= timeBlock(1);
    % plus the last data segment length
    dnum2= timeBlock(end) + 16/Fs/86400;
    fprintf('starting time = %s \n', datestr(dnum1));
    fprintf('ending time   = %s \n', datestr(dnum2));
    fprintf('totally %d records (%6.3f days) loaded\n', nsample, nsample/86400/Fs);
end
