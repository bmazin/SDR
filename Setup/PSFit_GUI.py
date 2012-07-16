# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'PSFit_GUI.ui'
#
# Created: Sun Jul 24 13:04:12 2011
#      by: PyQt4 UI code generator 4.8.4
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
        MainWindow.resize(915, 1010)
        self.centralwidget = QtGui.QWidget(MainWindow)
        self.centralwidget.setObjectName(_fromUtf8("centralwidget"))
        self.plot_1 = MPL_Widget(self.centralwidget)
        self.plot_1.setGeometry(QtCore.QRect(20, 10, 891, 311))
        self.plot_1.setObjectName(_fromUtf8("plot_1"))
        self.plot_2 = MPL_Widget(self.centralwidget)
        self.plot_2.setGeometry(QtCore.QRect(20, 330, 891, 331))
        self.plot_2.setObjectName(_fromUtf8("plot_2"))
        self.plot_3 = MPL_Widget(self.centralwidget)
        self.plot_3.setGeometry(QtCore.QRect(290, 660, 391, 301))
        self.plot_3.setObjectName(_fromUtf8("plot_3"))
        self.frequency = QtGui.QLabel(self.centralwidget)
        self.frequency.setGeometry(QtCore.QRect(790, 760, 62, 17))
        self.frequency.setObjectName(_fromUtf8("frequency"))
        self.atten = QtGui.QSpinBox(self.centralwidget)
        self.atten.setGeometry(QtCore.QRect(770, 790, 61, 31))
        self.atten.setObjectName(_fromUtf8("atten"))
        self.label = QtGui.QLabel(self.centralwidget)
        self.label.setGeometry(QtCore.QRect(710, 760, 71, 17))
        self.label.setObjectName(_fromUtf8("label"))
        self.savevalues = QtGui.QPushButton(self.centralwidget)
        self.savevalues.setGeometry(QtCore.QRect(730, 870, 131, 41))
        self.savevalues.setObjectName(_fromUtf8("savevalues"))
        self.label_2 = QtGui.QLabel(self.centralwidget)
        self.label_2.setGeometry(QtCore.QRect(710, 730, 91, 17))
        self.label_2.setObjectName(_fromUtf8("label_2"))
        self.res_num = QtGui.QLabel(self.centralwidget)
        self.res_num.setGeometry(QtCore.QRect(810, 730, 62, 17))
        self.res_num.setObjectName(_fromUtf8("res_num"))
        self.open_browse = QtGui.QPushButton(self.centralwidget)
        self.open_browse.setGeometry(QtCore.QRect(20, 700, 114, 32))
        self.open_browse.setObjectName(_fromUtf8("open_browse"))
        self.open_filename = QtGui.QLineEdit(self.centralwidget)
        self.open_filename.setGeometry(QtCore.QRect(20, 740, 261, 22))
        self.open_filename.setObjectName(_fromUtf8("open_filename"))
        self.save_browse = QtGui.QPushButton(self.centralwidget)
        self.save_browse.setGeometry(QtCore.QRect(20, 780, 114, 32))
        self.save_browse.setObjectName(_fromUtf8("save_browse"))
        self.save_filename = QtGui.QLineEdit(self.centralwidget)
        self.save_filename.setGeometry(QtCore.QRect(20, 820, 261, 22))
        self.save_filename.setObjectName(_fromUtf8("save_filename"))
        self.label_3 = QtGui.QLabel(self.centralwidget)
        self.label_3.setGeometry(QtCore.QRect(710, 800, 62, 17))
        self.label_3.setObjectName(_fromUtf8("label_3"))
        self.jumptores = QtGui.QPushButton(self.centralwidget)
        self.jumptores.setGeometry(QtCore.QRect(690, 686, 111, 41))
        self.jumptores.setObjectName(_fromUtf8("jumptores"))
        self.jumptonum = QtGui.QSpinBox(self.centralwidget)
        self.jumptonum.setGeometry(QtCore.QRect(810, 690, 57, 31))
        self.jumptonum.setMaximum(9999)
        self.jumptonum.setObjectName(_fromUtf8("jumptonum"))
        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtGui.QMenuBar(MainWindow)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 915, 22))
        self.menubar.setObjectName(_fromUtf8("menubar"))
        MainWindow.setMenuBar(self.menubar)
        self.statusbar = QtGui.QStatusBar(MainWindow)
        self.statusbar.setObjectName(_fromUtf8("statusbar"))
        MainWindow.setStatusBar(self.statusbar)

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        MainWindow.setWindowTitle(QtGui.QApplication.translate("MainWindow", "MainWindow", None, QtGui.QApplication.UnicodeUTF8))
        self.frequency.setText(QtGui.QApplication.translate("MainWindow", "TextLabel", None, QtGui.QApplication.UnicodeUTF8))
        self.label.setText(QtGui.QApplication.translate("MainWindow", "Frequency:", None, QtGui.QApplication.UnicodeUTF8))
        self.savevalues.setText(QtGui.QApplication.translate("MainWindow", "Save Values", None, QtGui.QApplication.UnicodeUTF8))
        self.label_2.setText(QtGui.QApplication.translate("MainWindow", "Res number:", None, QtGui.QApplication.UnicodeUTF8))
        self.res_num.setText(QtGui.QApplication.translate("MainWindow", "TextLabel", None, QtGui.QApplication.UnicodeUTF8))
        self.open_browse.setText(QtGui.QApplication.translate("MainWindow", "Open", None, QtGui.QApplication.UnicodeUTF8))
        self.save_browse.setText(QtGui.QApplication.translate("MainWindow", "Save to:", None, QtGui.QApplication.UnicodeUTF8))
        self.label_3.setText(QtGui.QApplication.translate("MainWindow", "Atten:", None, QtGui.QApplication.UnicodeUTF8))
        self.jumptores.setText(QtGui.QApplication.translate("MainWindow", "Jump to Res", None, QtGui.QApplication.UnicodeUTF8))

from mpl_pyqt4_widget import MPL_Widget
