#!/bin/bash

set -e
################################################################################
# START: config
################################################################################
h5bpMsgPrefix="[h5BP]"
h5bpVersion="4.3.0"
h5bpLocalFile="h5bp-html5-boilerplate-v${h5bpVersion}"
h5bpLocalFileZip="${h5bpLocalFile}.zip"
h5bpLocalKey="h5bp-html5-boilerplate"
#h5bpRemoteUrl="https://nodeload.github.com/h5bp/html5-boilerplate/legacy.zip/v${h5bpVersion}"
h5bpRemoteUrl="https://api.github.com/repos/h5bp/html5-boilerplate/zipball/v${h5bpVersion}"

bwtFixLocalDir="Assets/Library/BWT"

TbBodyMsgPrefix="[TB body]"

TbMsgPrefix="[TB]"
tbVersion="3.0.2"
tbLocalFile="twbs-bootstrap-v${tbVersion}"
tbLocalFileZip="${tbLocalFile}.zip"
tbLocalKey="twbs-bootstrap"
tbRemoteUrl="https://api.github.com/repos/twbs/bootstrap/zipball/v${tbVersion}"
# See below for getting URL of Git url:
#http://stackoverflow.com/questions/13106269/how-can-i-download-the-most-recent-version-of-a-github-project-to-use-in-a-bash

ERR="***ERROR***:" # Error message prefix

# Probably don't need to touch these
workingDir="Working"
deteteDir="Delete_me"
resultDir="Result"
bootstrapBodyTxtFile="bootstrapBodyText.html"
################################################################################
# END: config
################################################################################



function fnMkDir {
    if ! [ -e "${1}" ]; then
        mkdir "${1}" || { echo "$ERR Unable to create dir '${1}'. Exiting."; exit 1; }
    fi
} # function



function fnChangeToWorkingDir {

    cd "${workingDir}" || {
        echo "$ERR Unable to move to the working directory '${workingDir}'. Has the working directory structure been created?";
        echo "$ERR Exiting";
        exit 1;
    }
} # function



function fnMkDirStructure {
    rm -dfr ${workingDir}
    fnMkDir "${workingDir}"
    cd "${workingDir}"
    fnMkDir "${deteteDir}"
    fnMkDir $resultDir
    fnMkDir "$resultDir/assets"
    fnMkDir "$resultDir/assets/favicons"
    fnMkDir "$resultDir/css"
    fnMkDir "$resultDir/less"
    fnMkDir "$resultDir/less/tb"
    fnMkDir "$resultDir/scripts"
    fnMkDir "$resultDir/scripts/libs"
    fnMkDir "$resultDir/scripts/libs/tb"
    echo "Created directory structure OK."
} # function



function fnGetH5bp {

    echo "--------------------------------------------------------------------------------"
    echo "${h5bpMsgPrefix} Getting HTML5 boilerplate"

    fnChangeToWorkingDir

    #Grab latest copy of h5bp from Git
    echo "${h5bpMsgPrefix} Downloading HTML5 Boilerplate version $h5bpVersion from Github"
    curl -L -o ${h5bpLocalFileZip} ${h5bpRemoteUrl}

    #Assume if greater than 50k then download was OK
    zipSize=$(du -k ${h5bpLocalFileZip} | cut -f1)

    if [ "$zipSize" -lt 50 ]; then
        echo "${h5bpMsgPrefix} $ERR Download failed (download size less the 50k). Exiting."
    exit 1
    fi

    # Unzip download an move to a directory structure convenient to our process
    echo "${h5bpMsgPrefix} Unziping download and moving to correct directory structure."
    unzip -q ${h5bpLocalFileZip}

    mv ${h5bpLocalFileZip} "${deteteDir}"/ || { echo "${h5bpMsgPrefix} $ERR Unable move ../${h5bpLocalFileZip} to dir '${deteteDir}'. Exiting."; exit 1; }
    mv ${h5bpLocalKey}* ${h5bpLocalFile} || { echo "${h5bpMsgPrefix} $ERR Unable to rename unziped HTML5 dir to something std. Exiting."; exit 1; }
} # function



