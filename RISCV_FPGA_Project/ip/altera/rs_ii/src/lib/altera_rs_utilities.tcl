# (C) 2001-2013 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.





# +-----------------------------------
# | Module Parameters
# |
proc add_module_parametersCHANNEL {} {
add_parameter CHANNEL INTEGER 1 
set_parameter_property CHANNEL DISPLAY_NAME "Number of channels"
set_parameter_property CHANNEL ENABLED true
set_parameter_property CHANNEL UNITS None
set_parameter_property CHANNEL DESCRIPTION "Number of channels"
set_parameter_property CHANNEL HDL_PARAMETER true
}

proc add_module_parametersN {} {
add_parameter N INTEGER 255
set_parameter_property N DISPLAY_NAME "Number of symbols per codeword"
set_parameter_property N ENABLED true
set_parameter_property N UNITS None
set_parameter_property N DESCRIPTION "Symbols per codeword"
set_parameter_property N HDL_PARAMETER true
}

proc add_module_parametersGENPOLTYPE {} {
add_parameter GENPOLTYPE string "Classical"
set_parameter_property GENPOLTYPE DISPLAY_NAME "Type of Generator Polynomial"
set_parameter_property GENPOLTYPE ENABLED true
set_parameter_property GENPOLTYPE UNITS None
set_parameter_property GENPOLTYPE DESCRIPTION "Classical or CCSDS-like representration of the generator polynomial"
set_parameter_property GENPOLTYPE DISPLAY_HINT radio
set_parameter_property GENPOLTYPE ALLOWED_RANGES {"Classical" "CCSDS-like"}
set_parameter_property GENPOLTYPE LONG_DESCRIPTION "<html>Chose the representation  of the generator polynomial: 
<ul> Classical:  G(x) = (x-&alpha<sup>i0</sup>)(x-&alpha<sup>i0+rsp</sup>)(x-&alpha<sup>i0+2rsp</sup>)...</ul>
<ul> CCSDS-like: G(x) = (x-&alpha<sup>i0*rsp</sup>)(x-&alpha<sup>i0*rsp+rsp</sup>)(x-&alpha<sup>i0*rsp+2rsp</sup>)... </ul>
where i0 denotes the parameter GENSTART and rsp denotes the parameter ROOTSPACING.
</html>"
}

proc add_module_parametersM {} {
add_parameter  BITSPERSYMBOL INTEGER 8
set_parameter_property BITSPERSYMBOL DISPLAY_NAME "Number of bits per symbol"
set_parameter_property BITSPERSYMBOL ENABLED true
set_parameter_property BITSPERSYMBOL UNITS None
set_parameter_property BITSPERSYMBOL DESCRIPTION "Specifies the total number of bits per symbols"
set_parameter_property BITSPERSYMBOL HDL_PARAMETER true
}
proc add_module_parametersCHECK {} {
add_parameter CHECK INTEGER 16
set_parameter_property CHECK DISPLAY_NAME "Number of check symbols per codeword"
set_parameter_property CHECK ENABLED true
set_parameter_property CHECK UNITS None
set_parameter_property CHECK DESCRIPTION "Check symbols per codeword"
set_parameter_property CHECK HDL_PARAMETER true
}

proc add_module_parametersIRRPOL {} {
add_parameter IRRPOL INTEGER 285 
set_parameter_property IRRPOL DISPLAY_NAME "Field polynomial"
set_parameter_property IRRPOL ENABLED true
set_parameter_property IRRPOL UNITS None
set_parameter_property IRRPOL DESCRIPTION "Primitive Polynomial"
set_parameter_property IRRPOL HDL_PARAMETER true
}

proc add_module_parametersROOT {} {
add_parameter GENSTART INTEGER 0
set_parameter_property GENSTART DISPLAY_NAME "First root of the polynomial generator"
set_parameter_property GENSTART ENABLED true
set_parameter_property GENSTART UNITS None
set_parameter_property GENSTART DESCRIPTION "Specifies the exponent of first root of the polynomial generator"
set_parameter_property GENSTART HDL_PARAMETER true

add_parameter ROOTSPACE INTEGER 1
set_parameter_property ROOTSPACE DISPLAY_NAME "Root spacing in the polynomial generator"
set_parameter_property ROOTSPACE ENABLED true
set_parameter_property ROOTSPACE UNITS None
set_parameter_property ROOTSPACE DESCRIPTION "Specifies the spacing between roots of in the polynomial generator"
set_parameter_property ROOTSPACE HDL_PARAMETER true
}

proc add_module_parametersRS {} {
add_parameter RS string "Encoder"
set_parameter_property RS DISPLAY_NAME "Reed-Solomon"
set_parameter_property RS ENABLED true
set_parameter_property RS UNITS None
set_parameter_property RS DESCRIPTION "Specifies an encoder or a decoder"
set_parameter_property RS DISPLAY_HINT radio
set_parameter_property RS ALLOWED_RANGES {"Encoder" "Decoder"}
set_parameter_property RS GROUP "Module type"
}

proc add_module_parametersERASURE {} {
add_parameter ERASURE INTEGER 0
set_parameter_property ERASURE DISPLAY_NAME "Erasures-supporting decoder"
set_parameter_property ERASURE UNITS None
set_parameter_property ERASURE DESCRIPTION "Decoder can support erasure corrections"
set_parameter_property ERASURE DISPLAY_HINT boolean
set_parameter_property ERASURE HDL_PARAMETER true
set_parameter_property ERASURE LONG_DESCRIPTION "<html>The Reed-Solomon Decoder is able to support erasure correction.
 The decoding is succesful if 2.&#35error + &#35erasure &#8804 n-k
where n-k is the number of parity bit.
</html>"
set_parameter_property ERASURE GROUP "Decoder Option"
}

proc add_module_parametersERRORSYMB {} {
add_parameter ERRORSYMB INTEGER 1
set_parameter_property ERRORSYMB DISPLAY_NAME "Error symbol value"
set_parameter_property ERRORSYMB UNITS None
set_parameter_property ERRORSYMB DESCRIPTION "Decoder returns the erroneous symbols"
set_parameter_property ERRORSYMB DISPLAY_HINT boolean
set_parameter_property ERRORSYMB HDL_PARAMETER true
set_parameter_property ERRORSYMB GROUP "Decoder Status Signals"
}

