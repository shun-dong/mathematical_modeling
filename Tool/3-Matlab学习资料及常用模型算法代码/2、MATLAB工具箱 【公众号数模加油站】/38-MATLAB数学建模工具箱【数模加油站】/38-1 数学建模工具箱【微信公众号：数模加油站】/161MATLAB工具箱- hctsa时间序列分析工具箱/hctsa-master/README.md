# *hctsa*, highly comparative time-series analysis

*hctsa* is a software package for running highly comparative time-series analysis using [Matlab](www.mathworks.com/products/matlab/) (full support for versions R2014b or later; for use in python cf. [pyopy](https://github.com/strawlab/pyopy)).

The software provides a code framework that allows thousands of time-series analysis features to be extracted from time series (or a time-series dataset), as well as tools for normalizing and clustering the data, producing low-dimensional representations of the data, identifying discriminating features between different classes of time series, learning multivariate classification models using large sets of time-series features, finding nearest matches to a time series of interest, and a range of other visualizations and analyses.

**Feel free to [email me](mailto:ben.d.fulcher@gmail.com) for help with real-world applications of _hctsa_** :nerd_face:

If you use this software, please read and cite these open-access articles:

* B.D. Fulcher and N.S. Jones. [_hctsa_: A computational framework for automated time-series phenotyping using massive feature extraction](http://www.cell.com/cell-systems/fulltext/S2405-4712\(17\)30438-6). *Cell Systems* **5**, 527 (2017).
* B.D. Fulcher, M.A. Little, N.S. Jones. [Highly comparative time-series analysis: the empirical structure of time series and their methods](http://rsif.royalsocietypublishing.org/content/10/83/20130048.full). *J. Roy. Soc. Interface* **10**, 83 (2013).

Feedback, as [email](mailto:ben.d.fulcher@gmail.com), [github issues](https://github.com/benfulcher/hctsa/issues) or [pull requests](https://help.github.com/articles/using-pull-requests/), is much appreciated.

**For commercial use of *hctsa*, including licensing and consulting, contact [Engine Analytics](http://www.engineanalytics.org/).**

### Getting started
&#x1F4D6; &#x1F4D6;
Comprehensive documentation
&#x1F4D6; &#x1F4D6;
for *hctsa* is on [gitbook](https://hctsa-users.gitbook.io/hctsa-manual).

### Downloading the repository

For users unfamiliar with git, the current version of the repository can be downloaded by simply clicking the green _Clone or download_ button, and then clicking _Download .zip_.

It is recommended to use the repository with git.
For this, please [make a fork](https://help.github.com/articles/fork-a-repo/) of it, clone it to your local machine, and then set an [upstream remote](https://help.github.com/articles/fork-a-repo/#step-3-configure-git-to-sync-your-fork-with-the-original-spoon-knife-repository) to keep it synchronized with the main repository e.g., using the following code:
```
git remote add upstream git://github.com/benfulcher/hctsa.git
```
(make sure that you have [generated an ssh key](https://help.github.com/articles/generating-ssh-keys/) and associated it with your Github account).

You can then update to the latest stable version of the repository by pulling the master branch to your local repository:
```
git pull upstream master
```

For analyzing specific datasets, we recommend working outside of the repository so that incremental updates can be pulled from the upstream repository.
Details on how to merge the latest version of the repository with the local changes in your fork can be found [here](https://help.github.com/articles/syncing-a-fork/).

## *hctsa* licenses

### Internal licenses

There are two licenses applied to the core parts of the repository:

1. The framework for running *hctsa* analyses and visualizations is licensed as the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).
A license for commercial use is available from [Engine Analytics](http://www.engineanalytics.org/).

2. Code for computing features from time-series data is licensed as [GNU General Public License version 3](http://www.gnu.org/licenses/gpl-3.0.en.html).

A range of external code packages are provided in the **Toolboxes** directory of the repository, and each have their own associated license (as outlined below).

### External packages and dependencies

The following [Matlab toolboxes](https://mathworks.com/programs/nrd/matlab-toolbox-price-request.html?ref=ggl&s_eid=ppc_18665571802&q=matlab%20toolboxes%20price) are used by *hctsa* and are required for full functionality of the software.
In the case that some toolboxes are unavailable, the *hctsa* software can still be used, but only a reduced set of time-series features will be computed.

1. Statistics Toolbox
2. Signal Processing Toolbox
3. Curve Fitting Toolbox
4. System Identification Toolbox
5. Wavelet Toolbox
6. Econometrics Toolbox

---

The following time-series analysis packages are provided with the software (in the **Toolboxes** directory), and are used by our main feature extraction algorithms to compute meaningful structural features from time series:

* [*TISEAN* package for nonlinear time-series analysis, version 3.0.1](http://www.mpipks-dresden.mpg.de/~tisean/Tisean_3.0.1/index.html) (GPL license).
* [*TSTOOL* package for nonlinear time-series analysis, version 1.2](http://www.dpi.physik.uni-goettingen.de/tstool/) (GPL license).
* Joseph T. Lizier's [Java Information Dynamics Toolkit (JIDT)](https://github.com/jlizier/jidt) for studying information-theoretic measures of computation in complex systems, version 1.3 (GPL license).
* Time-series analysis code developed by [Michael Small](http://staffhome.ecm.uwa.edu.au/~00027830/code.html) (unlicensed).
* Max Little's [Time-series analysis code](http://www.maxlittle.net/software/index.php) (GPL license).
* Sample Entropy code from [Physionet](http://www.physionet.org/faq.shtml#license) (GPL license).
* [*ARFIT* Toolbox for AR model estimation](http://climate-dynamics.org/software/#arfit) (unlicensed).
* [*gpml* Toolbox for Gaussian Process regression model estimation, version 3.5](http://www.gaussianprocess.org/gpml/code/matlab/doc/) (FreeBSD license).
* Danilo P. Mandic's [delay vector variance code](http://www.commsp.ee.ic.ac.uk/~mandic/dvv.htm) (GPL license).
* [Cross Recurrence Plot Toolbox](http://tocsy.pik-potsdam.de/CRPtoolbox/) (GPL license)
* Zoubin Ghahramani's [Hidden Markov Model (HMM) code](http://mlg.eng.cam.ac.uk/zoubin/software.html) (MIT license).
* Danny Kaplan's Code for embedding statistics (GPL license).
* Two-dimensional histogram code from Matlab Central (BSD license).
* Various histogram and entropy code by Rudy Moddemeijer (unlicensed).

## Publications

### Our publications

See the following publications for details of *hctsa* was developed and has since been extended, as well as some example applications:
* ***Feature-based time-series analysis for a self-organizing living library of time-series data, [CompEngine](https://www.comp-engine.org/)*** &#x1F4D7; : B.D. Fulcher, C.H. Lubba, S.S. Sethi & N.S. Jones. _CompEngine_: A self-organizing, living library of time-series data. *arXiv* (2019). [Link](https://arxiv.org/abs/1905.01042v1).
* ***A reduced set of 22 efficiently coded features*** &#x1F4D7; : C.H. Lubba, S.S. Sethi, P. Knaute, S.R. Schultz, B.D. Fulcher & N.S. Jones. _catch22_: CAnonical Time-series CHaracteristics. *arXiv* (2019). [Link](https://arxiv.org/abs/1901.10200v2).
* ***Implementation paper introducing the _hctsa_ package, with applications to high throughput phenotyping of _C. Elegans_ and Drosophila movement time series*** &#x1F4D7; : B.D. Fulcher & N.S. Jones. _hctsa_: A Computational Framework for Automated Time-Series Phenotyping Using Massive Feature Extraction. *Cell Systems* **5**, 527 (2017). [Link](http://www.cell.com/cell-systems/fulltext/S2405-4712\(17\)30438-6).
* ***Introduction to feature-based time-series analysis*** &#x1F4D7; : B.D. Fulcher. Feature-based time-series analysis. *Feature Engineering for Machine Learning and Data Analytics*, CRC Press, 87-116 (2018).  [Link](https://www.crcpress.com/Feature-Engineering-for-Machine-Learning-and-Data-Analytics/Dong-Liu/p/book/9781138744387), [Preprint](https://arxiv.org/abs/1709.08055).
* ***Application to fMRI data*** &#x1F4D7; : S.S. Sethi, V. Zerbi, N. Wenderoth, A. Fornito, B.D. Fulcher. Structural connectome topology relates to regional BOLD signal dynamics in the mouse brain. *Chaos* **27**, 047405 (2017). [Link](http://aip.scitation.org/doi/10.1063/1.4979281), [preprint](http://biorxiv.org/lookup/doi/10.1101/085514).
* ***Application to time-series data mining*** &#x1F4D7; : B.D. Fulcher & N.S. Jones. Highly comparative feature-based time-series classification. *IEEE Trans. Knowl. Data Eng.* **26**, 3026 (2014). [Link](http://ieeexplore.ieee.org/lpdocs/epic03/wrapper.htm?arnumber=6786425).
* ***Application to fetal heart rate time series*** &#x1F4D7; : B.D. Fulcher, A.E. Georgieva, C.W.G. Redman, N.S. Jones. Highly comparative fetal heart rate analysis. *34th Ann. Int. Conf. IEEE EMBC* 3135 (2012). [Link](http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=6346629).
* ***Original paper, showing that the behavior of thousands of time-series methods on thousands of different time series can provide structure to the interdisciplinary time-series analysis literature*** &#x1F4D7; : B.D. Fulcher, M.A. Little, N.S. Jones. Highly comparative time-series analysis: the empirical structure of time series and their methods. *J. Roy. Soc. Interface* **10**, 20130048 (2013). [Link](http://rsif.royalsocietypublishing.org/content/10/83/20130048.full).

### Other Publications

Here are some examples of external use of _hctsa_.
Let me know if I've missed any!

* Feature selection using genetic algorithms for fetal heart rate analysis. [Paper](http://iopscience.iop.org/article/10.1088/0967-3334/35/7/1357/meta)
* Evaluating asphalt irregularity from smartphone sensors. [Paper](https://link.springer.com/chapter/10.1007/978-3-319-68765-0_27)
* Assessing muscles for clinical rehabilitation. [Paper](https://ieeexplore.ieee.org/abstract/document/8037372/)
* Detecting mild cognitive impairment using single-channel EEG to measure speech-evoked brain responses. [Paper](https://ieeexplore.ieee.org/abstract/document/8693868)
* Non-intrusive load monitoring for appliance detection and electrical power saving for buildings. [Paper](https://doi.org/10.1016/j.enbuild.2019.05.028).
* Classification of heartbeats measured using single-lead ECG. [Paper](https://ieeexplore.ieee.org/abstract/document/8757135).


## Acknowledgements

Many thanks go to [Romesh Abeysuriya](https://github.com/RomeshA) for helping with the mySQL database set-up and install scripts, and [Santi Villalba](https://github.com/sdvillal) for lots of helpful feedback and advice on the software.

## Related resources

### CompEngine

An accompanying web resource for this project is [CompEngine](http://www.comp-engine.org), which allows users to upload and compare thousands of diverse types of time-series data.
The vast and growing collection of time-series data can also be downloaded.

### _catch22_

Is over 7000 just a few too many features for your application?
Do you not have access to a Matlab license?
_catch22_ has you all of your faux rhetorical questions covered.
This reduced set of 22 features, determined through a combination of classification performance and mutual redundancy as explained in [this paper](https://arxiv.org/abs/1901.10200v2), is available [here](https://github.com/chlubba/catch22) as an efficiently coded C implementation with wrappers for python and R.

### _hctsa_ datasets
There are a range of open datasets with pre-computed _hctsa_ features.
(If you have data to share and host, let me know and I'll add it to this list):
* [1000 empirical time series](https://figshare.com/articles/1000_Empirical_Time_series/5436136)
* [_C. elegans_ movement speed data](https://figshare.com/articles/Highly_comparative_time-series_analysis_of_Caenorhabditis_elegans_movement_speed/3863559) and associated [analysis code](https://github.com/benfulcher/hctsa_phenotypingWorm).
* [Drosophila movement speed](https://figshare.com/articles/Highly_comparative_time-series_analysis_of_Drosophila_melanogaster_movement_speed/3863553) and associated [analysis code](https://github.com/benfulcher/hctsa_phenotypingFly).

### Code for distributing _hctsa_ calculations on a cluster

Matlab code for computing features for an initialized `HCTSA.mat` file, by distributing the computation across a large number of cluster jobs (using pbs or slurm schedulers) is [here](https://github.com/benfulcher/distributed_hctsa).

### `pyopy`

This excellent repository allows users to run *hctsa* software from within python: [pyopy](https://github.com/strawlab/pyopy).

### `hctsaAnalysisPython`
Some beginner-level python code for analyzing the results of _hctsa_ calculations is [here](https://github.com/benfulcher/hctsaAnalysisPython).

### Generating time-series data from synthetic models

A Matlab repository for generating time-series data from diverse model systems is [here](https://github.com/benfulcher/TimeSeriesGeneration).

### `tsfresh`

Native python time-series code to extract hundreds of time-series features, with in-built feature filtering, is [tsfresh](https://github.com/blue-yonder/tsfresh); cf. [their paper](https://www.sciencedirect.com/science/article/pii/S0925231218304843).

### `tscompdata` and `tsfeatures`

These R packages are by [Rob Hyndman](https://twitter.com/robjhyndman).
The first, [`tscompdata`](https://github.com/robjhyndman/tscompdata), makes available existing collections of time-series data for analysis.
The second, [`tsfeatures`](https://github.com/robjhyndman/tsfeatures), includes implementations of a range of time-series features.

### `Khiva`
[Khiva](https://github.com/shapelets/khiva) is an open-source library of efficient algorithms to analyse time series in GPU and CPU.

### `pyunicorn`

A python-based nonlinear time-series analysis and complex systems code package, [pyunicorn](http://scitation.aip.org/content/aip/journal/chaos/25/11/10.1063/1.4934554).
