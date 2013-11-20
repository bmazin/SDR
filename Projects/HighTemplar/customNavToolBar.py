from matplotlib.backends.backend_qt4agg import NavigationToolbar2QTAgg

class customNavToolBar(NavigationToolbar2QTAgg):

    def __init__(self,plotCanvas,mainFrame):
        NavigationToolbar2QTAgg.__init__(self, plotCanvas,mainFrame)

    def back(self):
        print 'Go back a resonator'
        #self.emit(

    def forward(self):
        print 'Go forward a resonator'
    