proc add_module_parametersERRORBITCOUNT {} {
add_parameter ERRORBITCOUNT INTEGER 1
set_parameter_property ERRORBITCOUNT DISPLAY_NAME "Error bit count"
set_parameter_property ERRORBITCOUNT UNITS None
set_parameter_property ERRORBITCOUNT DESCRIPTION "Decoder returns the number of erroneous bits per codeword"
set_parameter_property ERRORBITCOUNT DISPLAY_HINT boolean
set_parameter_property ERRORBITCOUNT HDL_PARAMETER true
set_parameter_property ERRORBITCOUNT GROUP "Decoder Status Signals"
}

proc add_module_parametersERRORSYMBCOUNT {} {
add_parameter ERRORSYMBCOUNT INTEGER 1
set_parameter_property ERRORSYMBCOUNT DISPLAY_NAME "Error symbol count"
set_parameter_property ERRORSYMBCOUNT UNITS None
set_parameter_property ERRORSYMBCOUNT DESCRIPTION "Decoder returns the number of erroneous symbols per codeword"
set_parameter_property ERRORSYMBCOUNT DISPLAY_HINT boolean
set_parameter_property ERRORSYMBCOUNT HDL_PARAMETER true
set_parameter_property ERRORSYMBCOUNT GROUP "Decoder Status Signals"
}

proc add_module_parametersBITCOUNTTYPE {} {
add_parameter BITCOUNTTYPE string "Full"
set_parameter_property BITCOUNTTYPE DISPLAY_NAME "Error bits count format"
set_parameter_property BITCOUNTTYPE UNITS None
set_parameter_property BITCOUNTTYPE DESCRIPTION "Format of the error bit count signal: Full count or Split count"
set_parameter_property BITCOUNTTYPE LONG_DESCRIPTION "<html> <ul>Full: Count the number of erroneous bits, return num_error_bits</ul>
<ul><p>Split: Count the number of error bits 1 corrected to 0, return num_error_bits1</p>
<p>Count the number of error bits 0 corrected to 1, return  num_error_bits0</p></ul></html>"
set_parameter_property BITCOUNTTYPE HDL_PARAMETER true
set_parameter_property BITCOUNTTYPE GROUP "Decoder Status Signals"
set_parameter_property BITCOUNTTYPE ALLOWED_RANGES {"Full" "Split"}
}

proc add_module_parametersCORRECT {} {
    add_module_parametersERASURE
    add_module_parametersCHANNEL
    add_module_parametersM
    add_module_parametersCHECK
}
proc add_module_parametersBM {} {
    add_module_parametersCORRECT 
    add_module_parametersIRRPOL
}
proc add_module_parametersDEC {} {
    add_module_parametersBM 
    add_module_parametersROOT
    add_module_parametersN
}

proc add_module_parametersENC {} {
    add_module_parametersCHANNEL
    add_module_parametersM
    add_module_parametersCHECK
    add_module_parametersIRRPOL
    add_module_parametersROOT
}
proc add_module_parametersSTATUS {} {
    add_module_parametersERRORSYMB
    add_module_parametersERRORSYMBCOUNT
    add_module_parametersERRORBITCOUNT
    add_module_parametersBITCOUNTTYPE
}
proc add_module_parametersTOP {} {
    add_module_parametersRS
    add_module_parametersCHANNEL
    add_module_parametersM
    add_module_parametersN
    add_module_parametersCHECK
    add_module_parametersIRRPOL
    add_module_parametersGENPOLTYPE
    add_module_parametersROOT
    add_module_parametersERASURE
    add_module_parametersSTATUS
}


# |
# +-----------------------------------

# +-----------------------------------
# | Parameter allowed values
# |
proc validateCORRECT {} {
    set bits_per_symbol    [ get_parameter_value BITSPERSYMBOL ]
    set check              [ get_parameter_value CHECK ]

    # Validate value for BITPERSYMBOL 
    set_parameter_property BITSPERSYMBOL ALLOWED_RANGES {3 4 5 6 7 8 9 10 11 12}
         
    # Validate value for CHECK
    set min_check 2
    set max_check [expr int(pow(2,$bits_per_symbol))-1-4]                       
    if { $check<$min_check || $check>$max_check } {
         send_message error "Number of check symbols per codeword is out of range"
    }
    
    # Validate value for CHANNEL
    set_parameter_property CHANNEL ALLOWED_RANGES {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16}  
}
proc validateBM {} {
    validateCORRECT
    set bits_per_symbol    [ get_parameter_value BITSPERSYMBOL ]
    # Validate value for IRRPOLY
    set_parameter_property IRRPOL ALLOWED_RANGES [get_irrpol_allowed_range $bits_per_symbol]
}
proc validateENC {} {
    validateBM
    set bits_per_symbol    [ get_parameter_value BITSPERSYMBOL ]
    set genstart           [ get_parameter_value GENSTART ]
    set rootspace          [ get_parameter_value ROOTSPACE ]
    set check              [ get_parameter_value CHECK ]

    # Validate value for GENSTART
    set min_genstart 0
    set max_genstart [expr int(pow(2,$bits_per_symbol))-2]
    if { $genstart<$min_genstart || $genstart>$max_genstart } {
         send_message error "Exponent of the first root is out of range"
    }

    # Validate value for ROOTSPACE
    set_parameter_property ROOTSPACE ALLOWED_RANGES [get_rootspace_allowed_range $bits_per_symbol]
}
proc validateDEC {} {
    validateENC
    set check              [ get_parameter_value CHECK ]
    set n                  [ get_parameter_value N ]
    set bits_per_symbol    [ get_parameter_value BITSPERSYMBOL ]
    
    # Validate value for N
    set min_default_N [expr $check+2 ] 
    set max_default_N [expr int(pow(2,$bits_per_symbol))-1] 
    if { $n<$min_default_N || $n>$max_default_N } {
        send_message error "Number of symbols per codeword is out of range"
    }
}
proc validateTOP {} {
    set rs                  [ get_parameter_value RS ]
    set errorbitcount       [ get_parameter_value ERRORBITCOUNT ]
    
    if {[string equal $rs "Encoder"]} {   
        set_parameter_property ERASURE ENABLED false
        set_parameter_property N ENABLED false
        set_parameter_property ERRORSYMB ENABLED false
        set_parameter_property ERRORBITCOUNT ENABLED false
        set_parameter_property ERRORSYMBCOUNT ENABLED false
        set_parameter_property BITCOUNTTYPE ENABLED false
    validateENC
    } else {
        set_parameter_property ERASURE ENABLED true
        set_parameter_property N ENABLED true
        set_parameter_property ERRORSYMB ENABLED true
        set_parameter_property ERRORBITCOUNT ENABLED true
        set_parameter_property ERRORSYMBCOUNT ENABLED true
        if {$errorbitcount==0} {
            set_parameter_property BITCOUNTTYPE ENABLED false
        } else {
            set_parameter_property BITCOUNTTYPE ENABLED true
            }
    validateDEC
    }
    
}

