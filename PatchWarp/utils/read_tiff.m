function [stack,info,frame_tag] = read_tiff(fn, ch, n_ch, network_temp_copy)
% Updated such that ScanImageTiffReader is used on Windows PC. by RH
% Note that tiff files in a network drive will be copied locally in a
% temporally folder in Mac OS or Linux by default because MATLAB's imread is very slow
% for files in some network drives. This behavior can be disabled by network_temp_copy =0
% In Windows, local copies are not created because ScanImageTiffReader reads files in a network drive 
% very efficiently. I have not tested ScanImageTiffReader in Mac OS or Linux, so
% I enable ScanImageTiffReader only for Windows users for now. At the moment, reading tiff files are 
% much faster on Windows.

    if(nargin<1)
        [filename, pathname]=uigetfile({'*.tiff;*.tif','Tiff Files(*.tiff, *.tif)'},'Select Tiff file');
        fn = fullfile(pathname,filename);
    end
    if(nargin<2)
        ch=1;
    end
    if(nargin<3)
        n_ch=1;
    end
    if(nargin<4)
        network_temp_copy=1;
    end
    try
        [m,n_ch,info]=memory_map_tiff(fn,'matrix',n_ch);
        w=info(1).ImageWidth;
        stack=m.Data.allchans(:,(1:w)+w*(ch-1),:);
    catch
        [imData,info]=bigread4(fn);
        frame_int=ch:n_ch:size(imData,3);
        stack=imData(:,:,frame_int);
    end
    frame_tag = get_frame_tag_from_info(info);
%     if(iscell(fn))
%         stack_c = cell(numel(fn),1);
%         info_c = cell(numel(fn),1);
%         frame_tag_c = cell(numel(fn),1);
%         for i=1:numel(fn)
%             if(nargout>2)
%                 [stack_c{i}, info_c{i}, frame_tag_c{i}] = read_tiff(fn{i}, ch, n_ch);
%             else
%                 [stack_c{i}, info_c{i}] = read_tiff(fn{i}, ch, n_ch);
%             end
%         end
%         stack = cat(3,stack_c{:});
%         info = cat(1,info_c{:});
%         frame_tag = cat(1,frame_tag_c{:});
%         return;
%     end
%     
%     temp_fn = [tempname_if_on_network2(fn)];
%     if (~isempty(temp_fn)) && ~ispc && network_temp_copy
%         copyfile(fn,temp_fn)
%         file_to_read = temp_fn;
%         file_to_delete = temp_fn;
%     else
%         file_to_read = fn;
%         file_to_delete = '';
%     end
%     
%     try
% %	try
%         info_all = imfinfo(file_to_read);
% %	catch					% added try-catch, but this is not optimal in terms of computation time. by RH
% %	file_to_read = fn;
% %	info_all = imfinfo(file_to_read);
% %	end
% 	
%         last_frame = floor(length(info_all)/n_ch)*n_ch;
%         if(last_frame ~= length(info_all))
%             warning('Total frames are not a multiple of n_ch.');
%         end
%         load_frames = bsxfun(@plus,ch(:),0:n_ch:last_frame-1);
% 
%         if(isempty(load_frames))
%             warning('No frame to read');
%             stack=[];
%             info = info_all([]);
%             frame_tag = [];
%         else
%             info=info_all(load_frames(1,:));
%             if(nargout>=3)
%                 frame_tag = get_frame_tag_from_info(info);
%             end
%             
%             if ispc
%                 reader = ScanImageTiffReader(file_to_read);
%                 stack_raw = reader.data();
%                 stack = zeros(size(stack_raw,1),size(stack_raw,2),size(load_frames,2),size(load_frames,1),class(stack_raw));
%                 for i_ch=1:size(load_frames,1)
%                     stack(:,:,:,i_ch) = stack_raw(:,:,load_frames(i_ch,:));
%                 end
%                 stack = permute(stack, [2 1 3 4]);
%                 reader.delete()
%             else
%                 first_frame = imread(file_to_read,'tiff','index',load_frames(1));
%                 stack = zeros(size(first_frame,1),size(first_frame,2),size(load_frames,2),size(load_frames,1),class(first_frame));
%                 i_frame=1;i_ch=1;
%                 stack(:,:,i_frame,i_ch)=first_frame;
%                 for i_ch=2:size(load_frames,1)
%                     stack(:,:,i_frame,i_ch) = imread(file_to_read,'tiff','index',load_frames(i_ch,i_frame));
%                 end
%                 for i_frame = 2:size(load_frames,2)
%                     for i_ch=1:size(load_frames,1)
%                         stack(:,:,i_frame,i_ch) = imread(file_to_read,'tiff','index',load_frames(i_ch,i_frame));
%                     end
%                 end
%             end
%         end
%         if(~isempty(file_to_delete))
%             delete(file_to_delete);
%         end
%     catch e
%         if(~isempty(file_to_delete))
%             delete(file_to_delete);
%         end
%         rethrow(e)
%     end
end
