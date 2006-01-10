#!/usr/bin/env python
#
import os
import string
import re
import shelve

# doing a little cleanup here
def cleanup():
   os.system('rm .deps')
   os.system('rm `find . | grep .so`')
   os.system('rm `find . | grep _wrap.cxx`')
   os.system('rm `find . | grep _wrap.o`')

cleanup()
basepath = os.getcwd()
rx = re.compile('#include [<|"](\S+)[>|"]')
numFiles = int(string.strip(os.popen2('find . -iname *.i | wc -l','w')[1].read()))

deps = shelve.open('.deps')
interfaceFiles = ['']*numFiles
allHeaders = []
counter = 0

for root,dirs,files in os.walk(os.getcwd()):
   for file in files:
      if file.endswith('.i'):
         relfilename = os.path.join(root,file)
         relfilename = relfilename.replace(basepath,'')
         interfaceFiles[counter] = relfilename
         deps[relfilename] = set([])
         counter += 1
      if file.endswith('.h'):
         relfilename = os.path.join(root,file)
         relfilename = relfilename.replace(basepath,'')
         allHeaders.append(relfilename)
         deps[relfilename] = set([])

def localDeps(file,filename):
   global deps
   for line in open(file):
      if line.startswith('#include'):
         currentMatch = rx.match(line,0,len(line)).group()
         if len(currentMatch.split('\"',2)) > 1:
            a,depfile,b = currentMatch.split('\"',2)
            curList = deps[filename]
            if not depfile.startswith('/'):
               depfile = '/' + depfile
            if depfile != filename:
               curList.add(depfile)
               deps[filename] = curList

visited = set([])
deplist = set([])

def getDep(filename):
   global deps
   global visited
   global deplist

   visited.add(filename)
   try:
      FILES = deps[filename]
      for actualFile in FILES:
         deplist.add(actualFile)
#         print actualFile
         if actualFile in visited:
            continue
         getDep(actualFile)
   except KeyError:
      pass

for filename in allHeaders:
   hfile = basepath + filename
   localDeps(hfile,filename)
   cppfile = hfile.replace('.h','.cpp')
   if os.path.exists(cppfile):
      localDeps(cppfile,filename)

for filename in interfaceFiles:
   dir,basename =  filename.rsplit('/',1)
   basename = basename.replace('.i','')
   objfile = basename + '.cpp.o'
   header = basename + '.h'

   deplist = set([])
   visited = set([])

   getDep(filename.replace('.i','.h'))
      
   depstring = ''
   os.chdir(basepath)
   for elem in deplist:
      elem = elem[1:].replace('.h','.cpp.o')
      if os.path.exists(elem) and not basename in elem:
         depstring += os.path.join(basepath,elem) + " "
         
   os.chdir(basepath)
   os.chdir(os.path.join(os.getcwd(),dir.replace('/','',1)))
   pydir = "/usr/include/python2.4"
   cmd1 = "swig -Wall -c++ -python -I%s %s.i" % (basepath,basename)
   cmd2 = "g++ -c -fPIC -ggdb -I%s -I%s -o %s_wrap.o %s_wrap.cxx" % (basepath,pydir,basename,basename)
   
   print cmd1
   print cmd2
   cmd3=''

   if os.path.exists(basename + '.cpp.o'):
      if basename == 'SVM_light':
         depstring += "-llapack-3 -lblas-3"
      cmd3 = "g++ -shared -ggdb %s %s.cpp.o %s_wrap.o -o _%s.so" % (depstring,basename,basename,basename)
      print cmd3

   os.system(cmd1)
   os.system(cmd2)
   os.system(cmd3)
   
   os.chdir(basepath)