# |
# +-----------------------------------




# +-----------------------------------
# | IRRPOL and ROOTSPACE allowed values
# |
proc get_irrpol_allowed_range {bits_per_symbol} {
    
    set irrpol [ list \
                        null \
                        null \
                        null \
                        [ list 11 13 ] \
                        [ list 19 25 ] \
                        [ list 37 41 47 55 59 61 ] \
                        [ list 67 91 97 103 109 115 ] \
                        [ list 131 137 143 145 157 167 171 185 191 193 203 211 213 229 239 241 247 253 ] \
                        [ list 285 299 301 333 351 355 357 361 369 391 397 425 451 463 487 501 ] \
                        [ list 529 539 545 557 563 601 607 617 623 631 637 647 661 675 677 687 695 701 719  721 731 757 761 787 \
                              789 799 803 817 827 847 859 865 875 877 883 895 901 911 949  953 967 971 973 981 985 995 1001 1019 ] \
                        [ list 1033 1051 1063 1069 1125 1135 1153 1163 1221 1239 1255 1267 1279 1293 1305 1315 1329 1341 1347 1367 13870 \
                              1413 1423 1431 1441 1479 1509 1527 1531 1555  1557 1573 1591 1603 1615 1627 1657 1663 1673 1717 1729 1747 1759 \
                              1789 1815 1821 1825 1849 1863 1869  1877 1881 1891 1917 1933 1939 1969 2011 2035 2041 ] \
                        [ list 2053 2071 2091 2093 3005 3017 4073 ] \
                        [ list 4179 5017 6005 7057 8049 8137 ] \
                    ]
    return [lindex $irrpol $bits_per_symbol]
}


