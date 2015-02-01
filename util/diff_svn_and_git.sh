#! /bin/sh
SVN_BASE_DIR=./svn
GIT_BASE_DIR=./git
SVN_REPO_BASE_URL=<URL_WITHOUT_REPOSITORY_NAME>
GIT_REPO_BASE_URL=<URW_WITHOUT_REPOSITORY_NAME>

REPOSITORY_MAPPING=repo_map.csv

for line in `cat ${REPOSITORY_MAPPING} | grep -v ^#`
do
  svn_repo_name=`echo ${line} | cut -d ',' -f 1`
  git_repo_name=`echo ${line} | cut -d ',' -f 2`

  # check out branch from git repository
  git checkout clone_git_repositories ${git_repo_name}

  for branch in trunk 1.2-maintain 1.3-maintain 1.4-maintain
  do
    checkout_svn_repositories ${branch} ${svn_repo_name}

    diff_svn_and_git ${svn_repo_name} ${git_repo_name} ${branch}
  done

done

# $1:svn_name
# $2:git_name
# $3:branch
function diff_svn_and_git() {
  echo *******************************************************
  echo ** take the difference of svn($1) to git($2).
  echo ** branch is $3.
  echo *******************************************************
  pushd $GIT_BASE_DIR/$2
  git checkout $3
  popd

  diff -r $SVN_BASE_DIR_$1_$2 $GIT_BASE_DIR/$2
}

# $1:branche name
# $2:repository name
function checkout_svn_repositories() {
  echo *******************************************************
  echo ** checkout svn. repo_name is ${2} and branch is ${1}.
  echo *******************************************************

  svn checkout $SVN_REPO_BASE_URL/$1/$2 $SVN_BASE_DIR/$1/$2
}

function clone_git_repositories() {
  echo *******************************************************
  echo ** clone git. repo_name is ${1}.
  echo *******************************************************

  git clone $GIT_REPO_BASE_URL/$1.git $GIT_BASE_DIR/$1
}
