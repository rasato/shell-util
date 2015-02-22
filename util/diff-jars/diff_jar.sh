#! /bin/sh

WORK_ROOT_DIR=work
JAR_STORE=jar

# ${1}:working directory
# ${2}:extracted jar name
# ${3}:another extracted jar name
# description:get diff between two jar files. output "diff_<jar name>_and_<another jar name>.log"
function get_diff() {
    extracted_dir=${1}/${2}
    another_extracted_dir=${1}/${3}

    echo "***********************************************************************************"
    echo "** take the difference between ${extracted_dir} and ${another_extracted_dir}."
    echo "***********************************************************************************"

    #DIFF_LOG_FILE=diff_${2}_and_${3}.log
    DIFF_LOG_FILE=`get_diff_log_name ${2} ${3}`
    diff -r --brief ${extracted_dir} ${another_extracted_dir}
}

# ${1}:jar name
# ${2}: another jar name
function get_diff_log_name() {
    echo "diff_${1}_and_${2}"
}

# ${1}:jar name
# ${2}:work directory
# description:extract jar file in work/jarname directory
function extract_jar() {
    extract_dir=${2}/${1}
    extract_jar_name=${1}

    # make extract dir per jar
    mkdir ${extract_dir}
    cp ${JAR_STORE}/${extract_jar_name}.jar ${extract_dir}

    echo "***********************************************************************************"
    echo "** extract ${extract_jar_name} in ${extract_dir}."
    echo "***********************************************************************************"
    pushd ${extract_dir}
    jar xvf ${extract_jar_name}.jar
    rm ${extract_jar_name}.jar
    popd
}

# ${1}:filterd log file name
function filter_diff() {
    echo "***********************************************************************************"
   echo "** not filtered." 
    echo "***********************************************************************************"
}

# initialize work dir
if [ -d ${WORK_ROOT_DIR} ]; then
    rm -rf ${WORK_ROOT_DIR}
fi
mkdir ${WORK_ROOT_DIR}

for line in `cat jar_name_map.csv`
do
    # get diff target names.
    jar_name=`echo ${line} | cut -d ',' -f 1`
    another_jar_name=`echo ${line} | cut -d ',' -f 2`

    # make work directory.
    work_dir=${WORK_ROOT_DIR}/${jar_name}_and_${another_jar_name}
    mkdir -p ${work_dir}

    # extract jar
    extract_jar ${jar_name} ${work_dir}
    extract_jar ${another_jar_name} ${work_dir}

    RESULT_FILE_NAME=`get_diff_log_name ${jar_name} ${another_jar_name}`
    get_diff ${work_dir} ${jar_name} ${another_jar_name} | tee ${RESULT_FILE_NAME}.log
    # TODO: if filter script, dispatch it.
    filter_diff ${RESULT_FILE_NAME}.log | tee ${RESULT_FILE_NAME}-filter.log
done
