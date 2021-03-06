
function dark_pfb_core10_config(this_block)

  % Revision History:
  %
  %   08-Feb-2016  (11:54 hours):
  %     Original code was machine generated by Xilinx's System Generator after parsing
  %     /Scratch/firmware/components/dark_pfb_core10/sysgen/dark_pfb_core10.vhd
  %
  %

  this_block.setTopLevelLanguage('VHDL');

  this_block.setEntityName('dark_pfb_core10');

  % System Generator has to assume that your entity  has a combinational feed through; 
  %   if it  doesn't, then comment out the following line:
  this_block.tagAsCombinational;

  this_block.addSimulinkInport('data0');
  this_block.addSimulinkInport('data1');
  this_block.addSimulinkInport('data2');
  this_block.addSimulinkInport('data3');
  this_block.addSimulinkInport('data4');
  this_block.addSimulinkInport('data5');
  this_block.addSimulinkInport('data6');
  this_block.addSimulinkInport('data7');
  this_block.addSimulinkInport('skip_pfb');
  this_block.addSimulinkInport('sync_in');

  this_block.addSimulinkOutport('bin0_t0');
  this_block.addSimulinkOutport('bin0_t1');
  this_block.addSimulinkOutport('bin1_t0');
  this_block.addSimulinkOutport('bin1_t1');
  this_block.addSimulinkOutport('bin2_t0');
  this_block.addSimulinkOutport('bin2_t1');
  this_block.addSimulinkOutport('bin3_t0');
  this_block.addSimulinkOutport('bin3_t1');
  this_block.addSimulinkOutport('bin4_t0');
  this_block.addSimulinkOutport('bin4_t1');
  this_block.addSimulinkOutport('bin5_t0');
  this_block.addSimulinkOutport('bin5_t1');
  this_block.addSimulinkOutport('bin6_t0');
  this_block.addSimulinkOutport('bin6_t1');
  this_block.addSimulinkOutport('bin7_t0');
  this_block.addSimulinkOutport('bin7_t1');
  this_block.addSimulinkOutport('bin_ctr');
  this_block.addSimulinkOutport('fft_rdy');
  this_block.addSimulinkOutport('overflow');

  bin0_t0_port = this_block.port('bin0_t0');
  bin0_t0_port.setType('UFix_36_0');
  bin0_t1_port = this_block.port('bin0_t1');
  bin0_t1_port.setType('UFix_36_0');
  bin1_t0_port = this_block.port('bin1_t0');
  bin1_t0_port.setType('UFix_36_0');
  bin1_t1_port = this_block.port('bin1_t1');
  bin1_t1_port.setType('UFix_36_0');
  bin2_t0_port = this_block.port('bin2_t0');
  bin2_t0_port.setType('UFix_36_0');
  bin2_t1_port = this_block.port('bin2_t1');
  bin2_t1_port.setType('UFix_36_0');
  bin3_t0_port = this_block.port('bin3_t0');
  bin3_t0_port.setType('UFix_36_0');
  bin3_t1_port = this_block.port('bin3_t1');
  bin3_t1_port.setType('UFix_36_0');
  bin4_t0_port = this_block.port('bin4_t0');
  bin4_t0_port.setType('UFix_36_0');
  bin4_t1_port = this_block.port('bin4_t1');
  bin4_t1_port.setType('UFix_36_0');
  bin5_t0_port = this_block.port('bin5_t0');
  bin5_t0_port.setType('UFix_36_0');
  bin5_t1_port = this_block.port('bin5_t1');
  bin5_t1_port.setType('UFix_36_0');
  bin6_t0_port = this_block.port('bin6_t0');
  bin6_t0_port.setType('UFix_36_0');
  bin6_t1_port = this_block.port('bin6_t1');
  bin6_t1_port.setType('UFix_36_0');
  bin7_t0_port = this_block.port('bin7_t0');
  bin7_t0_port.setType('UFix_36_0');
  bin7_t1_port = this_block.port('bin7_t1');
  bin7_t1_port.setType('UFix_36_0');
  bin_ctr_port = this_block.port('bin_ctr');
  bin_ctr_port.setType('UFix_8_0');
  fft_rdy_port = this_block.port('fft_rdy');
  fft_rdy_port.setType('UFix_1_0');
  fft_rdy_port.useHDLVector(false);
  overflow_port = this_block.port('overflow');
  overflow_port.setType('UFix_4_0');

  % -----------------------------
  if (this_block.inputTypesKnown)
    % do input type checking, dynamic output type and generic setup in this code block.

    if (this_block.port('data0').width ~= 24);
      this_block.setError('Input data type for port "data0" must have width=24.');
    end

    if (this_block.port('data1').width ~= 24);
      this_block.setError('Input data type for port "data1" must have width=24.');
    end

    if (this_block.port('data2').width ~= 24);
      this_block.setError('Input data type for port "data2" must have width=24.');
    end

    if (this_block.port('data3').width ~= 24);
      this_block.setError('Input data type for port "data3" must have width=24.');
    end

    if (this_block.port('data4').width ~= 24);
      this_block.setError('Input data type for port "data4" must have width=24.');
    end

    if (this_block.port('data5').width ~= 24);
      this_block.setError('Input data type for port "data5" must have width=24.');
    end

    if (this_block.port('data6').width ~= 24);
      this_block.setError('Input data type for port "data6" must have width=24.');
    end

    if (this_block.port('data7').width ~= 24);
      this_block.setError('Input data type for port "data7" must have width=24.');
    end

    if (this_block.port('skip_pfb').width ~= 1);
      this_block.setError('Input data type for port "skip_pfb" must have width=1.');
    end

    this_block.port('skip_pfb').useHDLVector(false);

    if (this_block.port('sync_in').width ~= 1);
      this_block.setError('Input data type for port "sync_in" must have width=1.');
    end

    this_block.port('sync_in').useHDLVector(false);

  end  % if(inputTypesKnown)
  % -----------------------------

  % -----------------------------
   if (this_block.inputRatesKnown)
     setup_as_single_rate(this_block,'clk_1','ce_1')
   end  % if(inputRatesKnown)
  % -----------------------------

    % (!) Set the inout port rate to be the same as the first input 
    %     rate. Change the following code if this is untrue.
    uniqueInputRates = unique(this_block.getInputRates);


  % Add addtional source files as needed.
  %  |-------------
  %  | Add files in the order in which they should be compiled.
  %  | If two files "a.vhd" and "b.vhd" contain the entities
  %  | entity_a and entity_b, and entity_a contains a
  %  | component of type entity_b, the correct sequence of
  %  | addFile() calls would be:
  %  |    this_block.addFile('b.vhd');
  %  |    this_block.addFile('a.vhd');
  %  |-------------

  %    this_block.addFile('');
  %    this_block.addFile('');
  this_block.addFile('../components/dark_pfb_core10/sysgen/dark_pfb_core10.vhd');

return;


% ------------------------------------------------------------

function setup_as_single_rate(block,clkname,cename) 
  inputRates = block.inputRates; 
  uniqueInputRates = unique(inputRates); 
  if (length(uniqueInputRates)==1 & uniqueInputRates(1)==Inf) 
    block.addError('The inputs to this block cannot all be constant.'); 
    return; 
  end 
  if (uniqueInputRates(end) == Inf) 
     hasConstantInput = true; 
     uniqueInputRates = uniqueInputRates(1:end-1); 
  end 
  if (length(uniqueInputRates) ~= 1) 
    block.addError('The inputs to this block must run at a single rate.'); 
    return; 
  end 
  theInputRate = uniqueInputRates(1); 
  for i = 1:block.numSimulinkOutports 
     block.outport(i).setRate(theInputRate); 
  end 
  block.addClkCEPair(clkname,cename,theInputRate); 
  return; 

% ------------------------------------------------------------

