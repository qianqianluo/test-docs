# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
from pathlib import Path
#import sys
#sys.path.insert(0, os.path.abspath('.'))



# -- Project information -----------------------------------------------------

project = 'TigaseDoc'
copyright = '2021, Qian Luo'
author = 'Qian Luo'

# The full version, including alpha/beta/rc tags
release = '0.1'



# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'sphinx_rtd_theme',
    'sphinx.ext.autodoc',
    'sphinx.ext.viewcode',
    'sphinx.ext.githubpages',
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = []
source_suffix = '.rst'
# This is also used if you do content translation via gettext catalogs.
# Usually you set "language" from the command line for these cases.
language = None


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
import sphinx_rtd_theme
html_theme = 'sphinx_rtd_theme'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']


# locale_dirs = ['locale/']   # path is example but recommended.
# gettext_compact = False     # optional.

import sys, os
sys.path.insert(0, os.path.abspath('../source'))
# multilangage support
############################
# SETUP THE RTD LOWER-LEFT #
############################
try:
   html_context
except NameError:
   html_context = dict()
html_context['display_lower_left'] = True

if 'REPO_NAME' in os.environ:
	REPO_NAME = os.environ['REPO_NAME']
else:
	REPO_NAME = ''
 
# SET CURRENT_LANGUAGE
if 'current_language' in os.environ:
   # get the current_language env var set by buildDocs.sh
   current_language = os.environ['current_language']
else:
   # the user is probably doing `make html`
   # set this build's current language to english
   current_language = 'en'
 
# tell the theme which language to we're currently building
html_context['current_language'] = current_language


 
# SET CURRENT_VERSION
from git import Repo
repo = Repo( search_parent_directories=True )
 
if 'current_version' in os.environ:
   # get the current_version env var set by buildDocs.sh
   current_version = os.environ['current_version']
else:
   # the user is probably doing `make html`
   # set this build's current version by looking at the branch
   current_version = repo.active_branch.name
 
# tell the theme which version we're currently on ('current_version' affects
# the lower-left rtd menu and 'version' affects the logo-area version)
html_context['current_version'] = current_version
html_context['version'] = current_version
 
# POPULATE LINKS TO OTHER LANGUAGES
html_context['languages'] = [ ('en', '/' +REPO_NAME+ '/en/' +current_version+ '/') ]
 
languages = [lang.name for lang in os.scandir('locale') if lang.is_dir()]
for lang in languages:
   html_context['languages'].append( (lang, '/' +REPO_NAME+ '/' +lang+ '/' +current_version+ '/') )
 
# POPULATE LINKS TO OTHER VERSIONS
html_context['versions'] = list()
 
versions = [branch.name for branch in repo.branches]
for version in versions:
   html_context['versions'].append( (version, '/' +REPO_NAME+ '/'  +current_language+ '/' +version+ '/') )
 
# POPULATE LINKS TO OTHER FORMATS/DOWNLOADS
 

 
# settings for EPUB
epub_basename = 'target'
 
html_context['downloads'] = list()
html_context['downloads'].append( ('pdf', '/' +REPO_NAME+ '/' +current_language+ '/' +current_version+ '/' +project+ '-docs_' +current_language+ '_' +current_version+ '.pdf') )
 
html_context['downloads'].append( ('epub', '/' +REPO_NAME+ '/' +current_language+ '/' +current_version+ '/' +project+ '-docs_' +current_language+ '_' +current_version+ '.epub') )
 
##########################
# "EDIT ON GITHUB" LINKS #
##########################
 
html_context['display_github'] = True
html_context['github_user'] = 'qianqianluo'
html_context['github_repo'] = 'test-docs'
html_context['github_version'] = 'master/docs/'