if {[file exists {chan_512_packet_cw.ise}] && [file exists {chan_512_packet_cw.xise}] && [file exists {chan_512_packet_cw.gise}]} {
    project open {chan_512_packet_cw}
} else {
    file delete {chan_512_packet_cw.ise} {chan_512_packet_cw.xise} {chan_512_packet_cw.gise}
    project new {chan_512_packet_cw}
}
project set "Enable Enhanced Design Summary" true
project set "Enable Message Filtering" true
project set "Display Incremental Messages" true
project set "Message Filter File" {../filter.filter}
project close
