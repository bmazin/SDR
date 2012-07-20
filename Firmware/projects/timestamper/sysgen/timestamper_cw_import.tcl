#
# Created by System Generator     Thu Jul 19 16:33:11 2012
#
# Note: This file is produced automatically, and will be overwritten the next
# time you press "Generate" in System Generator.
#

source SgIseProject.tcl

namespace eval ::xilinx::dsptool::iseproject::param {

    set Project {timestamper_cw}
    set Family {Virtex5}
    set Device {xc5vsx95t}
    set Package {ff1136}
    set Speed {-1}
    set HDLLanguage {vhdl}
    set SynthesisTool {XST}
    set Simulator {Modelsim-SE}
    set ReadCores False
    set MapEffortLevel {High}
    set ParEffortLevel {High}
    set Frequency {256.003276841944}
    set ProjectFiles {
        {{timestamper_cw.vhd} -view Implementation}
        {{timestamper.vhd} -view Implementation}
        {{timestamper_cw.ucf}}
        {{/home/sean/SDR/Firmware/projects/timestamper.mdl}}
    }
    set TopLevelModule {timestamper_cw}
    set SynthesisConstraintsFile {timestamper_cw.xcf}
    set ImplementationStopView {Structural}
    set ProjectGenerator {SysgenDSP}
}
::xilinx::dsptool::iseproject::create
