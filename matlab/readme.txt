  
    **************************************************************
    **quantreg: Quantile Regression for Large-scale Applications**
    ************************************************************** 

Version: 1.0
Author: Jiyan Yang
Published: Sep. 23, 2013
----------------------------------------

About:
It is a collection of codes that generate various experiments in large-scale quantile regression.
----------------------------------------

Structure:
/testing: it contains all the codes for making experiments.
/conditioning: it contains codes for doing various conditioning.
/core: it contains all the core codes such as quantile regression solver and data generator.
/data: it contains census dataset.
----------------------------------------

Usage:
1. The only codes needed to be modified are compute_err_X.m located in the testing folder, where X can be s, d, n or tau. Each of these codes will generate experiment investigating the performance of the algorithm when X changes.

2. In each compute_err_X.m, there is a block where user can specify the parameters. In particular, "dir" is a directory where the resulting files will be stored and "order" represents the order of the current experiment. For example, if dir = '~/quantreg/empirical_results/testing/' and order = 1, then the all the data and plots will be stored in folder "~/quantreg/empirical_results/testing/err_X_results1".

3. The following table summarizes the types of parameters in each codes.
    compute_err_X   x-axis   legend    files     fixed
         s             s     methods   tau       n,d
         n             n        s      tau       method,d
         d             d        s      tau       method,n
        tau           tau       s      methods   n,d

  Here, within each plot, different curve will be corresponding to each "legend" variable. Each plot corresponds to a fixed "files" variable. For each plot, y-axis can be 4 possibilities: relative error on objective value or realative error on solution vector measure in l2, l1 or infinity norms, which are stored in 4 different plots. The code will generate 4 * (# of "files" variables) plots.

4. All the numerical results and settings will be saved into a mat file stored in the directory described above. 

----------------------------------------

Datasets:
1. Synthetic data with iid Gaussians.
2. Synthetic skewed dataset.
3. Census data.
----------------------------------------

Reference:
J. Yang, X. Meng, and M. W. Mahoney. Quantile regression for large-scale applications. Technical report. Preprint: arXiv:1305.0087 (2013)

