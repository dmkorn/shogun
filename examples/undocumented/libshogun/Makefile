LIB_PATH=/usr/lib
INC_PATH=/usr/include

INCLUDES=
LIBS=-lshogun -lblas

LINKFLAGS=
CXXFLAGS=-O3 -g

LIBRARY_PATH=LD_LIBRARY_PATH
LINKFLAGS+=$(LIBS) -L$(LIB_PATH) 
CXXFLAGS+=-I$(INC_PATH) $(INCLUDES)
CC=c++

TARGETS = basic_minimal classifier_libsvm classifier_minimal_svm \
		  classifier_mklmulticlass kernel_gaussian kernel_revlin \
		  library_dyn_int library_gc_array library_indirect_object \
		  library_hash parameter_set_from_parameters \
		  parameter_iterate_float64 parameter_iterate_sgobject

all: $(TARGETS)

clean:
	rm -f $(TARGETS)

$(TARGETS): $(foreach t, $(TARGET), $t.cpp)

check-examples: $(TARGETS)
	@for t in $(TARGETS) ; do echo $$t && $(LIBRARY_PATH)="$(LIB_PATH):$$$(LIBRARY_PATH)" ./$$t >/dev/null; done

%: %.cpp
	$(CC) $(CXXFLAGS) $< $(LINKFLAGS) -o $@
