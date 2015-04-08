#!/bin/bash

# Patch help. To be run from the 'Working' directory
# diff -u ../Assets/Library/h5bp/h5bp_bpw.MASTER.html ../Assets/Library/h5bp/h5bp_bpw.AIMFOR.html > ../Assets/Library/h5bp/h5bp_bpw.patch
#

set -e
################################################################################
# START: config
################################################################################
h5bpMsgPrefix="[h5BP]"
h5bpVersion="5.0.0"
h5bpLocalDir="h5bp-html5-boilerplate-v${h5bpVersion}"
h5bpLocalFileZip="${h5bpLocalDir}.zip"
h5bpLocalDirSrc="${h5bpLocalDir}/dist"
h5bpLocalKey="h5bp-html5-boilerplate"
#h5bpRemoteUrl="https://nodeload.github.com/h5bp/html5-boilerplate/legacy.zip/v${h5bpVersion}"
h5bpRemoteUrl="https://api.github.com/repos/h5bp/html5-boilerplate/zipball/v${h5bpVersion}"

assetLib="/Assets/Library"
bwtFixLocalDir="${assetLib}/BWT"
libNuGet="${assetLib}/NuGet"

TbBodyMsgPrefix="[TB body]"

TbMsgPrefix="[TB]"
tbVersion="3.3.4"
tbLocalFile="twbs-bootstrap-v${tbVersion}"
tbLocalFileZip="${tbLocalFile}.zip"
tbLocalKey="twbs-bootstrap"
tbRemoteUrl="https://api.github.com/repos/twbs/bootstrap/zipball/v${tbVersion}"
# See below for getting URL of Git url:
#http://stackoverflow.com/questions/13106269/how-can-i-download-the-most-recent-version-of-a-github-project-to-use-in-a-bash


GlyphiconProMsgPrefix="[GP]"

ERR="***ERROR***:" # Error message prefix


# NuGet Packaging
nuGetMsgPrefix="[NuGet]"
nuGetPkgReleaseNotes="TwitterBootstrap v${tbVersion} and HTML5 Boilerplate v${h5bpVersion}."
nuGetPkgReleaseNotes="${nuGetPkgReleaseNotes}"
nuGetPkgVersion="1.0.6"

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
    fnMkDir "$resultDir/assets/fonts"
    fnMkDir "$resultDir/assets/images"
    fnMkDir "$resultDir/css"
    fnMkDir "$resultDir/css/less"
    fnMkDir "$resultDir/css/less/libs"
    fnMkDir "$resultDir/css/less/libs/tb"
    fnMkDir "$resultDir/scripts"
    fnMkDir "$resultDir/scripts/angular-apps"
    fnMkDir "$resultDir/scripts/libs"
    fnMkDir "$resultDir/scripts/libs/tb"
    fnMkDir "$resultDir/Views"
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
    mv ${h5bpLocalKey}* ${h5bpLocalDir} || { echo "${h5bpMsgPrefix} $ERR Unable to rename unziped HTML5 dir to something std. Exiting."; exit 1; }



} # function



