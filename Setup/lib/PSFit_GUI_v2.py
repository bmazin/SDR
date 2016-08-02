# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'PSFit_GUI_v2.ui'
#
# Created: Sat Aug 23 17:37:02 2014
#      by: PyQt4 UI code generator 4.9.4
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName(_fromUtf8("MainWindow"))
        MainWindow.resize(1100, 750)
        self.centralwidget = QtGui.QWidget(MainWindow)
        self.centralwidget.setObjectName(_fromUtf8("centralwidget"))
        self.open_filename = QtGui.QLineEdit(self.centralwidget)
        self.open_filename.setGeometry(QtCore.QRect(10, 210, 431, 21))
        self.open_filename.setObjectName(_fromUtf8("open_filename"))
        self.save_filename = QtGui.QLineEdit(self.centralwidget)
        self.save_filename.setGeometry(QtCore.QRect(10, 240, 431, 21))
        self.save_filename.setObjectName(_fromUtf8("save_filename"))
        self.plot_1 = MPL_Widget(self.centralwidget)
        self.plot_1.setGeometry(QtCore.QRect(10, 290, 541, 401))
        self.plot_1.setObjectName(_fromUtf8("plot_1"))
        self.plot_2 = MPL_Widget(self.centralwidget)
        self.plot_2.setGeometry(QtCore.QRect(560, 290, 541, 401))
        self.plot_2.setObjectName(_fromUtf8("plot_2"))
        self.plot_3 = MPL_Widget(self.centralwidget)
        self.plot_3.setGeometry(QtCore.QRect(450, 10, 651, 281))
        self.plot_3.setObjectName(_fromUtf8("plot_3"))
        self.widget = QtGui.QWidget(self.centralwidget)
        self.widget.setGeometry(QtCore.QRect(10, 10, 431, 181))
        self.widget.setObjectName(_fromUtf8("widget"))
        self.gridLayout = QtGui.QGridLayout(self.widget)
        self.gridLayout.setMargin(0)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.open_browse = QtGui.QPushButton(self.widget)
        self.open_browse.setObjectName(_fromUtf8("open_browse"))
        self.gridLayout.addWidget(self.open_browse, 0, 0, 1, 1)
        self.jumptonum = QtGui.QSpinBox(self.widget)
        self.jumptonum.setGeometry(QtCore.QRect(810, 690, 57, 31))
        self.jumptonum.setMaximum(9999)
        self.jumptonum.setObjectName(_fromUtf8("jumptonum"))
        self.gridLayout.addWidget(self.jumptonum, 1, 1, 1, 1)
        self.frequency = QtGui.QLabel(self.widget)
        self.frequency.setObjectName(_fromUtf8("frequency"))
        self.gridLayout.addWidget(self.frequency, 3, 6, 1, 1)
        self.save_browse = QtGui.QPushButton(self.widget)
        self.save_browse.setObjectName(_fromUtf8("save_browse"))
        self.gridLayout.addWidget(self.save_browse, 0, 1, 1, 1)
        self.atten = QtGui.QSpinBox(self.widget)
        self.atten.setMaximumSize(QtCore.QSize(776, 16777215))
        self.atten.setObjectName(_fromUtf8("atten"))
        self.gridLayout.addWidget(self.atten, 3, 1, 1, 1)
        self.jumptores = QtGui.QPushButton(self.widget)
        self.jumptores.setObjectName(_fromUtf8("jumptores"))
        self.gridLayout.addWidget(self.jumptores, 1, 0, 1, 1)
        self.label = QtGui.QLabel(self.widget)
        self.label.setObjectName(_fromUtf8("label"))
        self.gridLayout.addWidget(self.label, 3, 0, 1, 1)
        self.res_num = QtGui.QLabel(self.widget)
        self.res_num.setStatusTip(_fromUtf8(""))
        self.res_num.setObjectName(_fromUtf8("res_num"))
        self.gridLayout.addWidget(self.res_num, 1, 6, 1, 1)
        self.savevalues = QtGui.QPushButton(self.widget)
        self.savevalues.setObjectName(_fromUtf8("savevalues"))
        self.gridLayout.addWidget(self.savevalues, 4, 0, 1, 1)
        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtGui.QMenuBar(MainWindow)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 1100, 22))
        self.menubar.setObjectName(_fromUtf8("menubar"))
        MainWindow.setMenuBar(self.menubar)
        self.statusbar = QtGui.QStatusBar(MainWindow)
        self.statusbar.setObjectName(_fromUtf8("statusbar"))
        MainWindow.setStatusBar(self.statusbar)
        self.actionOpen = QtGui.QAction(MainWindow)
        self.actionOpen.setObjectName(_fromUtf8("actionOpen"))
        self.s = QtGui.QAction(MainWindow)
        self.s.setObjectName(_fromUtf8("s"))

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        MainWindow.setWindowTitle(QtGui.QApplication.translate("MainWindow", "MainWindow", None, QtGui.QApplication.UnicodeUTF8))
        self.open_browse.setText(QtGui.QApplication.translate("MainWindow", "Open", None, QtGui.QApplication.UnicodeUTF8))
        self.jumptonum.setToolTip(QtGui.QApplication.translate("MainWindow", "Resonator Number", None, QtGui.QApplication.UnicodeUTF8))
        self.frequency.setToolTip(QtGui.QApplication.translate("MainWindow", "Frequency (GHz)", None, QtGui.QApplication.UnicodeUTF8))
        self.frequency.setText(QtGui.QApplication.translate("MainWindow", "-1", None, QtGui.QApplication.UnicodeUTF8))
        self.save_browse.setText(QtGui.QApplication.translate("MainWindow", "Save", None, QtGui.QApplication.UnicodeUTF8))
        self.atten.setToolTip(QtGui.QApplication.translate("MainWindow", "Attenuation", None, QtGui.QApplication.UnicodeUTF8))
        self.jumptores.setText(QtGui.QApplication.translate("MainWindow", "Jump To Res", None, QtGui.QApplication.UnicodeUTF8))
        self.label.setText(QtGui.QApplication.translate("MainWindow", "atten", None, QtGui.QApplication.UnicodeUTF8))
        self.res_num.setToolTip(QtGui.QApplication.translate("MainWindow", "Resonator Number", None, QtGui.QApplication.UnicodeUTF8))
        self.res_num.setText(QtGui.QApplication.translate("MainWindow", "-1", None, QtGui.QApplication.UnicodeUTF8))
        self.savevalues.setToolTip(QtGui.QApplication.translate("MainWindow", "Save this resonator and move to next one", None, QtGui.QApplication.UnicodeUTF8))
        self.savevalues.setText(QtGui.QApplication.translate("MainWindow", "Save Values", None, QtGui.QApplication.UnicodeUTF8))
        self.actionOpen.setText(QtGui.QApplication.translate("MainWindow", "Open", None, QtGui.QApplication.UnicodeUTF8))
        self.s.setText(QtGui.QApplication.translate("MainWindow", "Save", None, QtGui.QApplication.UnicodeUTF8))

from lib.mpl_pyqt4_widget import MPL_Widget

if __name__ == "__main__":
    import sys
    app = QtGui.QApplication(sys.argv)
    MainWindow = QtGui.QMainWindow()
    ui = Ui_MainWindow()
    ui.setupUi(MainWindow)
    MainWindow.show()
    sys.exit(app.exec_())

