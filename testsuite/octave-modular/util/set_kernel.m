function y = set_kernel()
	global kernel_name;
	global name;
	global feats_train;
	global kern;
	global kernel_arg0_size;
	global kernel_arg1_size;
	y=false;

	if !isempty(kernel_arg0_size)
		size_cache=kernel_arg0_size;
	elseif !isempty(kernel_arg1_size)
		size_cache=kernel_arg1_size;
	else
		size_cache=10;
	end

	if isempty(kernel_name)
		kname=name;
	else
		kname=kernel_name;
	end

	% this sux awfully, but dunno how to do it differently here :(
	if strcmp(kname, 'AUC')==1
		disp('not implemented yet'); return;

	elseif strcmp(kname, 'Chi2')==1
		global Chi2Kernel;
		global kernel_arg0_width;
		kern=Chi2Kernel(feats_train, feats_train,
			kernel_arg0_width, size_cache);

	elseif strcmp(kname, 'Combined')
		disp('not implemented yet'); return;
		% this will break when test file is changed!
		global CombinedKernel;
		global subkernel0_name;
		global subkernel0_feature_type;
		global subkernel0_kernel_arg0_size;
		global subkernel0_kernel_arg1_degree;
		global subkernel1_name;
		global subkernel1_feature_type;
		global subkernel1_kernel_arg0_size;
		global subkernel1_kernel_arg1_degree;
		global subkernel1_kernel_arg2_inhomogene;
		global subkernel2_name;
		global subkernel2_feature_type;
		global subkernel2_kernel_arg0_size;

		sg('set_kernel', 'COMBINED', size_cache);

		subkernel_name=fix_kernel_name_inconsistency(subkernel0_name);
		sg('add_kernel', 1., subkernel_name, toupper(subkernel0_feature_type),
			str2num(subkernel0_kernel_arg0_size), subkernel0_kernel_arg1_degree);

		subkernel_name=fix_kernel_name_inconsistency(subkernel1_name);
		sg('add_kernel', 1., subkernel_name, toupper(subkernel1_feature_type),
			str2num(subkernel1_kernel_arg0_size), subkernel1_kernel_arg1_degree,
			tobool(subkernel1_kernel_arg2_inhomogene));

		subkernel_name=fix_kernel_name_inconsistency(subkernel2_name);
		sg('add_kernel', 1., subkernel_name, toupper(subkernel2_feature_type),
			str2num(subkernel2_kernel_arg0_size));

	elseif strcmp(kname, 'CommUlongString')==1
		global CommUlongStringKernel;
		global kernel_arg0_use_sign;
		global kernel_arg1_normalization;
		kern=CommUlongStringKernel(feats_train, feats_train,
			tobool(kernel_arg0_use_sign), kernel_arg1_normalization);

	elseif strcmp(kname, 'CommWordString')==1
		global CommWordStringKernel;
		global kernel_arg0_use_sign;
		global kernel_arg1_normalization;
		kern=CommWordStringKernel(feats_train, feats_train,
			tobool(kernel_arg0_use_sign), kernel_arg1_normalization);

	elseif strcmp(kname, 'Const')==1
		global ConstKernel;
		global kernel_arg0_c;
		kern=ConstKernel(feats_train, feats_train, kernel_arg0_c);

	elseif strcmp(kname, 'Custom')==1
		global CustomKernel;
		disp('not implemented yet'); return;

	elseif strcmp(kname, 'Diag')==1
		global DiagKernel;
		global kernel_arg0_diag;
		kern=DiagKernel(feats_train, feats_train, kernel_arg0_diag);

	elseif strcmp(kname, 'Distance')==1
		global DistanceKernel;
		global kernel_arg0_width;
		global distance;
		if !set_and_train_distance()
			y=false;
			return;
		end
		kern=DistanceKernel(feats_train, feats_train,
			kernel_arg0_width, distance);

	elseif strcmp(kname, 'FixedDegreeString')==1
		global FixedDegreeStringKernel;
		global kernel_arg0_degree;
		kern=FixedDegreeStringKernel(feats_train, feats_train,
			kernel_arg0_degree);

	elseif strcmp(kname, 'GaussianShift')==1
		global GaussianShiftKernel;
		global kernel_arg0_width;
		global kernel_arg1_max_shift;
		global kernel_arg2_shift_step;
		kern=GaussianShiftKernel(feats_train, feats_train,
			kernel_arg0_width, kernel_arg1_max_shift, kernel_arg2_shift_step);

	elseif strcmp(kname, 'Gaussian')==1
		global GaussianKernel;
		global kernel_arg0_width;
		kern=GaussianKernel(feats_train, feats_train,
			kernel_arg0_width);

	elseif strcmp(kname, 'HistogramWord')==1
		global HistogramWordKernel;
		global pie;
		if !set_pie()
			return;
		end
		kern=HistogramWordKernel(feats_train, feats_train, pie);

	elseif strcmp(kname, 'LinearByte')==1
		global LinearByteKernel;
		disp('not implemented yet'); return;

	elseif strcmp(kname, 'LinearString')==1
		global LinearStringKernel;
		kern=LinearStringKernel(feats_train, feats_train);

	elseif strcmp(kname, 'LinearWord')==1
		global LinearWordKernel;
		kern=LinearWordKernel(feats_train, feats_train);

	elseif strcmp(kname, 'Linear')==1
		global LinearKernel;
		global kernel_arg0_scale;
		kern=LinearKernel(feats_train, feats_train,
			kernel_arg0_scale);

	elseif strcmp(kname, 'LocalAlignmentString')==1
		global LocalAlignmentStringKernel;
		kern=LocalAlignmentStringKernel(feats_train, feats_train);

	elseif strcmp(kname, 'PolyMatchString')==1
		global PolyMatchStringKernel;
		global kernel_arg0_degree;
		global kernel_arg1_inhomogene;
		kern=PolyMatchStringKernel(feats_train, feats_train,
			kernel_arg0_degree, tobool(kernel_arg1_inhomogene));

	elseif strcmp(kname, 'PolyMatchWord')==1
		global PolyMatchWordKernel;
		global kernel_arg0_degree;
		global kernel_arg1_inhomogene;
		kern=PolyMatchWordKernel(feats_train, feats_train,
			kernel_arg0_degree, tobool(kernel_arg1_inhomogene));

	elseif strcmp(kname, 'Poly')==1
		global PolyKernel;
		global kernel_arg0_degree;
		global kernel_arg1_inhomogene;
		global kernel_arg2_use_normalization;
		kern=PolyKernel(feats_train, feats_train,
			kernel_arg0_degree, tobool(kernel_arg1_inhomogene),
			tobool(kernel_arg2_use_normalization));

	elseif strcmp(kname, 'SalzbergWord')==1
		global SalzbergWordKernel;
		global pie;
		if !set_pie()
			return;
		end
		kern=SalzbergWordKernel(feats_train, feats_train, pie);

	elseif strcmp(kname, 'Sigmoid')==1
		global SigmoidKernel;
		global kernel_arg1_gamma_;
		global kernel_arg2_coef0;
		kern=SigmoidKernel(feats_train, feats_train, size_cache,
			kernel_arg1_gamma_, kernel_arg2_coef0);

	elseif strcmp(kname, 'SimpleLocalityImprovedString')==1
		global SimpleLocalityImprovedStringKernel;
		global kernel_arg0_length;
		global kernel_arg1_inner_degree;
		global kernel_arg2_outer_degree;
		kern=SimpleLocalityImprovedStringKernel(feats_train, feats_train,
			kernel_arg0_length, kernel_arg1_inner_degree,
			kernel_arg2_outer_degree);

	elseif strcmp(kname, 'SparseGaussian')==1
		global SparseGaussianKernel;
		global kernel_arg0_width;
		kern=SparseGaussianKernel(feats_train, feats_train,
			kernel_arg0_width);

	elseif strcmp(kname, 'SparseLinear')==1
		SparseLinearKernel;
		global kernel_arg0_scale;
		kern=SparseLinearKernel(feats_train, feats_train,
			kernel_arg0_scale);

	elseif strcmp(kname, 'SparsePoly')==1
		global SparsePolyKernel;
		global kernel_arg0_degree;
		global kernel_arg1_inhomogene;
		global kernel_arg2_use_normalization;
		kern=SparsePolyKernel(feats_train, feats_train,
			kernel_arg0_degree, tobool(kernel_arg1_inhomogene),
			tobool(kernel_arg2_use_normalization));

	elseif strcmp(kname, 'WeightedCommWordString')==1
		global WeightedCommWordStringKernel;
		global kernel_arg0_use_sign;
		global kernel_arg1_normalization;
		kern=WeightedCommWordStringKernel(feats_train, feats_train,
			tobool(kernel_arg0_use_sign), kernel_arg1_normalization);

	elseif strcmp(kname, 'WeightedDegreePositionString')==1
		global WeightedDegreePositionStringKernel;
		global kernel_arg0_degree;
		kern=WeightedDegreePositionStringKernel(feats_train, feats_train,
			kernel_arg0_degree);

	elseif strcmp(kname, 'WeightedDegreeString')==1
		global WeightedDegreeStringKernel;
		global kernel_arg0_degree;
		kern=WeightedDegreeStringKernel(feats_train, feats_train,
			kernel_arg0_degree);

	elseif strcmp(kname, 'WordMatch')==1
		global WordMatchKernel;
		global kernel_arg0_degree;
		kern=WordMatchKernel(feats_train, feats_train,
			kernel_arg0_degree);

	else
		error('Unsupported kernel %s!', kname);
	end

	y=true;