proc get_rootspace_allowed_range {bits_per_symbol} {

    set rootspace [ list \
                        null \
                        null \
                        null \
                        [ list   1     2     3     4     5     6] \
                        [ list   1     2     4     7     8    11    13    14] \
                        [ list   1     2     3     4     5     6     7     8     9    10    11    12    13\
                                14    15    16    17    18    19    20    21    22    23    24    25    26\
                                27    28    29    30     ] \
                        [ list   1     2     4     5     8    10    11    13    16    17    19    20    22\
                                23    25    26    29    31    32    34    37    38    40    41    43    44\
                                46    47    50    52    53    55    58    59    61    62     ] \
                        [ list   1     2     3     4     5     6     7     8     9    10    11    12    13\
                                14    15    16    17    18    19    20    21    22    23    24    25    26\
                                27    28    29    30    31    32    33    34    35    36    37    38    39\
                                40    41    42    43    44    45    46    47    48    49    50    51    52\
                                53    54    55    56    57    58    59    60    61    62    63    64    65\
                                66    67    68    69    70    71    72    73    74    75    76    77    78\
                                79    80    81    82    83    84    85    86    87    88    89    90    91\
                                92    93    94    95    96    97    98    99   100   101   102   103   104\
                               105   106   107   108   109   110   111   112   113   114   115   116   117\
                               118   119   120   121   122   123   124   125   126     ] \
                        [ list   1     2     4     7     8    11    13    14    16    19    22    23    26\
                                28    29    31    32    37    38    41    43    44    46    47    49    52\
                                53    56    58    59    61    62    64    67    71    73    74    76    77\
                                79    82    83    86    88    89    91    92    94    97    98   101   103\
                               104   106   107   109   112   113   116   118   121   122   124   127   128\
                               131   133   134   137   139   142   143   146   148   149   151   152   154\
                               157   158   161   163   164   166   167   169   172   173   176   178   179\
                               181   182   184   188   191   193   194   196   197   199   202   203   206\
                               208   209   211   212   214   217   218   223   224   226   227   229   232\
                               233   236   239   241   242   244   247   248   251   253   254     ] \
                        [ list   1     2     3     4     5     6     8     9    10    11    12    13    15\
                                16    17    18    19    20    22    23    24    25    26    27    29    30\
                                31    32    33    34    36    37    38    39    40    41    43    44    45\
                                46    47    48    50    51    52    53    54    55    57    58    59    60\
                                61    62    64    65    66    67    68    69    71    72    74    75    76\
                                78    79    80    81    82    83    85    86    87    88    89    90    92\
                                93    94    95    96    97    99   100   101   102   103   104   106   107\
                               108   109   110   111   113   114   115   116   117   118   120   121   122\
                               123   124   125   127   128   129   130   131   132   134   135   136   137\
                               138   139   141   142   143   144   145   148   149   150   151   152   153\
                               155   156   157   158   159   160   162   163   164   165   166   167   169\
                               170   171   172   173   174   176   177   178   179   180   181   183   184\
                               185   186   187   188   190   191   192   193   194   195   197   198   199\
                               200   201   202   204   205   206   207   208   209   211   212   213   214\
                               215   216   218   220   221   222   223   225   226   227   228   229   230\
                               232   233   234   235   236   237   239   240   241   242   243   244   246\
                               247   248   249   250   251   253   254   255   256   257   258   260   261\
                               262   263   264   265   267   268   269   270   271   272   274   275   276\
                               277   278   279   281   282   283   284   285   286   288   289   290   291\
                               293   295   296   297   298   299   300   302   303   304   305   306   307\
                               309   310   311   312   313   314   316   317   318   319   320   321   323\
                               324   325   326   327   328   330   331   332   333   334   335   337   338\
                               339   340   341   342   344   345   346   347   348   349   351   352   353\
                               354   355   356   358   359   360   361   362   363   366   367   368   369\
                               370   372   373   374   375   376   377   379   380   381   382   383   384\
                               386   387   388   389   390   391   393   394   395   396   397   398   400\
                               401   402   403   404   405   407   408   409   410   411   412   414   415\
                               416   417   418   419   421   422   423   424   425   426   428   429   430\
                               431   432   433   435   436   437   439   440   442   443   444   445   446\
                               447   449   450   451   452   453   454   456   457   458   459   460   461\
                               463   464   465   466   467   468   470   471   472   473   474   475   477\
                               478   479   480   481   482   484   485   486   487   488   489   491   492\
                               493   494   495   496   498   499   500   501   502   503   505   506   507\
                               508   509   510     ] \
                        [ list     1           2           4           5           7           8          10          13          14          16          17          19          20\
                                  23          25          26          28          29          32          34          35          37          38          40          41          43\
                                  46          47          49          50          52          53          56          58          59          61          64          65          67\
                                  68          70          71          73          74          76          79          80          82          83          85          86          89\
                                  91          92          94          95          97          98         100         101         103         104         106         107         109\
                                 112         113         115         116         118         119         122         125         127         128         130         131         133\
                                 134         136         137         139         140         142         145         146         148         149         151         152         157\
                                 158         160         161         163         164         166         167         169         170         172         173         175         178\
                                 179         181         182         184         185         188         190         191         193         194         196         197         199\
                                 200         202         203         205         206         208         211         212         214         215         218         221         223\
                                 224         226         227         229         230         232         233         235         236         238         239         241         244\
                                 245         247         250         251         254         256         257         259         260         262         263         265         266\
                                 268         269         271         272         274         277         278         280         281         283         284         287         289\
                                 290         292         293         295         296         298         299         301         302         304         305         307         311\
                                 313         314         316         317         320         322         323         325         326         328         329         331         332\
                                 334         335         337         338         340         343         344         346         347         349         350         353         355\
                                 356         358         359         361         362         364         365         367         368         370         371         373         376\
                                 377         379         380         382         383         386         388         389         391         392         394         395         397\
                                 398         400         401         404         406         409         410         412         413         415         416         419         421\
                                 422         424         425         427         428         430         431         433         436         437         439         442         443\
                                 445         446         448         449         452         454         455         457         458         460         461         463         464\
                                 466         467         469         470         472         475         476         478         479         481         482         485         487\
                                 488         490         491         493         494         497         499         500         502         503         505         508         509\
                                 511         512         514         515         518         520         521         523         524         526         529         530         532\
                                 533         535         536         538         541         542         544         545         547         548         551         553         554\
                                 556         557         559         560         562         563         565         566         568         569         571         574         575\
                                 577         578         580         581         584         586         587         590         592         593         595         596         598\
                                 599         601         602         604         607         608         610         611         613         614         617         619         622\
                                 623         625         626         628         629         631         632         634         635         637         640         641         643\
                                 644         646         647         650         652         653         655         656         658         659         661         662         664\
                                 665         667         668         670         673         674         676         677         679         680         683         685         686\
                                 688         689         691         692         694         695         697         698         700         701         703         706         707\
                                 709         710         712         716         718         719         721         722         724         725         727         728         730\
                                 731         733         734         736         739         740         742         743         745         746         749         751         752\
                                 754         755         757         758         760         761         763         764         766         767         769         772         773\
                                 776         778         779         782         784         785         787         788         790         791         793         794         796\
                                 797         799         800         802         805         808         809         811         812         815         817         818         820\
                                 821         823         824         826         827         829         830         832         833         835         838         839         841\
                                 842         844         845         848         850         851         853         854         856         857         859         860         862\
                                 863         865         866         871         872         874         875         877         878         881         883         884         886\
                                 887         889         890         892         893         895         896         898         901         904         905         907         908\
                                 910         911         914         916         917         919         920         922         923         925         926         928         929\
                                 931         932         934         937         938         940         941         943         944         947         949         950         952\
                                 953         955         956         958         959         962         964         965         967         970         971         973         974\
                                 976         977         980         982         983         985         986         988         989         991         994         995         997\
                                 998        1000        1003        1004        1006        1007        1009        1010        1013        1015        1016        1018        1019\
                                1021        1022          ] \
                        [ list     1           2           3           4           5           6           7           8           9          10          11          12          13\
                                  14          15          16          17          18          19          20          21          22          24          25          26          27\
                                  28          29          30          31          32          33          34          35          36          37          38          39          40\
                                  41          42          43          44          45          47          48          49          50          51          52          53          54\
                                  55          56          57          58          59          60          61          62          63          64          65          66          67\
                                  68          70          71          72          73          74          75          76          77          78          79          80          81\
                                  82          83          84          85          86          87          88          90          91          93          94          95          96\
                                  97          98          99         100         101         102         103         104         105         106         107         108         109\
                                 110         111         112         113         114         116         117         118         119         120         121         122         123\
                                 124         125         126         127         128         129         130         131         132         133         134         135         136\
                                 137         139         140         141         142         143         144         145         146         147         148         149         150\
                                 151         152         153         154         155         156         157         158         159         160         162         163         164\
                                 165         166         167         168         169         170         171         172         173         174         175         176         177\
                                 179         180         181         182         183         185         186         187         188         189         190         191         192\
                                 193         194         195         196         197         198         199         200         201         202         203         204         205\
                                 206         208         209         210         211         212         213         214         215         216         217         218         219\
                                 220         221         222         223         224         225         226         227         228         229         231         232         233\
                                 234         235         236         237         238         239         240         241         242         243         244         245         246\
                                 247         248         249         250         251         252         254         255         256         257         258         259         260\
                                 261         262         263         264         265         266         268         269         270         271         272         273         274\
                                 275         277         278         279         280         281         282         283         284         285         286         287         288\
                                 289         290         291         292         293         294         295         296         297         298         300         301         302\
                                 303         304         305         306         307         308         309         310         311         312         313         314         315\
                                 316         317         318         319         320         321         323         324         325         326         327         328         329\
                                 330         331         332         333         334         335         336         337         338         339         340         341         342\
                                 343         344         346         347         348         349         350         351         352         353         354         355         357\
                                 358         359         360         361         362         363         364         365         366         367         369         370         371\
                                 372         373         374         375         376         377         378         379         380         381         382         383         384\
                                 385         386         387         388         389         390         392         393         394         395         396         397         398\
                                 399         400         401         402         403         404         405         406         407         408         409         410         411\
                                 412         413         415         416         417         418         419         420         421         422         423         424         425\
                                 426         427         428         429         430         431         432         433         434         435         436         438         439\
                                 440         441         442         443         444         446         447         448         449         450         451         452         453\
                                 454         455         456         457         458         459         461         462         463         464         465         466         467\
                                 468         469         470         471         472         473         474         475         476         477         478         479         480\
                                 481         482         484         485         486         487         488         489         490         491         492         493         494\
                                 495         496         497         498         499         500         501         502         503         504         505         507         508\
                                 509         510         511         512         513         514         515         516         517         518         519         520         521\
                                 522         523         524         525         526         527         528         530         531         532         533         535         536\
                                 537         538         539         540         541         542         543         544         545         546         547         548         549\
                                 550         551         553         554         555         556         557         558         559         560         561         562         563\
                                 564         565         566         567         568         569         570         571         572         573         574         576         577\
                                 578         579         580         581         582         583         584         585         586         587         588         589         590\
                                 591         592         593         594         595         596         597         599         600         601         602         603         604\
                                 605         606         607         608         609         610         611         612         613         614         615         616         617\
                                 618         619         620         622         624         625         626         627         628         629         630         631         632\
                                 633         634         635         636         637         638         639         640         641         642         643         645         646\
                                 647         648         649         650         651         652         653         654         655         656         657         658         659\
                                 660         661         662         663         664         665         666         668         669         670         671         672         673\
                                 674         675         676         677         678         679         680         681         682         683         684         685         686\
                                 687         688         689         691         692         693         694         695         696         697         698         699         700\
                                 701         702         703         704         705         706         707         708         709         710         711         714         715\
                                 716         717         718         719         720         721         722         723         724         725         726         727         728\
                                 729         730         731         732         733         734         735         737         738         739         740         741         742\
                                 743         744         745         746         747         748         749         750         751         752         753         754         755\
                                 756         757         758         760         761         762         763         764         765         766         767         768         769\
                                 770         771         772         773         774         775         776         777         778         779         780         781         783\
                                 784         785         786         787         788         789         790         791         792         793         794         795         796\
                                 797         798         799         800         802         803         804         806         807         808         809         810         811\
                                 812         813         814         815         816         817         818         819         820         821         822         823         824\
                                 825         826         827         829         830         831         832         833         834         835         836         837         838\
                                 839         840         841         842         843         844         845         846         847         848         849         850         852\
                                 853         854         855         856         857         858         859         860         861         862         863         864         865\
                                 866         867         868         869         870         871         872         873         875         876         877         878         879\
                                 880         881         882         883         884         885         886         887         888         889         891         892         893\
                                 894         895         896         898         899         900         901         902         903         904         905         906         907\
                                 908         909         910         911         912         913         914         915         916         917         918         919         921\
                                 922         923         924         925         926         927         928         929         930         931         932         933         934\
                                 935         936         937         938         939         940         941         942         944         945         946         947         948\
                                 949         950         951         952         953         954         955         956         957         958         959         960         961\
                                 962         963         964         965         967         968         969         970         971         972         973         974         975\
                                 976         977         978         980         981         982         983         984         985         986         987         988         990\
                                 991         992         993         994         995         996         997         998         999        1000        1001        1002        1003\
                                1004        1005        1006        1007        1008        1009        1010        1011        1013        1014        1015        1016        1017\
                                1018        1019        1020        1021        1022        1023        1024        1025        1026        1027        1028        1029        1030\
                                1031        1032        1033        1034        1036        1037        1038        1039        1040        1041        1042        1043        1044\
                                1045        1046        1047        1048        1049        1050        1051        1052        1053        1054        1055        1056        1057\
                                1059        1060        1061        1062        1063        1064        1065        1066        1067        1069        1070        1071        1072\
                                1073        1074        1075        1076        1077        1078        1079        1080        1082        1083        1084        1085        1086\
                                1087        1088        1089        1090        1091        1092        1093        1094        1095        1096        1097        1098        1099\
                                1100        1101        1102        1103        1105        1106        1107        1108        1109        1110        1111        1112        1113\
                                1114        1115        1116        1117        1118        1119        1120        1121        1122        1123        1124        1125        1126\
                                1128        1129        1130        1131        1132        1133        1134        1135        1136        1137        1138        1139        1140\
                                1141        1142        1143        1144        1145        1146        1147        1148        1149        1151        1152        1153        1154\
                                1155        1156        1158        1159        1160        1161        1162        1163        1164        1165        1166        1167        1168\
                                1169        1170        1171        1172        1174        1175        1176        1177        1178        1179        1180        1181        1182\
                                1183        1184        1185        1186        1187        1188        1189        1190        1191        1192        1193        1194        1195\
                                1197        1198        1199        1200        1201        1202        1203        1204        1205        1206        1207        1208        1209\
                                1210        1211        1212        1213        1214        1215        1216        1217        1218        1220        1221        1222        1223\
                                1224        1225        1226        1227        1228        1229        1230        1231        1232        1233        1234        1235        1236\
                                1237        1238        1239        1240        1241        1243        1244        1245        1247        1248        1249        1250        1251\
                                1252        1253        1254        1255        1256        1257        1258        1259        1260        1261        1262        1263        1264\
                                1266        1267        1268        1269        1270        1271        1272        1273        1274        1275        1276        1277        1278\
                                1279        1280        1281        1282        1283        1284        1285        1286        1287        1289        1290        1291        1292\
                                1293        1294        1295        1296        1297        1298        1299        1300        1301        1302        1303        1304        1305\
                                1306        1307        1308        1309        1310        1312        1313        1314        1315        1316        1317        1318        1319\
                                1320        1321        1322        1323        1324        1325        1326        1327        1328        1329        1330        1331        1332\
                                1333        1336        1337        1338        1339        1340        1341        1342        1343        1344        1345        1346        1347\
                                1348        1349        1350        1351        1352        1353        1354        1355        1356        1358        1359        1360        1361\
                                1362        1363        1364        1365        1366        1367        1368        1369        1370        1371        1372        1373        1374\
                                1375        1376        1377        1378        1379        1381        1382        1383        1384        1385        1386        1387        1388\
                                1389        1390        1391        1392        1393        1394        1395        1396        1397        1398        1399        1400        1401\
                                1402        1404        1405        1406        1407        1408        1409        1410        1411        1412        1413        1414        1415\
                                1416        1417        1418        1419        1420        1421        1422        1423        1425        1427        1428        1429        1430\
                                1431        1432        1433        1434        1435        1436        1437        1438        1439        1440        1441        1442        1443\
                                1444        1445        1446        1447        1448        1450        1451        1452        1453        1454        1455        1456        1457\
                                1458        1459        1460        1461        1462        1463        1464        1465        1466        1467        1468        1469        1470\
                                1471        1473        1474        1475        1476        1477        1478        1479        1480        1481        1482        1483        1484\
                                1485        1486        1487        1488        1489        1490        1491        1492        1493        1494        1496        1497        1498\
                                1499        1500        1501        1502        1503        1504        1505        1506        1507        1508        1509        1510        1511\
                                1512        1514        1515        1516        1517        1519        1520        1521        1522        1523        1524        1525        1526\
                                1527        1528        1529        1530        1531        1532        1533        1534        1535        1536        1537        1538        1539\
                                1540        1542        1543        1544        1545        1546        1547        1548        1549        1550        1551        1552        1553\
                                1554        1555        1556        1557        1558        1559        1560        1561        1562        1563        1565        1566        1567\
                                1568        1569        1570        1571        1572        1573        1574        1575        1576        1577        1578        1579        1580\
                                1581        1582        1583        1584        1585        1586        1588        1589        1590        1591        1592        1593        1594\
                                1595        1596        1597        1598        1599        1600        1601        1603        1604        1605        1606        1607        1608\
                                1609        1611        1612        1613        1614        1615        1616        1617        1618        1619        1620        1621        1622\
                                1623        1624        1625        1626        1627        1628        1629        1630        1631        1632        1634        1635        1636\
                                1637        1638        1639        1640        1641        1642        1643        1644        1645        1646        1647        1648        1649\
                                1650        1651        1652        1653        1654        1655        1657        1658        1659        1660        1661        1662        1663\
                                1664        1665        1666        1667        1668        1669        1670        1671        1672        1673        1674        1675        1676\
                                1677        1678        1680        1681        1682        1683        1684        1685        1686        1687        1688        1689        1690\
                                1692        1693        1694        1695        1696        1697        1698        1699        1700        1701        1703        1704        1705\
                                1706        1707        1708        1709        1710        1711        1712        1713        1714        1715        1716        1717        1718\
                                1719        1720        1721        1722        1723        1724        1726        1727        1728        1729        1730        1731        1732\
                                1733        1734        1735        1736        1737        1738        1739        1740        1741        1742        1743        1744        1745\
                                1746        1747        1749        1750        1751        1752        1753        1754        1755        1756        1757        1758        1759\
                                1760        1761        1762        1763        1764        1765        1766        1767        1768        1769        1770        1772        1773\
                                1774        1775        1776        1777        1778        1779        1781        1782        1783        1784        1785        1786        1787\
                                1788        1789        1790        1791        1792        1793        1795        1796        1797        1798        1799        1800        1801\
                                1802        1803        1804        1805        1806        1807        1808        1809        1810        1811        1812        1813        1814\
                                1815        1816        1818        1819        1820        1821        1822        1823        1824        1825        1826        1827        1828\
                                1829        1830        1831        1832        1833        1834        1835        1836        1837        1838        1839        1841        1842\
                                1843        1844        1845        1846        1847        1848        1849        1850        1851        1852        1853        1854        1855\
                                1856        1857        1858        1859        1860        1861        1862        1864        1865        1866        1867        1868        1870\
                                1871        1872        1873        1874        1875        1876        1877        1878        1879        1880        1881        1882        1883\
                                1884        1885        1887        1888        1889        1890        1891        1892        1893        1894        1895        1896        1897\
                                1898        1899        1900        1901        1902        1903        1904        1905        1906        1907        1908        1910        1911\
                                1912        1913        1914        1915        1916        1917        1918        1919        1920        1921        1922        1923        1924\
                                1925        1926        1927        1928        1929        1930        1931        1933        1934        1935        1936        1937        1938\
                                1939        1940        1941        1942        1943        1944        1945        1946        1947        1948        1949        1950        1951\
                                1952        1953        1954        1956        1957        1959        1960        1961        1962        1963        1964        1965        1966\
                                1967        1968        1969        1970        1971        1972        1973        1974        1975        1976        1977        1979        1980\
                                1981        1982        1983        1984        1985        1986        1987        1988        1989        1990        1991        1992        1993\
                                1994        1995        1996        1997        1998        1999        2000        2002        2003        2004        2005        2006        2007\
                                2008        2009        2010        2011        2012        2013        2014        2015        2016        2017        2018        2019        2020\
                                2021        2022        2023        2025        2026        2027        2028        2029        2030        2031        2032        2033        2034\
                                2035        2036        2037        2038        2039        2040        2041        2042        2043        2044        2045        2046           ]\
                        [ list     1           2           4           8          11          16          17          19          22          23          29          31          32\
                                  34          37          38          41          43          44          46          47          53          58          59          61          62\
                                  64          67          68          71          73          74          76          79          82          83          86          88          89\
                                  92          94          97         101         103         106         107         109         113         116         118         121         122\
                                 124         127         128         131         134         136         137         139         142         146         148         149         151\
                                 152         157         158         163         164         166         167         172         173         176         178         179         181\
                                 184         187         188         191         193         194         197         199         202         206         209         211         212\
                                 214         218         223         226         227         229         232         233         236         239         241         242         244\
                                 248         251         253         254         256         257         262         263         268         269         271         272         274\
                                 277         278         281         283         284         289         292         293         296         298         302         304         307\
                                 311         313         314         316         317         319         323         326         328         331         332         334         337\
                                 341         344         346         347         349         352         353         356         358         359         361         362         367\
                                 368         373         374         376         379         382         383         386         388         389         391         394         397\
                                 398         401         404         407         409         412         418         419         421         422         424         428         431\
                                 433         436         437         439         443         446         449         451         452         454         457         458         461\
                                 463         464         466         467         472         473         478         479         482         484         487         488         491\
                                 493         496         499         502         503         506         508         509         512         514         517         521         523\
                                 524         526         527         529         536         538         541         542         544         547         548         551         554\
                                 556         557         562         563         566         568         569         571         577         578         583         584         586\
                                 587         589         592         593         596         599         601         604         607         608         613         614         617\
                                 619         622         626         628         629         631         632         634         638         641         643         646         647\
                                 649         652         653         656         659         661         662         664         667         668         671         673         674\
                                 677         682         683         688         691         692         694         697         698         701         703         704         706\
                                 709         712         713         716         718         719         722         724         727         731         733         734         736\
                                 737         739         743         746         748         751         752         757         758         761         764         766         769\
                                 772         773         776         778         779         781         782         787         788         794         796         797         799\
                                 802         803         808         809         811         814         817         818         821         823         824         827         829\
                                 836         838         839         841         842         844         848         851         853         856         857         859         862\
                                 863         866         869         872         874         877         878         881         883         886         887         892         893\
                                 898         899         901         902         904         907         908         911         913         914         916         919         922\
                                 926         928         929         932         934         937         941         943         944         946         947         953         956\
                                 958         961         964         967         968         971         974         976         977         979         982         983         986\
                                 989         991         992         997         998        1003        1004        1006        1007        1009        1012        1013        1016\
                                1018        1019        1021        1024        1028        1031        1033        1034        1037        1039        1042        1046        1048\
                                1049        1051        1052        1054        1058        1061        1063        1067        1069        1072        1073        1076        1081\
                                1082        1084        1087        1088        1091        1093        1094        1096        1097        1102        1103        1108        1109\
                                1111        1112        1114        1117        1121        1123        1124        1126        1129        1132        1133        1136        1138\
                                1139        1142        1147        1151        1153        1154        1156        1159        1163        1166        1168        1171        1172\
                                1174        1177        1178        1181        1184        1186        1187        1189        1192        1193        1198        1199        1201\
                                1202        1207        1208        1213        1214        1216        1217        1219        1223        1226        1228        1229        1231\
                                1234        1237        1238        1241        1243        1244        1247        1249        1252        1256        1258        1259        1262\
                                1264        1268        1271        1273        1276        1277        1279        1282        1283        1286        1289        1291        1292\
                                1294        1297        1298        1301        1303        1304        1306        1307        1312        1318        1319        1321        1322\
                                1324        1327        1328        1331        1333        1334        1336        1342        1343        1346        1348        1349        1354\
                                1357        1361        1363        1364        1366        1367        1369        1373        1376        1381        1382        1384        1387\
                                1388        1394        1396        1397        1399        1402        1403        1406        1408        1409        1411        1412        1418\
                                1423        1424        1426        1427        1429        1432        1433        1436        1438        1439        1441        1444        1447\
                                1448        1451        1453        1454        1457        1459        1462        1466        1468        1471        1472        1474        1478\
                                1481        1483        1486        1487        1489        1492        1493        1496        1499        1501        1502        1504        1507\
                                1511        1513        1514        1516        1517        1522        1523        1528        1529        1531        1532        1537        1538\
                                1541        1543        1544        1546        1549        1552        1553        1556        1558        1559        1562        1564        1567\
                                1571        1574        1576        1577        1579        1583        1588        1591        1592        1594        1597        1598        1601\
                                1604        1606        1607        1609        1613        1616        1618        1619        1621        1622        1627        1628        1633\
                                1634        1636        1637        1639        1642        1643        1646        1648        1649        1654        1657        1658        1661\
                                1663        1667        1669        1672        1676        1678        1679        1681        1682        1684        1688        1691        1693\
                                1696        1697        1699        1702        1706        1709        1711        1712        1714        1717        1718        1721        1723\
                                1724        1726        1727        1732        1733        1738        1739        1741        1744        1747        1748        1751        1753\
                                1754        1756        1759        1762        1763        1766        1769        1772        1774        1777        1783        1784        1786\
                                1787        1789        1793        1796        1798        1801        1802        1804        1808        1811        1814        1816        1817\
                                1819        1822        1823        1826        1828        1829        1831        1832        1837        1838        1843        1844        1847\
                                1849        1852        1853        1856        1858        1861        1864        1867        1868        1871        1873        1874        1877\
                                1879        1882        1886        1888        1889        1891        1892        1894        1901        1903        1906        1907        1909\
                                1912        1913        1916        1919        1921        1922        1927        1928        1931        1933        1934        1936        1942\
                                1943        1948        1949        1951        1952        1954        1957        1958        1961        1964        1966        1969        1972\
                                1973        1978        1979        1982        1984        1987        1991        1993        1994        1996        1997        1999        2003\
                                2006        2008        2011        2012        2014        2017        2018        2021        2024        2026        2027        2029        2032\
                                2033        2036        2038        2039        2042        2047        2048        2053        2056        2057        2059        2062        2063\
                                2066        2068        2069        2071        2074        2077        2078        2081        2083        2084        2087        2089        2092\
                                2096        2098        2099        2101        2102        2104        2108        2111        2113        2116        2117        2122        2123\
                                2126        2129        2131        2134        2137        2138        2141        2143        2144        2146        2147        2152        2153\
                                2159        2161        2162        2164        2167        2168        2173        2174        2176        2179        2182        2183        2186\
                                2188        2189        2192        2194        2201        2203        2204        2206        2207        2209        2213        2216        2218\
                                2221        2222        2224        2227        2228        2231        2234        2237        2239        2242        2243        2246        2248\
                                2251        2252        2257        2258        2263        2264        2266        2267        2269        2272        2273        2276        2278\
                                2279        2281        2284        2287        2291        2293        2294        2297        2299        2302        2306        2308        2309\
                                2311        2312        2318        2321        2323        2326        2329        2332        2333        2336        2339        2341        2342\
                                2344        2347        2348        2351        2354        2356        2357        2362        2363        2368        2369        2371        2372\
                                2374        2377        2378        2381        2383        2384        2386        2389        2393        2396        2398        2399        2402\
                                2404        2407        2411        2413        2414        2416        2417        2419        2423        2426        2428        2432        2434\
                                2437        2438        2441        2446        2447        2449        2452        2453        2456        2458        2459        2461        2462\
                                2467        2468        2473        2474        2476        2477        2479        2482        2486        2488        2489        2491        2494\
                                2497        2498        2501        2503        2504        2507        2512        2516        2518        2519        2521        2524        2528\
                                2531        2533        2536        2537        2539        2542        2543        2546        2549        2551        2552        2554        2557\
                                2558        2563        2564        2566        2567        2572        2573        2578        2579        2581        2582        2584        2588\
                                2591        2593        2594        2596        2599        2602        2603        2606        2608        2609        2612        2614        2617\
                                2621        2623        2624        2627        2629        2633        2636        2638        2641        2642        2644        2647        2648\
                                2651        2654        2656        2657        2659        2662        2663        2666        2668        2669        2671        2672        2677\
                                2683        2684        2686        2687        2689        2692        2693        2696        2698        2699        2701        2707        2708\
                                2711        2713        2714        2719        2722        2726        2728        2729        2731        2732        2734        2738        2741\
                                2746        2747        2749        2752        2753        2759        2761        2762        2764        2767        2768        2771        2773\
                                2774        2776        2777        2783        2788        2789        2791        2792        2794        2797        2798        2801        2803\
                                2804        2806        2809        2812        2813        2816        2818        2819        2822        2824        2827        2831        2833\
                                2836        2837        2839        2843        2846        2848        2851        2852        2854        2857        2858        2861        2864\
                                2866        2867        2869        2872        2876        2878        2879        2881        2882        2887        2888        2893        2894\
                                2896        2897        2902        2903        2906        2908        2909        2911        2914        2917        2918        2921        2923\
                                2924        2927        2929        2932        2936        2939        2941        2942        2944        2948        2953        2956        2957\
                                2959        2962        2963        2966        2969        2971        2972        2974        2978        2981        2983        2984        2986\
                                2987        2992        2993        2998        2999        3001        3002        3004        3007        3008        3011        3013        3014\
                                3019        3022        3023        3026        3028        3032        3034        3037        3041        3043        3044        3046        3047\
                                3049        3053        3056        3058        3061        3062        3064        3067        3071        3074        3076        3077        3079\
                                3082        3083        3086        3088        3089        3091        3092        3097        3098        3103        3104        3106        3109\
                                3112        3113        3116        3118        3119        3121        3124        3127        3128        3131        3134        3137        3139\
                                3142        3148        3149        3151        3152        3154        3158        3161        3163        3166        3167        3169        3173\
                                3176        3179        3181        3182        3184        3187        3188        3191        3193        3194        3196        3197        3202\
                                3203        3208        3209        3212        3214        3217        3218        3221        3223        3226        3229        3232        3233\
                                3236        3238        3239        3242        3244        3247        3251        3253        3254        3256        3257        3259        3266\
                                3268        3271        3272        3274        3277        3278        3281        3284        3286        3287        3292        3293        3296\
                                3298        3299        3301        3307        3308        3313        3314        3316        3317        3319        3322        3323        3326\
                                3329        3331        3334        3337        3338        3343        3344        3347        3349        3352        3356        3358        3359\
                                3361        3362        3364        3368        3371        3373        3376        3377        3379        3382        3383        3386        3389\
                                3391        3392        3394        3397        3398        3401        3403        3404        3407        3412        3413        3418        3421\
                                3422        3424        3427        3428        3431        3433        3434        3436        3439        3442        3443        3446        3448\
                                3449        3452        3454        3457        3461        3463        3464        3466        3467        3469        3473        3476        3478\
                                3481        3482        3487        3488        3491        3494        3496        3499        3502        3503        3506        3508        3509\
                                3511        3512        3517        3518        3524        3526        3527        3529        3532        3533        3538        3539        3541\
                                3544        3547        3548        3551        3553        3554        3557        3559        3566        3568        3569        3571        3572\
                                3574        3578        3581        3583        3586        3587        3589        3592        3593        3596        3599        3602        3604\
                                3607        3608        3611        3613        3616        3617        3622        3623        3628        3629        3631        3632        3634\
                                3637        3638        3641        3643        3644        3646        3649        3652        3656        3658        3659        3662        3664\
                                3667        3671        3673        3674        3676        3677        3683        3686        3688        3691        3694        3697        3698\
                                3701        3704        3706        3707        3709        3712        3713        3716        3719        3721        3722        3727        3728\
                                3733        3734        3736        3737        3739        3742        3743        3746        3748        3749        3751        3754        3758\
                                3761        3763        3764        3767        3769        3772        3776        3778        3779        3781        3782        3784        3788\
                                3791        3793        3797        3799        3802        3803        3806        3811        3812        3814        3817        3818        3821\
                                3823        3824        3826        3827        3832        3833        3838        3839        3841        3842        3844        3847        3851\
                                3853        3854        3856        3859        3862        3863        3866        3868        3869        3872        3877        3881        3883\
                                3884        3886        3889        3893        3896        3898        3901        3902        3904        3907        3908        3911        3914\
                                3916        3917        3919        3922        3923        3928        3929        3931        3932        3937        3938        3943        3944\
                                3946        3947        3949        3953        3956        3958        3959        3961        3964        3967        3968        3971        3973\
                                3974        3977        3979        3982        3986        3988        3989        3992        3994        3998        4001        4003        4006\
                                4007        4009        4012        4013        4016        4019        4021        4022        4024        4027        4028        4031        4033\
                                4034        4036        4037        4042        4048        4049        4051        4052        4054        4057        4058        4061        4063\
                                4064        4066        4072        4073        4076        4078        4079        4084        4087        4091        4093        4094           ] \
                    ]
    return [lindex $rootspace $bits_per_symbol]
}

