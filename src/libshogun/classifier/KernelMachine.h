/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Written (W) 1999-2009 Soeren Sonnenburg
 * Copyright (C) 1999-2009 Fraunhofer Institute FIRST and Max-Planck-Society
 */

#ifndef _KERNEL_MACHINE_H__
#define _KERNEL_MACHINE_H__

#include "lib/common.h"
#include "lib/io.h"
#include "kernel/Kernel.h"
#include "features/Labels.h"
#include "classifier/Classifier.h"

#include <stdio.h>

namespace shogun
{
class CClassifier;
class CLabels;
class CKernel;

/** @brief A generic KernelMachine interface.
 *
 * A kernel machine is defined as
 *  \f[
 * 		f({\bf x})=\sum_{i=0}^{N-1} \alpha_i k({\bf x}, {\bf x_i})+b
 * 	\f]
 *
 * where \f$N\f$ is the number of training examples
 * \f$\alpha_i\f$ are the weights assigned to each training example
 * \f$k(x,x')\f$ is the kernel
 * and \f$b\f$ the bias.
 *
 * Using an a-priori choosen kernel, the \f$\alpha_i\f$ and bias are determined
 * in a training procedure.
 */
class CKernelMachine : public CClassifier
{
	public:
		/** default constructor */
		CKernelMachine();

		/** destructor */
		virtual ~CKernelMachine();

		/** Returns the name of the SGSerializable instance.  It MUST BE
		 *  the CLASS NAME without the prefixed `C'.
		 *
		 * @return name of the SGSerializable
		 */
		virtual const char* get_name(void) const {
			return "KernelMachine"; }

		/** set kernel
		 *
		 * @param k kernel
		 */
		inline void set_kernel(CKernel* k)
		{
			SG_UNREF(kernel);
			SG_REF(k);
			kernel=k;
		}

		/** get kernel
		 *
		 * @return kernel
		 */
		inline CKernel* get_kernel()
		{
			SG_REF(kernel);
			return kernel;
		}

		/** set batch computation enabled
		 *
		 * @param enable if batch computation shall be enabled
		 */
		inline void set_batch_computation_enabled(bool enable)
		{
			use_batch_computation=enable;
		}

		/** check if batch computation is enabled
		 *
		 * @return if batch computation is enabled
		 */
		inline bool get_batch_computation_enabled()
		{
			return use_batch_computation;
		}

		/** set linadd enabled
		 *
		 * @param enable if linadd shall be enabled
		 */
		inline void set_linadd_enabled(bool enable)
		{
			use_linadd=enable;
		}

		/** check if linadd is enabled
		 *
		 * @return if linadd is enabled
		 */
		inline bool get_linadd_enabled()
		{
			return use_linadd ;
		}

		/** set state of bias
		 *
		 * @param enable_bias if bias shall be enabled
		 */
		inline void set_bias_enabled(bool enable_bias) { use_bias=enable_bias; }

		/** get state of bias
		 *
		 * @return state of bias
		 */
		inline bool get_bias_enabled() { return use_bias; }

		/** get bias
		 *
		 * @return bias
		 */
		inline float64_t get_bias()
		{
			return m_bias;
		}

		/** set bias to given value
		 *
		 * @param bias new bias
		 */
		inline void set_bias(float64_t bias)
		{
			m_bias=bias;
		}

		/** get support vector at given index
		 *
		 * @param idx index of support vector
		 * @return support vector
		 */
		inline int32_t get_support_vector(int32_t idx)
		{
			ASSERT(m_svs && idx<num_svs);
			return m_svs[idx];
		}

		/** get alpha at given index
		 *
		 * @param idx index of alpha
		 * @return alpha
		 */
		inline float64_t get_alpha(int32_t idx)
		{
			ASSERT(m_alpha && idx<num_svs);
			return m_alpha[idx];
		}

		/** set support vector at given index to given value
		 *
		 * @param idx index of support vector
		 * @param val new value of support vector
		 * @return if operation was successful
		 */
		inline bool set_support_vector(int32_t idx, int32_t val)
		{
			if (m_svs && idx<num_svs)
				m_svs[idx]=val;
			else
				return false;

			return true;
		}

