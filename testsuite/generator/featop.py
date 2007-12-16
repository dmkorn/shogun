"""
Common operations on features
"""

from shogun.Features import *
from shogun.PreProc import *

WORDSTRING_ORDER=3
WORDSTRING_GAP=0
WORDSTRING_REVERSE=False

def get_simple (ftype, data, alphabet=DNA, sparse=False):
	if ftype=='Byte' or ftype=='Char':
		train=eval(ftype+"Features(data['train'], alphabet)")
		test=eval(ftype+"Features(data['test'], alphabet)")
	else:
		train=eval(ftype+"Features(data['train'])")
		test=eval(ftype+"Features(data['test'])")

	if sparse:
		sparse_train=eval('Sparse'+ftype+'Features()')
		sparse_train.obtain_from_simple(train)

		sparse_test=eval('Sparse'+ftype+'Features()')
		sparse_test.obtain_from_simple(test)

		return {'train':sparse_train, 'test':sparse_test}
	else:
		return {'train':train, 'test':test}

def get_string (ftype, data, alphabet=DNA):
	train=eval('String'+ftype+"Features(alphabet)")
	train.set_string_features(data['train'])
	test=eval('String'+ftype+"Features(alphabet)")
	test.set_string_features(data['test'])

	return {'train':train, 'test':test}

def get_string_complex (ftype, data, alphabet=DNA, order=WORDSTRING_ORDER,
	gap=WORDSTRING_GAP, reverse=WORDSTRING_REVERSE):

	feats={}

	charfeat=StringCharFeatures(alphabet)
	charfeat.set_string_features(data['train'])
	feat=eval('String'+ftype+'Features(charfeat.get_alphabet())')
	feat.obtain_from_char(charfeat, order-1, order, gap, reverse)
	if ftype=='Word':
		preproc=SortWordString()
		preproc.init(feat)
		feat.add_preproc(preproc)
		feat.apply_preproc()
	feats['train']=feat

	charfeat=StringCharFeatures(alphabet)
	charfeat.set_string_features(data['test'])
	feat=eval('String'+ftype+'Features(charfeat.get_alphabet())')
	feat.obtain_from_char(charfeat, order-1, order, gap, reverse)
	if ftype=='Word':
		feat.add_preproc(preproc)
		feat.apply_preproc()
	feats['test']=feat

	return feats

