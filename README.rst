msPurity for Galaxy
========================
|Build Status (Travis)| |Git| |Bioconda| |License|


Version v1.12.2+galaxy2
------

  - msPurity
     - bioconductor-mspurity v1.12.2
  - Galaxy tools
     - v2

About
------
Galaxy tools for the Bioconductor R package msPurity. Tools available for assessing precursor ion purity of
LC-MS/MS or DI-M/MS data that has been acquired. And tools are available to assess LC-MS or DI-MS for
anticipated precursor ion purity to guide a later fragmentation experiment.

Additional, tools available to perform LC-MS/MS spectral matching.

Associated paper `msPurity: Automated Evaluation of Precursor Ion Purity for Mass Spectrometry Based Fragmentation in Metabolomics. Analytical Chemistry <http://pubs.acs.org/doi/abs/10.1021/acs.analchem.6b04358>`_

Use the following links for more details of the msPurity R package:

* Bioconductor: http://bioconductor.org/packages/msPurity/
* Vignette: https://bioconductor.org/packages/devel/bioc/vignettes/msPurity/inst/doc/msPurity-vignette.html
* Manual: http://bioconductor.org/packages/devel/bioc/manuals/msPurity/man/msPurity.pdf
* Bioconductor mirror code: https://github.com/Bioconductor-mirror/msPurity
* Github code: https://github.com/computational-metabolomics/mspurity
* Bioconda (stable): https://anaconda.org/bioconda/bioconductor-mspurity
* Conda (dev and testing): https://anaconda.org/tomnl/bioconductor-mspurity




Dependencies
------
Dependencies for these Galaxy tools should be handled by CONDA. The most recent version of the msPurity R package can found on channel  `tomnl <https://anaconda.org/tomnl/bioconductor-mspurity>`_ on `anaconda <https://anaconda.org/tomnl/bioconductor-mspurity>`_. Warning this will be a different version of the package compared to the BICONDA bioconductor-mspurity.


Galaxy
------
`Galaxy <https://galaxyproject.org>`_ is an open, web-based platform for data intensive biomedical research. Whether on the free public server or your own instance, you can perform, reproduce, and share complete analyses.


Authors, contributors & contacts
-------------------------

- Thomas N. Lawson (t.n.lawson@bham.ac.uk) - `University of Birmingham (UK) <http://www.birmingham.ac.uk/index.aspx>`_
- Ralf J. M. Weber (r.j.weber@bham.ac.uk) - `University of Birmingham (UK) <http://www.birmingham.ac.uk/index.aspx>`_
- Jordi Capellades (j.capellades.to@gmail.com) - `Universitat Rovira i Virgili (SP)  <http://www.urv.cat/en/>`_
- Julien Saint-Vanne (jsaintvanne) - `ABiMS (France) <http://abims.sb-roscoff.fr/>`_
- Simon Bray (sbray@informatik.uni-freiburg.de) - `University of Freiburg (Germany) <https://www.uni-freiburg.de/>`_

Changes
-------------------------
v1.12.2-galaxy2
  - Bug fix for using custom library sqlite database from Galaxy UI
  - Bug fix for "allfrag" for createDatabase


v1.12.2-galaxy1
  - grpPeaklist reference incorrect in createDatabase.xml
  - Add custom adduct handling for createMSP
  - Change output of flagRemove to tabular


v1.12.2-galaxy0
  - Update to version v1.12.2 of `msPurity <https://github.com/computational-metabolomics/msPurity/pull/71>`_
  - Optional summary output for combineAnnotations (for very large output)
  - Extra column added to flagRemove output
  - Hide probmetab input 
  - Make dimsPredictPuritySingle more compatible with "simple workflow inputs"


v1.12.1-galaxy0
  - Update to version v1.12.1 of `msPurity <https://github.com/computational-metabolomics/msPurity/pull/71>`_

v1.12.0-galaxy1
  - Bug fix (offsets were not being automatically selected for purityA) thanks jsaintvanne
  - Exit script without error for flagRemove
  - Username updated in Toolshed yaml

v1.12.0-galaxy0
  - Updates for Bioconductor stable msPurity v1.12.0 release 
  - Additional columns added for spectral matching (for msnpy use case)
  - Merge of v1.11.4-galaxy1

v1.11.4-galaxy1
  - Not submitted to toolshed
  - Update to follow IUC guidelines for Galaxy tool development

v1.11.4-galaxy0.2.7
  - submitted to test toolshed (20190927)
  - Bug fix for spectralMatching choice of instrument types

v1.11.4-galaxy0.2.6:
  - submitted to test toolshed (20190924)
  - Bug fix for createAnnotation database local path
  - Update of instrument types for spectral matching
  - Update of split_msp tool to handle different MSP types


v1.11.4-galaxy0.2.5:
  - submitted to test toolshed (20190913)
  - Added ppmInterp parameter to purityA
  - Complete update of combineAnnotation tool to use either sqlite, postgres or mysql database
  - Update of spectralMatching tool to use either sqlite, postgres or mysql database
  - Added include_adducts parameter to createMSP

v1.11.3-galaxy0.2.5:
  - Note: This was not pushed to test toolshed
  - Clean up of the versioning to be in line with IUC
  - All tools updated with the same versioning
  - Bump to msPurity v1.11.3 to so EIC is calculated for all features

v0.2.5 (spectralMatching):
  - spectralMatching - Extra details from matched library spectra is now added to the database (fix)

v0.2.4 (all tools):
  - bioconductor-mspurity v1.11.2 now used. Fixes EIC problems for MS/MS data

v0.2.2 (spectralMatching):
  - spectralMatching - Extra details from matched library spectra is now added to the database

v0.2.3 (createDatabase):
  - createDatabase.xml fix for EIC creation

v0.2.2 (createDatabase, flagRemove, combineAnnotation):
  - createDatabase.xml fix for xcms3 and CAMERA
  - flagRemove xcms3 fix
  - combineAnnotation Made sirius, probmetab and metfrag optional
  - combineAnnotation fix column sirius

v0.2.1 (all tools):
  - Update msPurity R code version (bug fix for createMSP and xcms3 version check for createDatabase)

v0.2.0 (all tools):
  - Update all tools to be more consistent with msPurity core code

License
-------
Released under the GNU General Public License v3.0 (see `LICENSE file <https://github.com/computational-metabolomics/dimspy-galaxy/blob/master/LICENSE>`_)


.. |Build Status (Travis)| image:: https://img.shields.io/travis/computational-metabolomics/mspurity-galaxy.svg?style=flat&maxAge=3600&label=Travis-CI
   :target: https://travis-ci.org/computational-metabolomics/mspurity-galaxy

.. |Git| image:: https://img.shields.io/badge/repository-GitHub-blue.svg?style=flat&maxAge=3600
   :target: https://github.com/computational-metabolomics/mspurity-galaxy

.. |Bioconda| image:: https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat&maxAge=3600
   :target: http://bioconda.github.io/recipes/bioconductor-mspurity/README.html

.. |License| image:: https://img.shields.io/badge/License-GPL%20v3-blue.svg
   :target: https://www.gnu.org/licenses/gpl-3.0.html