		/** set alpha at given index to given value
		 *
		 * @param idx index of alpha vector
		 * @param val new value of alpha vector
		 * @return if operation was successful
		 */
		inline bool set_alpha(int32_t idx, float64_t val)
		{
			if (m_alpha && idx<num_svs)
				m_alpha[idx]=val;
			else
				return false;

			return true;
		}

		/** get number of support vectors
		 *
		 * @return number of support vectors
		 */
		inline int32_t get_num_support_vectors()
		{
			return num_svs;
		}

		/** set alphas to given values
		 *
		 * @param alphas array with all alphas to set
		 * @param d number of alphas (== number of support vectors)
		 */
		void set_alphas(float64_t* alphas, int32_t d)
		{
			ASSERT(alphas);
			ASSERT(m_alpha);
			ASSERT(d==num_svs);

			for(int32_t i=0; i<d; i++)
				m_alpha[i]=alphas[i];
		}

		/** set support vectors to given values
		 *
		 * @param svs array with all support vectors to set
		 * @param d number of support vectors
		 */
		void set_support_vectors(int32_t* svs, int32_t d)
		{
			ASSERT(m_svs);
			ASSERT(svs);
			ASSERT(d==num_svs);

			for(int32_t i=0; i<d; i++)
				m_svs[i]=svs[i];
		}

		/** get all support vectors (swig compatible)
		 *
		 * @param svs array to contain a copy of the support vectors
		 * @param num number of support vectors in the array
		 */
		void get_support_vectors(int32_t** svs, int32_t* num)
		{
			int32_t nsv = get_num_support_vectors();

			ASSERT(svs && num);
			*svs=NULL;
			*num=nsv;

			if (nsv>0)
			{
				*svs = (int32_t*) SG_MALLOC(sizeof(int32_t)*nsv);
				for(int32_t i=0; i<nsv; i++)
					(*svs)[i] = get_support_vector(i);
			}
		}

		/** get all alphas (swig compatible)
		 *
		 * @param alphas array to contain a copy of the alphas
		 * @param d1 number of alphas in the array
		 */
		void get_alphas(float64_t** alphas, int32_t* d1)
		{
			int32_t nsv = get_num_support_vectors();

			ASSERT(alphas && d1);
			*alphas=NULL;
			*d1=nsv;

			if (nsv>0)
			{
				*alphas = (float64_t*) SG_MALLOC(nsv*sizeof(float64_t));
				for(int32_t i=0; i<nsv; i++)
					(*alphas)[i] = get_alpha(i);
			}
		}

		/** create new model
		 *
		 * @param num number of alphas and support vectors in new model
		 */
		inline bool create_new_model(int32_t num)
		{
			delete[] m_alpha;
			delete[] m_svs;

			m_bias=0;
			num_svs=num;

			if (num>0)
			{
				m_alpha= new float64_t[num];
				m_svs= new int32_t[num];
				return (m_alpha!=NULL && m_svs!=NULL);
			}
			else
			{
				m_alpha= NULL;
				m_svs=NULL;
				return true;
			}
		}

		/** initialise kernel optimisation
		 *
		 * @return if operation was successful
		 */
		bool init_kernel_optimization();

		/** classify kernel machine
		 *
		 * @return result labels
		 */
		virtual CLabels* classify();

		/** classify objects
		 *
		 * @param data (test)data to be classified
		 * @return classified labels
		 */
		virtual CLabels* classify(CFeatures* data);

		/** classify one example
		 *
		 * @param num which example to classify
		 * @return classified value
		 */
		virtual float64_t classify_example(int32_t num);

		/** classify example helper, used in threads
		 *
		 * @param p params of the thread
		 * @return nothing really
		 */
		static void* classify_example_helper(void* p);

	protected:
		/** kernel */
		CKernel* kernel;
		/** if batch computation is enabled */
		bool use_batch_computation;
		/** if linadd is enabled */
		bool use_linadd;
		/** if bias shall be used */
		bool use_bias;
		/**  bias term b */
		float64_t m_bias;
		/** array of coefficients alpha */
		float64_t* m_alpha;
		/** array of ``support vectors'' */
		int32_t* m_svs;
		/** number of ``support vectors'' */
		int32_t num_svs;
};
}
#endif /* _KERNEL_MACHINE_H__ */
