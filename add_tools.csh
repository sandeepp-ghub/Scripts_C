if ($?1) then
    pp set $1
endif

setenv HS_ENV /mrvl2g/dc5purecl01_s_ccpd01_wa_003/ccpd01/ccpd01/wa_003/seyal/HS_ENV/dev_nsp
setenv PROJ_BE /mrvl2g/dc5purecl01_s_ccpd01_wa_003/ccpd01/ccpd01/wa_003/seyal/PROJ_BE/dev
setenv PROJ_TECHNOLOGY TSMC_005
setenv PROJ_STD_LIB th280_005

setenv PROJ_TEMPLATE ${PROJ_BE}/SCRIPTS

setenv BACKEND_UNITS "dmc"
setenv BACKEND_TOP dmc
setenv PROJ_HIGH_SPEED_MACROS $BACKEND_UNITS

setenv TECHNOLOGY TSMC_005
setenv PROJ_TECHNOLOGY TSMC_005
setenv PROJ_STD_LIB th280_005
setenv STD_LIB_STYLE TSMC
setenv PROJ_METAL RDL16
setenv PROJ_CTS_VT ULVT
setenv PROJ_THICK_METALS 1Ya1Yb4Y2Yy2Yx2R
setenv PROJ_LAYERS TSMC
setenv PROJ_PACKAGE_TYPE FC
setenv PROJ_SETUP_CORNER typ
setenv PROJ_RDL_TYPE 2.8kal
setenv METAL 16
setenv TOP_METAL 16


setenv HS_BIN ${HS_ENV}/bin
set path = ( $HS_BIN $path )
alias cne 'source $HS_ENV/bin/dev/cne/src/cne.csh  \!*'

app del calibre
app add calibre=aoi_cal_2020.2_35.23

alias calibre_drv "calibredrv -sgq normal -sgm 40 -sgc 4 -l /user/seyal/scripts/Calibre/layerprops.5nm.16ML -m"

app del innovus
app add innovus=20.12.000 
alias inn1  "innovus -stylus -files ${HS_ENV}/scripts/inn_setup.tcl -lic_startup invs -wait 300 -no_logv -overwrite -log ./innovus.log -cpus 1  -sgq long -sgc 1  -sgm 40 -sgfg -sgteelog ./run.log"
alias inn8  "innovus -stylus -files ${HS_ENV}/scripts/inn_setup.tcl -lic_startup invs -wait 300 -no_logv -overwrite -log ./innovus.log -cpus 8  -sgq long -sgc 8  -sgm 40 -sgfg -sgteelog ./run.log"
alias inn16 "innovus -stylus -files ${HS_ENV}/scripts/inn_setup.tcl -lic_startup invs -wait 300 -no_logv -overwrite -log ./innovus.log -cpus 16 -sgq long -sgc 16 -sgm 40 -sgfg -sgteelog ./run.log"

app del primetime
app add primetime=R-2020.09-SP3
alias pt1 "pt_shell -sgq normal -sgc 1 -sgm 10 -sgfg -sgteelog ./run.log"
alias pt4 "pt_shell -sgq normal -sgc 4 -sgm 40 -sgfg -sgteelog ./run.log"

