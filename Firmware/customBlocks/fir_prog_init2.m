function fir_prog_init2(blk, varargin)
% By Matt Strader
%
% delay_wideband_prog_init(blk, varargin)
%
% blk = The block to configure.
% varargin = {'varname', 'value', ...} pairs
% 
% Declare any default values for arguments you might like.

clog('Entering fir_prog_init','trace'); 
disp('fir_prog_init')
defaults = {'nChannels', 256, 'nTaps', 26,'coeffBits',12,'coeffBinPt',11};
 
% if parameter is changed then only it will redraw otherwise will exit
if same_state(blk, 'defaults', defaults, varargin{:})
    disp('same state')
    return
end
clog('fir_prog_init post same_state','trace'); 
% Checks whether the block selected is correct with this called function.
check_mask_type(blk, 'fir_prog');
 
%Sets the variable to the sub-blocks (scripted ones), also checks whether
%to update or prevent from any update
munge_block(blk, varargin{:});
 
% sets the variable needed
nChannels = get_var('nChannels', 'defaults', defaults, varargin{:});
nTaps = get_var('nTaps', 'defaults', defaults, varargin{:});
coeffBits = get_var('coeffBits', 'defaults', defaults, varargin{:});
coeffBinPt = get_var('coeffBinPt', 'defaults', defaults, varargin{:});
 
% Begin redrawing
delete_lines(blk);

x = 30;
y = 30;
w = 30;
h = 30;
offset = 60;

disp('adding blocks')

% create inputs
reuse_block(blk,'sync_in','built-in/Inport',...
                'Port', '1',...
                'Position',[0 500 30 500+20]) ; 

reuse_block(blk,'data_in','built-in/Inport',...
                'Port', '2',...
                'Position',[0 205 30 205+20]) ; 


reuse_block(blk,'ch','built-in/Inport',...
                'Port', '3',...
                'Position',[0 580 30 580+20]) ; 

sumPos = [200+(nTaps+1)*150 400 200+(nTaps+1)*150+160 20*nTaps+400];
syncOutX = sumPos(1)+200;
syncOutW = 30;
syncOutY = sumPos(2);
syncOutH = 20;

syncOutPos = [syncOutX syncOutY syncOutX+syncOutW syncOutY+syncOutH];
dataOutY = sumPos(2)+60;
dataOutPos = [syncOutX dataOutY syncOutX+syncOutW dataOutY+syncOutH];

%create outputs
reuse_block(blk,'sync_out','built-in/Outport',...
                'Port', '1',...
                'Position',syncOutPos) ; 

reuse_block(blk,'data_out','built-in/Outport',...
                'Port', '2',...
                'Position',dataOutPos) ; 
%create internal blocks
sync_latency = 6;%5 from mult, 1 from bram, delay from adder tree will be added by adder tree
reuse_block(blk,'sync_delay','xbsIndex_r4/Delay',...
            'Position',[90 500 90+30 500+30],...
            'latency',num2str(sync_latency));


bramLatency=1;% delay data enough to address and read from coeff bram block
reuse_block(blk,'data_delay','xbsIndex_r4/Delay',...
            'Position',[40 205 40+30 205+30],...
            'latency',num2str(bramLatency));

add_latency=3;
reuse_block(blk, 'sum', 'casper_library_misc/adder_tree', ...
    'Position', sumPos, ...
    'n_inputs',num2str(nTaps),'latency',num2str(add_latency), ...
    'adder_imp', 'DSP48','first_stage_hdl','on');

add_line(blk,'sync_in/1','sync_delay/1','autorouting','on');
add_line(blk,'sum/2','data_out/1','autorouting','off');
add_line(blk,'sync_delay/1','sum/1','autorouting','off');
add_line(blk,'sum/1','sync_out/1','autorouting','off');

%if the bits in the coefficients are too great to fit in a bram altogether, it must be split into multiple bram blocks.
bramDataWidth = 64; %width that can be stored in a single-port block memory in a cycle
nCoeffsPerBram = floor(bramDataWidth/coeffBits);
nBrams = ceil(nTaps/nCoeffsPerBram);
nCoeffsInLastBram = rem(nTaps,nCoeffsPerBram);
if nCoeffsInLastBram == 0
    nCoeffsInLastBram = nCoeffsPerBram;
end

reuse_block(blk, 'we_const', 'xbsIndex_r4/Constant', ...
        'const', '0', 'arith_type', 'Boolean', ...
        'explicit_period', 'on', ...
        'Position',[0 630 30 630+20]);

reuse_block(blk, 'bram_data_const', 'xbsIndex_r4/Constant', ...
        'const', '0', 'arith_type', 'Unsigned', ...
        'n_bits', num2str(bramDataWidth), ...
        'bin_pt', '0', 'explicit_period', 'on', ...
        'Position',[0 605 30 605+20]);