function processH5bp {

    echo "--------------------------------------------------------------------------------"
    echo "${h5bpMsgPrefix} Processing HTML5 boilerplate"

    fnChangeToWorkingDir
    h5bpMyLibVersionMd5=$(md5 -q "../Assets/Library/h5bp/h5bp_bpw.MASTER.html")
    h5bpDownloadVersionMd5=$(md5 -q "${h5bpLocalFile}/index.html")

    [ "$h5bpMyLibVersionMd5" == "$h5bpDownloadVersionMd5" ] || {
        echo "${h5bpMsgPrefix} Hash 1: $h5bpMyLibVersionMd5"
        echo "${h5bpMsgPrefix} Hash 2: $h5bpDownloadVersionMd5"
        echo "${h5bpMsgPrefix} *** WARNING ***: MD5 hash of m5bp index.html is different to our library version 'h5bp_bpw.MASTER.html'."
        echo "${h5bpMsgPrefix} *** WARNING ***: Proceeding regardless, but you should review the resulting template file and probably update our library version."
    }


    echo "${h5bpMsgPrefix} Generating patch file to get from 'h5bp_bpw.MASTER.html' to 'h5bp_bpw.AIMFOR.html'."
    diff -u ../Assets/Library/h5bp/h5bp_bpw.MASTER.html ../Assets/Library/h5bp/h5bp_bpw.AIMFOR.html > h5bp_bpw.patch || {
        # Exit 0 = no differences, 1 = differences, and >1 = errors.
        if [ $? -eq 2 ]; then
            echo "${h5bpMsgPrefix} $ERR Diff exited code 2. Exiting."; exit 1;
        fi
    }
    echo "${h5bpMsgPrefix} Comparing the patch file we've just generated to the reference file."
    diff -u ../Assets/Library/h5bp/h5bp_bpw.patch h5bp_bpw.patch > /tmp/$(basename $0).txt || {
        # Exit 0 = no differences, 1 = differences, and >1 = errors.
        if [ $? -eq 1 ]; then
            echo "${h5bpMsgPrefix} $ERR Diff exited code 1. Exiting."; exit 1;
        fi
        if [ $? -eq 2 ]; then
            echo "${h5bpMsgPrefix} $ERR Diff exited code 2. Exiting."; exit 1;
        fi
    }

    cp "${h5bpLocalFile}/index.html" ${resultDir}/

    echo "${h5bpMsgPrefix} Patching downloaded h5bp index.html with the patch we have created."
    patch "${resultDir}/index.html" < "h5bp_bpw.patch"
    mv "h5bp_bpw.patch" ${deteteDir}/ || { echo "${h5bpMsgPrefix} $ERR Unable move 'h5bp_bpw.patch' to '${deteteDir}'. Exiting."; exit 1; }

    echo "${h5bpMsgPrefix} Populate results dir '${resultDir}' with required assets."
    cp "${h5bpLocalFile}/apple-touch-icon"* "${resultDir}/assets/favicons/"
    cp "${h5bpLocalFile}/css"/* "${resultDir}/css/"
    rm "${resultDir}/css/main.css" "${resultDir}/css/normalize.css"
    cp "${h5bpLocalFile}/js"/*.js "${resultDir}/scripts/"
    rm "${resultDir}/scripts/plugins.js"
    cp "${h5bpLocalFile}/js/vendor"/* "${resultDir}/scripts/libs/"

    # BWT additional files
    pwd
    cp "../${bwtFixLocalDir}/bwt-site.less" "${resultDir}/less/"
    cp "../${bwtFixLocalDir}/bwt-imported.less" "${resultDir}/less/"
    cp "../${bwtFixLocalDir}/elements.less" "${resultDir}/less/"
    cp "../${bwtFixLocalDir}/bwt-bootstrap-reset.less" "${resultDir}/less/bwt-bootstrap-reset.less";
    cp "../${bwtFixLocalDir}/bwt-main-areas.less" "${resultDir}/less/bwt-main-areas.less";
    cp "../${bwtFixLocalDir}/bwt-mixins.less" "${resultDir}/less/bwt-mixins.less"
    cp "../${bwtFixLocalDir}/bwt-site.js" "${resultDir}/scripts/bwt-site.js"

} # function



function fnProcessBootstrapBodyTxt {

    echo "--------------------------------------------------------------------------------"
    echo "${TbBodyMsgPrefix} Processing Twitter Bootstrap body text"

    fnChangeToWorkingDir

    echo "${TbBodyMsgPrefix} Grabbing sample file."

    #Create copy of master body:
    cp ../Assets/Library/Bootstrap/${bootstrapBodyTxtFile} .

    #Need to add html, head, title and body tags with:
    echo "${TbBodyMsgPrefix} Adding html/head/title/body tags so we can process."
    origFile=$(cat ${bootstrapBodyTxtFile})
    echo "<html><head><title>Test</title></head><body> $origFile </body></html>" > ${bootstrapBodyTxtFile}

    #Tidy HTML with:
    echo "${TbBodyMsgPrefix} Tidying HTML."
    tidy -q -config ~/.tidy.config ${bootstrapBodyTxtFile} > ${bootstrapBodyTxtFile}.processed || {

    # Exit 0 = all OK, 1 = warnings, and 2 = errors.
    if [ $? -eq 2 ]; then
        echo "${TbBodyMsgPrefix} $ERR Tidy exited code 2. Exiting."; exit 1;
    fi
    }
    mv "${bootstrapBodyTxtFile}" "${deteteDir}"/ || { echo "${TbBodyMsgPrefix} $ERR Unable to move '${bootstrapBodyTxtFile}' to '${deteteDir}'. Exiting."; exit 1; }

    #Remove added tags with:
    echo "${TbBodyMsgPrefix} Removing tags we added..."
    perl -i -pe 'BEGIN{undef $/;} s/\<html\>.*\<body\>//smg' ${bootstrapBodyTxtFile}.processed
    perl -i -pe 'BEGIN{undef $/;} s/\<\/body\>.*\<\/html\>//smg' ${bootstrapBodyTxtFile}.processed
} # function



function fnGetTwitterBootstrap {

    echo "--------------------------------------------------------------------------------"
    echo "${TbMsgPrefix} Getting Twitter Bootstrap"

    fnChangeToWorkingDir

    #Grab latest copy of h5bp from Git
    echo "${TbMsgPrefix} Downloading Twitter Bootstrap version $tbVersion from Github"
    curl -L -o "${tbLocalFileZip}" "${tbRemoteUrl}"

    #Assume if greater than 50k then download was OK
    zipSize=$(du -k ${tbLocalFileZip} | cut -f1)

    if [ "$zipSize" -lt 50 ]; then
        echo "${TbMsgPrefix} $ERR Download failed (download size less the 50k). Exiting."
    exit 1
    fi

    # Unzip download an move to a directory structure convenient to our process
    echo "${TbMsgPrefix} Unziping download and moving to correct directory structure."
    unzip -q ${tbLocalFileZip}

    mv ${tbLocalFileZip} "${deteteDir}"/ || { echo "${TbMsgPrefix} $ERR Unable move ../${tbLocalFileZip} to dir '${deteteDir}'. Exiting."; exit 1; }
    mv ${tbLocalKey}* ${tbLocalFile} || { echo "${TbMsgPrefix} $ERR Unable to rename unziped HTML5 dir to something std. Exiting."; exit 1; }
} # function

function processTwitterBootstrap {

    fnChangeToWorkingDir
    #h5bpMyLibVersionMd5=$(md5 -q "../Assets/Library/h5bp/h5bp_bpw.MASTER.html")
    #h5bpDownloadVersionMd5=$(md5 -q "${h5bpLocalFile}/index.html")

    #[ "$h5bpMyLibVersionMd5" == "$h5bpDownloadVersionMd5" ] || {
    #echo "Hash 1: $h5bpMyLibVersionMd5"
    #echo "Hash 2: $h5bpDownloadVersionMd5"
    #echo "*** WARNING ***: MD5 hash of m5bp index.html is different to our library version 'h5bp_bpw.MASTER.html'."
    #echo "*** WARNING ***: Proceeding regardless, but you should review the resulting template file and probably update our library version."
    #}


    #echo "Generating patch file to get from 'h5bp_bpw.MASTER.html' to 'h5bp_bpw.AIMFOR.html'..."
    #diff -u ../Assets/Library/h5bp/h5bp_bpw.MASTER.html ../Assets/Library/h5bp/h5bp_bpw.AIMFOR.html > h5bp_bpw.patch || {
    ## Exit 0 = no differences, 1 = differences, and >1 = errors.
    #if [ $? -eq 2 ]; then
    #echo "$ERR Diff exited code 2. Exiting."; exit 1;
    #fi
    #}

    #cp "${h5bpLocalFile}/index.html" ${resultDir}/

    #echo "Patching downloaded h5bp index.html with the patch we have created..."
    #patch "${resultDir}/index.html" < "h5bp_bpw.patch"
    #mv "h5bp_bpw.patch" ${deteteDir}/ || { echo "$ERR Unable move 'h5bp_bpw.patch' to '${deteteDir}'. Exiting."; exit 1; }

    echo "${TbMsgPrefix} Populate results dir '${resultDir}' with required assets..."
    cp -R "${tbLocalFile}/js/"* "${resultDir}/scripts/libs/tb/"
    cp -R "${tbLocalFile}/less/"* "${resultDir}/less/tb/"
} # function





startDir=$(pwd)

cd ${startDir}
fnMkDirStructure

cd ${startDir}
fnGetH5bp

cd ${startDir}
processH5bp

cd ${startDir}
fnProcessBootstrapBodyTxt

cd ${startDir}
fnGetTwitterBootstrap

cd ${startDir}
processTwitterBootstrap




echo "Exiting. Nice!"
exit 0

