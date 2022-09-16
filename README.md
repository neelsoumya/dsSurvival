# dsSurvival

[![License](https://img.shields.io/badge/license-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)

## Introduction

`dsSurvival` is a package for building survival functions for DataSHIELD (a platform for federated analysis of private data). These are server side functions for survival models, Cox proportional hazards models and Cox regression models.

A tutorial in bookdown format with executable code is available here:

https://neelsoumya.github.io/dsSurvivalbookdown/


DataSHIELD is a platform in R for federated analysis of private data. DataSHIELD has a client-server architecture and this package has a client side and server side component.

* The client side package is called `dsSurvivalClient`

    * https://github.com/neelsoumya/dsSurvivalClient

* The server side package is called `dsSurvival`

    * https://github.com/neelsoumya/dsSurvival


If you use the code, please cite the following manuscript:

Banerjee S, Sofack G, Papakonstantinou T, Avraam D, Burton P, et al. (2022), dsSurvival: Privacy preserving survival models for federated individual patient meta-analysis in DataSHIELD, bioRxiv: 2022.01.04.471418.

https://www.biorxiv.org/content/10.1101/2022.01.04.471418v2

https://doi.org/10.1101/2022.01.04.471418

https://bmcresnotes.biomedcentral.com/articles/10.1186/s13104-022-06085-1

A bibliography file is available here:

https://github.com/neelsoumya/dsSurvival/blob/main/CITATION.bib


```bibtex
@article{Banerjee2022,
author = {Banerjee, Soumya and Sofack, Ghislain and Papakonstantinou, Thodoris and Avraam, Demetris and Burton, Paul and Z{\"{o}}ller, Daniela and Bishop, Tom RP},
doi = {10.1101/2022.01.04.471418},
journal = {bioRxiv},
month = {jan},
pages = {2022.01.04.471418},
publisher = {Cold Spring Harbor Laboratory},
title = {{dsSurvival: Privacy preserving survival models for federated individual patient meta-analysis in DataSHIELD}},
year = {2022}
}
```

## Quick start

* Install R 

   https://www.r-project.org/

and R Studio 

   https://www.rstudio.com/products/rstudio/download/preview/


* Install the following packages in R:



```r 
install.packages('devtools')
library(devtools)
devtools::install_github('neelsoumya/dsSurvivalClient')
devtools::install_github('datashield/dsBaseClient@6.1.1')
install.packages('rmarkdown')
install.packages('knitr')
install.packages('tinytex')
install.packages('metafor')
install.packages('DSOpal')
install.packages('DSI')
install.packages('opalr')
```


* Follow the tutorial in bookdown format with executable code and synthetic data:

https://neelsoumya.github.io/dsSurvivalbookdown/

This uses the Opal demo server which has all server-side packages preinstalled

https://opal-sandbox.mrc-epid.cam.ac.uk/


You can also see the script `simple_script.R`

https://github.com/neelsoumya/dsSurvival/blob/main/vignettes/simple_script.R


## Installation


* Install R Studio and the development environment as described below:

    * https://data2knowledge.atlassian.net/wiki/spaces/DSDEV/pages/12943461/Getting+started


* Install the virtual machines as described below:

    * https://data2knowledge.atlassian.net/wiki/spaces/DSDEV/pages/931069953/Installation+Training+Hub-+DataSHIELD+v6

    * https://data2knowledge.atlassian.net/wiki/spaces/DSDEV/pages/1657634881/Testing+100+VM

    * https://data2knowledge.atlassian.net/wiki/spaces/DSDEV/pages/1657634898/Tutorial+6.1.0+100+VM
    
    * https://hub.docker.com/layers/rock-base/datashield/rock-base/6.2-R4.2/images/sha256-2b1ae879a4387e1dac6843ea59ac1db61816ee78467c9d30d6769a2aed330b0e?context=explore

* Install `dsBase` and `dsSurvival` on Opal server in the Virtual Machine (type neelsoumya/dsSurvival and main in the textboxes) as shown in the screenshot below

![Screenshot of installation of package in VM](https://github.com/neelsoumya/dsSurvivalClient/blob/main/project/Capture_VM_install_screenshot.PNG)

In the newer version of Opal your window may look like the screenshot below

![Screenshot in new version of Opal](newopal_screenshot.png)


See the link below on how to install a package in Opal

https://opaldoc.obiba.org/en/latest/web-user-guide/administration/datashield.html#add-package


If you have an older version of Opal, please use this version by Stuart Wheater

https://github.com/StuartWheater/dsSurvival

```r

install.packages('devtools')

library(devtools)

devtools::install_github('neelsoumya/dsBaseClient')

devtools::install_github('neelsoumya/dsSurvivalClient')

```

If you want to use a certain release then you can do the following

```r

library(devtools)

devtools::install_github('neelsoumya/dsSurvivalClient@v1.0.0')

```

If you want to try privacy preserving survival curves (available in v2.0), you can use the main branch or you can do the following

```r

library(devtools)

devtools::install_github('neelsoumya/dsSurvivalClient', ref = 'privacy_survival_curves')

```

or

```r

library(devtools)

devtools::install_github('neelsoumya/dsSurvivalClient@v2.0.0')

```

## Usage


A tutorial with executable code in bookdown format is available here: 

https://neelsoumya.github.io/dsSurvivalbookdown/



A screenshot of the meta-analyzed hazard ratios from a survival model is shown below.

![A screenshot of meta-analyzed hazard ratios from the survival model is shown below](https://github.com/neelsoumya/dsSurvivalClient/blob/main/project/screenshot_survival_models.png)

For polished publication ready plots, use the following script `forestplot_FINAL.R`

   https://github.com/neelsoumya/dsSurvival/blob/main/forestplot_FINAL.R
   

If you want to learn the basics of survival models, please see the following repository:

https://github.com/neelsoumya/survival_models


## Release notes

v1.0.0: A basic first release of survival models in DataSHIELD. This release has Cox proportional hazards models, summaries of models, diagnostics and the ability to meta-analyze hazard ratios. There is also capability to generate forest plots of meta-analyzed hazard ratios. This release supports study-level meta-analysis (SLMA).


A shiny graphical user interface for building survival models in DataSHIELD has also been created by Xavier Escriba Montagut and Juan Gonzalez. It uses dsSurvival and dsSurvivalClient.


* https://github.com/isglobal-brge/ShinyDataSHIELD

* https://isglobal-brge.github.io/ShinyDataSHIELD_bookdown/

* https://isglobal-brge.github.io/ShinyDataSHIELD_bookdown/functionalities.html#survival-analysis

* https://datashield-demo.obiba.org/


v1.0.1: Minor fixes.

v2.0.0: This has privacy preserving survival curves.

v2.1.0: This has vcov() functionality. 


## Acknowledgements

We acknowledge the help and support of the DataSHIELD technical team.
We are especially grateful to Elaine Smith, Stuart Wheater, Eleanor Hyde, Stephen Sharp, Ken Ong, Yannick Marcon, Paul Burton, Demetris Avraam, Patricia Ryser-Welch, Kevin Rue-Albrecht, Maria Jose Gomez Vazquez and Wolfgang Viechtbauer for fruitful discussions and feedback.

We thank @joerghenkebuero for suggestions about documentation, @AlanRace for a bug fix and Xavier Escriba Montagut for a fix to the plotting functionality.

## Contact

* Soumya Banerjee, Demetris Avraam, Paul Burton, Xavier Escriba Montagut, Juan Gonzalez, Tom R. P. Bishop and DataSHIELD technical team

* sb2333@cam.ac.uk

* DataSHIELD 

    * DataSHIELD is a platform that enables the non-disclosive analysis of distributed sensitive data 

    * https://www.datashield.ac.uk


## Citation

If you use the code, please cite the following manuscript:

Banerjee S, Sofack G, Papakonstantinou T, Avraam D, Burton P, et al. (2022), dsSurvival: Privacy preserving survival models for federated individual patient meta-analysis in DataSHIELD, bioRxiv: 2022.01.04.471418.

https://www.biorxiv.org/content/10.1101/2022.01.04.471418v2

https://doi.org/10.1101/2022.01.04.471418 

https://bmcresnotes.biomedcentral.com/articles/10.1186/s13104-022-06085-1

A bib file is available here:

https://github.com/neelsoumya/dsSurvival/blob/main/CITATION.bib

```bibtex
@article{Banerjee2022,
author = {Banerjee, Soumya and Sofack, Ghislain and Papakonstantinou, Thodoris and Avraam, Demetris and Burton, Paul and Z{\"{o}}ller, Daniela and Bishop, Tom RP},
doi = {10.1101/2022.01.04.471418},
journal = {bioRxiv},
month = {jan},
pages = {2022.01.04.471418},
publisher = {Cold Spring Harbor Laboratory},
title = {{dsSurvival: Privacy preserving survival models for federated individual patient meta-analysis in DataSHIELD}},
year = {2022}
}

```


<!--and the following DOI

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4917552.svg)](https://doi.org/10.5281/zenodo.4917552)



or see the CITATION.cff file created using

https://citation-file-format.github.io/cff-initializer-javascript/

-->

