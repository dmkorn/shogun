from pylab import figure,pcolor,scatter,contour,colorbar,show,subplot,plot,legend, connect
from shogun.Features import *
from shogun.Regression import *
from shogun.Kernel import *
import util

util.set_title('SVR on Sinus')

X, Y=util.get_sinedata()
C=10
width=0.5
epsilon=0.01

feat = RealFeatures(X)
lab = Labels(Y.flatten())
gk=GaussianKernel(feat,feat, width)
#svr = SVRLight(C, epsilon, gk, lab)
svr = LibSVR(C, epsilon, gk, lab)
svr.train()

plot(X, Y, '.', label='train data')
plot(X[0], svr.classify().get_labels(), hold=True, label='train output')

XE, YE=util.compute_output_plot_isolines_sine(svr, gk, feat)
plot(XE[0], YE, hold=True, label='test output')

connect('key_press_event', util.quit)
show()
