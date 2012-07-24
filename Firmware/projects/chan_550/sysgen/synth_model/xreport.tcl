if {[file exists {chan_550_cw.ise}] && [file exists {chan_550_cw.xise}] && [file exists {chan_550_cw.gise}]} {
    project open {chan_550_cw}
} else {
    file delete {chan_550_cw.ise} {chan_550_cw.xise} {chan_550_cw.gise}
    project new {chan_550_cw}
}
project set "Enable Enhanced Design Summary" true
project set "Enable Message Filtering" true
project set "Display Incremental Messages" true
project set "Message Filter File" {../filter.filter}
project close
