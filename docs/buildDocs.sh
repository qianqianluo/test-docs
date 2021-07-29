#!/bin/bash
set -x
################################################################################
# File:    buildDocs.sh
# Purpose: Script that builds our documentation using sphinx and updates GitHub
#          Pages. This script is executed by:
#            .github/workflows/docs_pages_workflow.yml
#
# Authors: Qian Luo
# Created: 2021-07-02
# Updated: 2020-07-08
# Version: 0.0
################################################################################
 
###################
# INSTALL DEPENDS #
###################
 
apt-get update
apt-get -y install git rsync python3-sphinx python3-sphinx-rtd-theme python3-stemmer python3-git python3-pip python3-virtualenv 
 
python3 -m pip install --upgrade rinohtype pygments
 
#####################
# DECLARE VARIABLES #
#####################
 
pwd
ls -lah
export SOURCE_DATE_EPOCH=$(git log -1 --pretty=%ct)
# make a new temp dir which will be our GitHub Pages docroot
docroot=`mktemp -d`
 
export REPO_NAME="${GITHUB_REPOSITORY##*/}"

##############
# BUILD DOCS #
##############
 
# first, cleanup any old builds' static assets
make -C docs clean
# get a list of branches, excluding 'HEAD' and 'gh-pages'
versions="`git for-each-ref '--format=%(refname:lstrip=-1)' refs/remotes/origin/ | grep -viE '^(HEAD|gh-pages)$'`"

for current_version in ${versions}; do
  
   # make the current language available to conf.py
   export current_version
   git checkout ${current_version}
  
   echo "INFO: Building sites for ${current_version}"
  
   # skip this branch if it doesn't have our docs dir & sphinx config
   if [ ! -e 'docs/source/conf.py' ]; then
      echo -e "\tINFO: Couldn't find 'docs/conf.py' (skipped)"
      continue
   fi
  
   languages="en `find docs/source/locale/ -mindepth 1 -maxdepth 1 -type d -exec basename '{}' \;`"
   for current_language in ${languages}; do
  
      # make the current language available to conf.py
      export current_language
      ##########
      # BUILDS #
      ##########
      echo "INFO: Building for ${current_language}"
  
      # HTML #
      sphinx-build -b html docs/source docs/build/html/${current_language}/${current_version} -D language="${current_language}"
 
  
      # copy the static assets produced by the above build into our docroot
      rsync -av "docs/build/html/" "${docroot}/"
  
   done
  
done

# return to master branch
git checkout master

#######################
# Update GitHub Pages #
#######################
 
git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"

pushd "${docroot}"
 
# don't bother maintaining history; just generate fresh
git init
git remote add deploy "https://token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git checkout -b gh-pages
 
# add .nojekyll to the root so that github won't 404 on content added to dirs
# that start with an underscore (_), such as our "_content" dir..
touch .nojekyll

# add redirect from the docroot to our default docs language/version
cat > style.css <<EOF
@import url('https://fonts.googleapis.com/css2?family=Didact+Gothic&display=swap');
@import url('https://cdnjs.cloudflare.com/ajax/libs/normalize/8.0.1/normalize.css');
body {
    font-family: 'Didact Gothic', sans-serif;
    color:#333;
        box-sizing: border-box;
}

* {
    box-sizing: border-box;
}

a {
    text-decoration: none;
}

header {
   
    background-color: #f2f2f2;
    height: 110px;
    padding: 10px 0;
    
}

nav {
    width: 960px;
    margin: 0 auto;
    display: flex;
    justify-content: space-between;
}

.logo {
    width: 100px;
}

.logo img {
    width: 100px;
    
}

.lang-menu {
    width: 100px;
    text-align: right;
    font-weight: bold;
    margin-top: 25px;
    position: relative;
}
.lang-menu .selected-lang {
    display: flex;   
    justify-content: space-between;
    line-height: 2;
    cursor: pointer;
}
.lang-menu .selected-lang:before {
    content: '';
    display: inline-block;
    width: 32px;
    height: 32px;
    background-image: url(https://www.countryflags.io/us/flat/32.png);
    background-size: contain;
    background-repeat: no-repeat;
}

.lang-menu ul {
    margin: 0;
    padding: 0;
    display: none;
    background-color: #fff;
    border: 1px solid #f8f8f8;
    position: absolute;
    top: 45px;
    right: 0px;
    width: 125px;
    border-radius: 5px;
    box-shadow: 0px 1px 10px rgba(0,0,0,0.2);
}


.lang-menu ul li {
    list-style: none;
    text-align: left;
    display: flex;
    justify-content: space-between;
}

.lang-menu ul li a {
    text-decoration: none;
    width: 125px;
    padding: 5px 10px;
    display: block;
}

.lang-menu ul li:hover {
    background-color: #f2f2f2;
}

.lang-menu ul li a:before {
    content: '';
    display: inline-block;
    width: 25px;
    height: 25px;
    vertical-align: middle;
    margin-right: 10px;
    background-size: contain;
    background-repeat: no-repeat;
}

.pl:before {
    background-image: url(https://www.countryflags.io/pl/flat/32.png);
}

.en:before {
    background-image: url(https://www.countryflags.io/us/flat/32.png);
}
.cn:before {
    background-image: url(https://www.countryflags.io/cn/flat/32.png);
}




.lang-menu:hover ul {
    display: block;
}
EOF

cat > index.html <<EOF
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tigase documentation main page</title>
    <link rel="stylesheet" href="style.css">
</head>
 
<body>
<h1 style = "color:blue;"> Welcome to Tigase Documentation Website</h1>
    <header>
        <nav>
            <div class="logo">
                <a href="#"><img src="logo.png" alt=""></a>
            </div> 
            <div class="lang-menu">
                <div class="selected-lang">
                    English
                </div>
                <ul>
                    <a href="/${REPO_NAME}/pl/master/" class="pl"><li>POLISH</li></a>
		
                    <li>
                        <a href="/${REPO_NAME}/en/master/" class="en">English</a>
                    </li>
                    <li>
                        <a href="/${REPO_NAME}/zh_CN/master/" class="cn">CHINESE</a>
                    </li>
                
            </div>
        </nav>
    </header>

</body>

</html>
EOF

# copy the resulting html pages built from sphinx above to our new git repo
git add .
 
# commit all the new files
msg="Updating Docs for commit ${GITHUB_SHA} made on `date -d"@${SOURCE_DATE_EPOCH}" --iso-8601=seconds` from ${GITHUB_REF} by ${GITHUB_ACTOR}"
git commit -am "${msg}"
 
# overwrite the contents of the gh-pages branch on our github.com repo
git push deploy gh-pages --force
 
popd # return to main repo sandbox root
 
# exit cleanly
exit 0