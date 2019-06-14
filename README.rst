msPurity for Galaxy
========================
|Build Status (Travis)| |Git| |Bioconda| |License|

Warning
------
Proceed with caution these tools are in active development so tools may change! Stable release to Galaxy toolshed coming soon. Currently these tools will only work when the 'tomnl' conda channel is being used with Galaxy. 


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

- Thomas N. Lawson (tnl495@bham.ac.uk) - `University of Birmingham (UK) <http://www.birmingham.ac.uk/index.aspx>`_
- Ralf J. M. Weber (r.j.weber@bham.ac.uk) - `University of Birmingham (UK) <http://www.birmingham.ac.uk/index.aspx>`_
- Jordi Capellades (j.capellades.to@gmail.com) - `Universitat Rovira i Virgili (SP)  <http://www.urv.cat/en/>`_
- Julien Saint-Vanne (jsaintvanne) - `ABiMS (France) <http://abims.sb-roscoff.fr/>`_

Changes
-------------------------
v0.2.1 (all tools):
- Update msPurity R code version (bug fix for createMSP and xcms3 version check for createDatabase)
- createDatabase.xml fix for xcms3 and CAMERA

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
   :target: http://bioconda.github.io/recipes/mspurity/README.html

.. |License| image:: https://img.shields.io/badge/License-GPL%20v3-blue.svg
   :target: https://www.gnu.org/licenses/gpl-3.0.html