proc add_filesets {top_level} {
    foreach fileset {quartus_synth sim_verilog sim_vhdl} {
        add_fileset $fileset [string toupper $fileset] "generate_$fileset"
        set_fileset_property $fileset TOP_LEVEL $top_level
    }
}

proc generate_quartus_synth {entity} {
    generate synth
}

proc generate_sim_verilog {entity} {
    generate sim
}

proc generate_sim_vhdl {entity} {
    generate sim
}

proc add_rs_package {type base_dir} {
    set simulator_list { \
                         {mentor   1   } \
                         {aldec    1    } \
                         {synopsys 0 } \
                         {cadence  0  } \
                       }
    add_encrypted_file $type "altera_rs_ii_pkg.sv" "$base_dir/lib" $simulator_list
}

proc add_encrypted_file {type filename {path "."} {simulator_list ""}} {
    if {$simulator_list == ""} {
        set simulator_list [get_simulator_list]
    }
    set is_ocp [string equal [file extension $filename] ".ocp"]
    if {$type == "sim"} {
        if {$is_ocp} {
            return
        }
        set added 0
        foreach simulator $simulator_list {
            set sim [lindex $simulator 0]
            set supported [lindex $simulator 1]
            if {$supported} {
                set specific "[string toupper $sim]_SPECIFIC"
                add_fileset_file $sim/$filename SYSTEM_VERILOG_ENCRYPT PATH $path/$sim/$filename $specific
                set added 1
            }
        }
        if {! $added} {
            add_fileset_file $filename SYSTEM_VERILOG PATH $path/$filename
        }
    } else {
        if {$is_ocp} {
            add_fileset_file $filename OTHER PATH $path/$filename
        } else {
            add_fileset_file $filename SYSTEM_VERILOG PATH $path/$filename
        }
    }
}