for iTap=1:nTaps
    iTapLabel = num2str(iTap);
    offset = 50;
    x = 100 + iTap*3*offset;
    y = 400;
    w = 30;
    h = 30;


    sliceName = ['coeff_slice',iTapLabel];

    slicePosition = [x-60 y x-60+30 y+20];
    reuse_block(blk, sliceName,'xbsIndex_r4/Slice',...
                    'nbits', num2str(coeffBits),... %Width of slice
                    'mode', 'Lower Bit Location + Width',...
                    'bit0',num2str(coeffBits*rem(iTap-1,nCoeffsPerBram)),... %Offset of bottom bit
                    'base0', 'LSB of Input',...
                    'Position',slicePosition) ; 

    reinterpName = ['reinterp',iTapLabel];
    reuse_block(blk, reinterpName, 'xbsIndex_r4/Reinterpret', ...
        'Position', [x y x+30 y+20], ...
        'force_arith_type', 'on', 'arith_type', 'Signed  (2''s comp)', ...
        'force_bin_pt', 'on', 'bin_pt', num2str(coeffBinPt));
    
    add_line(blk,[sliceName,'/1'],[reinterpName,'/1'],'autorouting','on');

    multname = ['Mult',iTapLabel];
    reuse_block(blk, multname, 'xbsIndex_r4/Mult');
    set_param([blk,'/',multname], ...
            'precision','Full',...
            'latency','5',...
            'use_behavioral_HDL','off',...
            'opt','Speed',...
            'use_embedded','on',...
            'optimum_pipeline','on',...
            'Position', [x+offset y-offset x+offset+40 y-offset+40]);

    add_line(blk,[reinterpName,'/1'],[multname,'/2'],'autorouting','on');
    if iTap < nTaps
        delayname = ['delay',num2str(iTap)];
        reuse_block(blk,delayname,'casper_library_delays/delay_bram',...
                'Position',[x+2*offset y-2*offset x+2*offset+w y-2*offset+h],...
                'DelayLen',num2str(nChannels),...
                'bram_latency',num2str(2),...
                'use_dsp48','off',...
                'async','off');
    end
    if iTap > 1
        lastdelayname = ['delay',num2str(iTap-1)];
        delayname = ['delay',num2str(iTap)];
        add_line(blk,[lastdelayname,'/1'],[multname,'/1'],'autorouting','on');
        if iTap < nTaps
            add_line(blk,[lastdelayname,'/1'],[delayname,'/1'],'autorouting','on');
        end
    end
    add_line(blk,[multname,'/1'],['sum','/',num2str(iTap+1)],'autorouting','off');

end
add_line(blk,'data_in/1','data_delay/1','autorouting','on');
add_line(blk,'data_delay/1','delay1/1','autorouting','on');
add_line(blk,'data_delay/1','Mult1/1','autorouting','on');

if nBrams > 1

    for iBram=1:nBrams

        bramName = ['bram',num2str(iBram)];
        defaultBramVal = '0';
        nCoeffsInBram = nCoeffsPerBram;
        if iBram == nBrams
            nCoeffsInBram = nCoeffsInLastBram;
            defaultBramVal = num2str(bin2dec(repmat('1',1,coeffBinPt)));
        end
%        sliceName = ['mem_sl',num2str(iBram)];
%        reuse_block(blk, sliceName,'xbsIndex_r4/Slice',...
%                'nbits', num2str(nBitsInBram),... %Width of slice
%                'mode', 'Upper Bit Location + Width',...
%                'bit1',num2str(-1*bramDataWidth*(iBram-1)),... %Offset of bottom bit
%                'base1', 'MSB of Input',...
%                'Position',[50 580+iBram*120 50+50 580+iBram*120+70]) ; 
        %make the brams that will hold and feed the coefficients one channel at a time
        %make the default value 
%        reuse_block(blk, bramName, 'xbsIndex_r4/Single Port RAM', ...
%                'Position',[130 580+iBram*120 130+50 580+iBram*120+70],...
%                'depth', num2str(nChannels), ...
%                'initVector',defaultBramVal,...
%                'write_mode', 'No Read On Write',...
%                'latency','3');

        reuse_block(blk, bramName, 'xps_library/Shared BRAM', ...
            'data_width', num2str(bramDataWidth),...
            'addr_width', num2str(max(10,log2(nChannels))), ...
            'init_vals',defaultBramVal,...
            'Position',[130 580+iBram*120 130+50 580+iBram*120+70]);

        add_line(blk,'ch/1',[bramName,'/1'],'autorouting','on');
        add_line(blk,'bram_data_const/1',[bramName,'/2'],'autorouting','on');
        add_line(blk,'we_const/1',[bramName,'/3'],'autorouting','on');
        for iLine=1:nCoeffsInBram
            coeffName = ['coeff_slice',num2str(iLine+(iBram-1)*nCoeffsPerBram)];
            add_line(blk,[bramName,'/1'],[coeffName,'/1'],'autorouting','off');
        end
    end
else
    iBram=1;
    bramName = ['bram',num2str(iBram)];
    defaultBramVal = num2str(bin2dec(repmat('1',1,coeffBinPt)))
    reuse_block(blk, bramName, 'xps_library/Shared BRAM', ...
            'data_width', num2str(bramDataWidth),...
            'addr_width', num2str(max(10,log2(nChannels))), ...
            'init_vals',defaultBramVal,...
            'Position',[100 580 100+50 580+70]);

    add_line(blk,'ch/1',[bramName,'/1'],'autorouting','on');
    add_line(blk,'bram_data_const/1',[bramName,'/2'],'autorouting','on');
    add_line(blk,'we_const/1',[bramName,'/3'],'autorouting','on');
    nCoeffsInBram = nCoeffsInLastBram;
    for iLine=1:nCoeffsInBram
        coeffName = ['coeff_slice',num2str(iLine+(iBram-1)*nCoeffsPerBram)];
        add_line(blk,[bramName,'/1'],[coeffName,'/1'],'autorouting','off');
    end

end

disp('done adding blocks')
% clean out everything else
clean_blocks(blk);
 
%fmtstr = sprintf();
% Printing at the bottom of the block fmtstr = sprintf('Min
% Delay=%d',(n_inputs_bits + bram_latency+1); %
%set_param(blk, 'AttributesFormatString', fmtstr);
 
% Save all the variables just like global variables in C
save_state(blk, 'defaults', defaults, varargin{:});
clog('exiting fir_prog_init','trace'); 
