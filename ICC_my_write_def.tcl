#######################################
# write def of box pin and macro      #
# #####################################

proc my_write_def {file_name} {
eval {write_def -macro -pin -verbose -components -output $file_name }
}