function fnProcessH5bp {

    echo "--------------------------------------------------------------------------------"
    echo "${h5bpMsgPrefix} Processing HTML5 boilerplate"

    fnChangeToWorkingDir
    h5bpMyLibVersionMd5=$(md5 -q "../Assets/Library/h5bp/h5bp_bpw.MASTER.html")
    h5bpDownloadVersionMd5=$(md5 -q "${h5bpLocalDirSrc}/index.html")

    [ "$h5bpMyLibVersionMd5" == "$h5bpDownloadVersionMd5" ] || {
        echo "${h5bpMsgPrefix} Hash 1: $h5bpMyLibVersionMd5"
        echo "${h5bpMsgPrefix} Hash 2: $h5bpDownloadVersionMd5"
        echo "${h5bpMsgPrefix} *** WARNING ***: MD5 hash of m5bp index.html is different to our library version 'h5bp_bpw.MASTER.html'."
        #echo "${h5bpMsgPrefix} *** WARNING ***: Proceeding regardless, but you should review the resulting template file and probably update our library version."
        echo "${h5bpMsgPrefix} *** WARNING ***: You should review the resulting template file and probably update our library version."
        echo "${h5bpMsgPrefix} Exiting..."
        exit 1
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

    cp "${h5bpLocalDirSrc}/index.html" ${resultDir}/

    echo "${h5bpMsgPrefix} Patching downloaded h5bp index.html with the patch we have created."
    patch "${resultDir}/index.html" < "h5bp_bpw.patch"
    mv "h5bp_bpw.patch" ${deteteDir}/ || { echo "${h5bpMsgPrefix} $ERR Unable move 'h5bp_bpw.patch' to '${deteteDir}'. Exiting."; exit 1; }

    echo "${h5bpMsgPrefix} Populate results dir '${resultDir}' with required assets."
    cp "${h5bpLocalDirSrc}/apple-touch-icon"* "${resultDir}/assets/favicons/"
    cp "${h5bpLocalDirSrc}/css"/* "${resultDir}/css/"
    rm "${resultDir}/css/main.css" "${resultDir}/css/normalize.css"
    cp "${h5bpLocalDirSrc}/js"/*.js "${resultDir}/scripts/"
    rm "${resultDir}/scripts/plugins.js" "${resultDir}/scripts/main.js"
    cp "${h5bpLocalDirSrc}/js/vendor"/* "${resultDir}/scripts/libs/"

    # BWT additional files
    pwd
    #cp "../${bwtFixLocalDir}/bwt-banner.less" "${resultDir}/css/less/"
    #cp "../${bwtFixLocalDir}/bwt-bootstrap-reset.less" "${resultDir}/css/less/";
    #cp "../${bwtFixLocalDir}/bwt-build-helpers.less" "${resultDir}/css/less/";
    #cp "../${bwtFixLocalDir}/bwt-buttons.less" "${resultDir}/css/less/"
    #cp "../${bwtFixLocalDir}/bwt-fonts.less" "${resultDir}/css/less/"
    #cp "../${bwtFixLocalDir}/bwt-footer.less" "${resultDir}/css/less/"
    #cp "../${bwtFixLocalDir}/bwt-forms.less" "${resultDir}/css/less/"
    #cp "../${bwtFixLocalDir}/bwt-header.less" "${resultDir}/css/less/"
    #cp "../${bwtFixLocalDir}/bwt-imported.less" "${resultDir}/css/less/"
    #cp "../${bwtFixLocalDir}/bwt-layout.less" "${resultDir}/css/less/";
    #cp "../${bwtFixLocalDir}/bwt-lists.less" "${resultDir}/css/less/";
    #cp "../${bwtFixLocalDir}/bwt-misc.less" "${resultDir}/css/less/";
    #cp "../${bwtFixLocalDir}/bwt-mixins.less" "${resultDir}/css/less/"
    #cp "../${bwtFixLocalDir}/bwt-navigation-main.less" "${resultDir}/css/less/"
    #cp "../${bwtFixLocalDir}/bwt-panels.less" "${resultDir}/css/less/"
    #cp "../${bwtFixLocalDir}/bwt-site.js" "${resultDir}/scripts/bwt-site.js"
    #cp "../${bwtFixLocalDir}/bwt-site.less" "${resultDir}/css/less/"
    #cp "../${bwtFixLocalDir}/css_browser_selector.js" "${resultDir}/scripts/libs/"
    #cp "../${bwtFixLocalDir}/elements.less" "${resultDir}/css/less/libs/"
    cp -R "../${bwtFixLocalDir}/" "${resultDir}/"


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

function fnProcessTwitterBootstrap {

    fnChangeToWorkingDir

    echo "${TbMsgPrefix} Populate results dir '${resultDir}' with required assets..."
    cp -R "${tbLocalFile}/js/"* "${resultDir}/scripts/libs/tb/"
    cp -R "${tbLocalFile}/less/"* "${resultDir}/css/less/libs/tb/"
    fnMkDir "${resultDir}/assets/fonts/glyphicons_halflings_regular"

    echo "${TbMsgPrefix} Move built-in 'glyphicons halflings regular' to new location"
    cp -R "${tbLocalFile}/fonts/"* "${resultDir}/assets/fonts/glyphicons_halflings_regular/"
    perl -pi -e "s/\.\.\/fonts\//\/assets\/fonts\/glyphicons_halflings_regular\//g" "${resultDir}/css/less/libs/tb/variables.less"

} # function


function fnProcessNuGet {

    echo "--------------------------------------------------------------------------------"
    echo "${nuGetMsgPrefix} Converting for NuGet"

    fnChangeToWorkingDir


    echo "${nuGetMsgPrefix} Placing dummy file in empty directories..."
    cp "../${libNuGet}/dummy.txt" "${resultDir}/assets/favicons/"
    cp "../${libNuGet}/dummy.txt" "${resultDir}/assets/fonts/"
    cp "../${libNuGet}/dummy.txt" "${resultDir}/assets/images/"
    cp "../${libNuGet}/dummy.txt" "${resultDir}/scripts/angular-apps/"

    echo "${nuGetMsgPrefix} Creating master template..."
    cp "../${libNuGet}/bwt-master.cshtml" "${resultDir}/Views/"
    cat "${resultDir}/index.html" >> "${resultDir}/Views/bwt-master.cshtml"
    perl -pi -e 's/\.\//\//g' "${resultDir}/Views/bwt-master.cshtml"
    rm "${resultDir}/index.html"

    mkdir "NuGet"
    mkdir "NuGet/content"
    mkdir "NuGet/libs"
    mkdir "NuGet/tools"
    cp -R "${resultDir}/"* "NuGet/content/"

    cp "../${assetLib}/readme.md" "NuGet/readme.txt"
    cp "../${assetLib}/Package.nuspec" "NuGet/"
    perl -pi -e "s/\[\[NUGET\_PKG\_VERSION\]\]/${nuGetPkgVersion}/g" "NuGet/Package.nuspec"
    perl -pi -e "s/\[\[NUGET\_PKG\_RELEASE\_NOTES\]\]/${nuGetPkgReleaseNotes}/g" "NuGet/Package.nuspec"

} # function



function fnProcessGlyphicons {

    echo "--------------------------------------------------------------------------------"
    echo "${GlyphiconProMsgPrefix} Processing Glyphicons Pro"

    fnChangeToWorkingDir


    gpMyLibVersionMd5=$(cat "../Assets/Library/Glyphicons_pro/glyphicons_pro.zip.md5")
    gpCurrentLibVersionMd5=$(md5 -q "../Assets/Library/Glyphicons_pro/glyphicons_pro.zip")

    [ "$gpMyLibVersionMd5" == "$gpCurrentLibVersionMd5" ] || {
        echo "${GlyphiconProMsgPrefix} Hash 1: $gpMyLibVersionMd5"
        echo "${GlyphiconProMsgPrefix} Hash 2: $gpCurrentLibVersionMd5"
        echo "${GlyphiconProMsgPrefix} *** WARNING ***: MD5 hash of glyphicons_pro.zip is different to our library version 'glyphicons_pro.zip.md5'."
        echo "${GlyphiconProMsgPrefix} *** WARNING ***: You should review Glyphicon Pro and check the .less files."
        echo "${GlyphiconProMsgPrefix} Exiting..."
        exit 1
    }

    fnMkDir "glyphicons_pro"


    gpTypeDir="glyphicons"
    gpTypeFile="glyphicons"
    unzip -qj "../Assets/Library/Glyphicons_pro/glyphicons_pro.zip" "glyphicons_pro/${gpTypeDir}/web/html_css/fonts/*" -d glyphicons_pro/${gpTypeDir}
    searchStr="\.\.\/fonts\/"
    replaceStr="\/assets\/fonts\/glyphicons_pro\/${gpTypeDir}\/"
    unzip -qj "../Assets/Library/Glyphicons_pro/glyphicons_pro.zip" "glyphicons_pro/${gpTypeDir}/web/html_css/less/${gpTypeFile}.less" -d glyphicons_pro/${gpTypeDir}
    perl -pi -e "s/${searchStr}/${replaceStr}/g" "glyphicons_pro/${gpTypeDir}/${gpTypeFile}.less"

    gpTypeDir='glyphicons_filetypes'
    gpTypeFile="glyphicons-filetypes"
    unzip -qj "../Assets/Library/Glyphicons_pro/glyphicons_pro.zip" "glyphicons_pro/${gpTypeDir}/web/html_css/fonts/*" -d glyphicons_pro/${gpTypeDir}
    searchStr="\.\.\/fonts\/"
    replaceStr="\/assets\/fonts\/glyphicons_pro\/${gpTypeDir}\/"
    unzip -qj "../Assets/Library/Glyphicons_pro/glyphicons_pro.zip" "glyphicons_pro/${gpTypeDir}/web/html_css/less/${gpTypeFile}.less" -d glyphicons_pro/${gpTypeDir}
    perl -pi -e "s/${searchStr}/${replaceStr}/g" "glyphicons_pro/${gpTypeDir}/${gpTypeFile}.less"

    gpTypeDir="glyphicons_social"
    gpTypeFile="glyphicons-social"
    unzip -qj "../Assets/Library/Glyphicons_pro/glyphicons_pro.zip" "glyphicons_pro/${gpTypeDir}/web/html_css/fonts/*" -d glyphicons_pro/${gpTypeDir}
    searchStr="\.\.\/fonts\/"
    replaceStr="\/assets\/fonts\/glyphicons_pro\/${gpTypeDir}\/"
    unzip -qj "../Assets/Library/Glyphicons_pro/glyphicons_pro.zip" "glyphicons_pro/${gpTypeDir}/web/html_css/less/${gpTypeFile}.less" -d glyphicons_pro/${gpTypeDir}
    perl -pi -e "s/${searchStr}/${replaceStr}/g" "glyphicons_pro/${gpTypeDir}/${gpTypeFile}.less"

    mv "glyphicons_pro" "$resultDir/assets/fonts/"



} # function



startDir=$(pwd)

cd ${startDir}
fnMkDirStructure

cd ${startDir}
fnGetH5bp

cd ${startDir}
fnProcessH5bp

cd ${startDir}
fnProcessBootstrapBodyTxt

cd ${startDir}
fnGetTwitterBootstrap

cd ${startDir}
fnProcessTwitterBootstrap

cd ${startDir}
fnProcessGlyphicons

cd ${startDir}
fnProcessNuGet


echo "Exiting. Nice!"
exit 0

