#-------------------------------------------------------------------------------
proc checkValues {} {
  global opt buttons appNames appName developer userEntityList allNone useXL developer
  global edmWriteToFile edmWhereRules eeWriteToFile
  
  set butNormal {}
  set butDisabled {}

  if {[info exists buttons(appCombo)]} {
    set ic [lsearch $appNames $appName]
    if {$ic < 0} {set ic 0}
    catch {$buttons(appCombo) current $ic}

# Jotne EDM Model Checker
    if {$developer} {
      catch {
        if {[string first "EDM Model Checker" $appName] == 0} {
          pack $buttons(edmWriteToFile) -side left -anchor w -padx 5
          pack $buttons(edmWhereRules) -side left -anchor w -padx 5
        } else {
          pack forget $buttons(edmWriteToFile)
          pack forget $buttons(edmWhereRules)
        }
      }
    }

# STEP Tools
    catch {
      if {[string first "Conformance Checker" $appName] != -1} {
        pack $buttons(eeWriteToFile) -side left -anchor w -padx 5
      } else {
        pack forget $buttons(eeWriteToFile)
      }
    }
    
    catch {
      if {$appName == "Tree View (for debugging)"} {
        pack $buttons(indentGeometry) -side left -anchor w -padx 5
        pack $buttons(indentStyledItem) -side left -anchor w -padx 5
      } else {
        pack forget $buttons(indentGeometry)
        pack forget $buttons(indentStyledItem)
      }
    }
  }

# configure Excel, CSV, Viz only, Excel or not
  if {$opt(XLSCSV) == "Excel"} {
    catch {$buttons(genExcel) configure -text "Generate Spreadsheet"}
  } elseif {$opt(XLSCSV) == "CSV"} {
    catch {$buttons(genExcel) configure -text "Generate CSV Files"}
  } elseif {$opt(XLSCSV) == "None"} {
    catch {$buttons(genExcel) configure -text "Generate View"}
  }
  if {![info exists useXL]} {set useXL 1}

# no Excel
  if {!$useXL} {
    foreach item {INVERSE PMIGRF PMISEM VALPROP writeDirType} {set opt($item) 0}
    set opt(XL_OPEN) 1
    foreach item [array names opt] {
      if {[string first "PR_STEP" $item] == 0} {lappend butNormal "opt$item"}
    }
    foreach b {optINVERSE optPMIGRF optPMISEM optVALPROP optXL_FPREC optXL_KEEPOPEN optXL_LINK1 optXL_SORT allNone2} {lappend butDisabled $b}
    foreach b {optVIZFEA optVIZPMI optVIZTPG optVIZBRP} {lappend butNormal $b}
    foreach b {allNone0 allNone1 allNone3 optPR_USER} {lappend butNormal $b}

# Excel
  } else {
    foreach item [array names opt] {
      if {[string first "PR_STEP" $item] == 0} {lappend butNormal "opt$item"}
    }
    foreach b {optINVERSE optPMIGRF optPMISEM optVALPROP optXL_FPREC optXL_KEEPOPEN optXL_LINK1 optXL_SORT} {lappend butNormal $b}
    foreach b {optVIZFEA optVIZPMI optVIZTPG optVIZBRP} {lappend butNormal $b}
    foreach b {allNone0 allNone1 allNone2 allNone3 optPR_USER} {lappend butNormal $b}
  }

# viz only
  if {$opt(XLSCSV) == "None"} {
    set opt(PMIGRF) 0
    foreach item [array names opt] {
      if {[string first "PR_STEP" $item] == 0} {lappend butDisabled "opt$item"}
    }
    foreach b {optPMIGRF optPMISEM optVALPROP optPR_USER optINVERSE} {lappend butDisabled $b}
    foreach b {allNone0 allNone1 allNone2} {lappend butDisabled $b}
    foreach b {userentity userentityopen} {lappend butDisabled $b}
    set userEntityList {}
    if {$opt(VIZFEA) == 0 && $opt(VIZPMI) == 0 && $opt(VIZTPG) == 0 && $opt(VIZBRP) == 0} {
      foreach item {VIZFEA VIZPMI VIZTPG VIZBRP} {set opt($item) 1}
    }
  }
  
# graphical PMI report
  if {$opt(PMIGRF)} {
    if {$opt(XLSCSV) != "None"} {
      foreach b {optPR_STEP_AP242 optPR_STEP_PRES optPR_STEP_REPR optPR_STEP_SHAP} {
        set opt([string range $b 3 end]) 1
        lappend butDisabled $b
      }
    }
  } else {
    lappend butNormal optPR_STEP_PRES
    if {!$opt(VALPROP)} {lappend butNormal optPR_STEP_QUAN}
    if {!$opt(PMISEM)}  {foreach b {optPR_STEP_AP242 optPR_STEP_COMM optPR_STEP_SHAP optPR_STEP_REPR} {lappend butNormal $b}}
  }

# validation properties
  if {$opt(VALPROP)} {
    foreach b {optPR_STEP_QUAN optPR_STEP_REPR optPR_STEP_SHAP} {
      set opt([string range $b 3 end]) 1
      lappend butDisabled $b
    }
  } elseif {!$opt(PMIGRF)} {
    lappend butNormal optPR_STEP_QUAN
  }

# graphical PMI view
  if {$opt(VIZPMI)} {
    foreach b {gpmiColor0 gpmiColor1 gpmiColor2 gpmiColor3 linecolor optVIZPMIVP} {lappend butNormal $b}
    if {$opt(XLSCSV) != "None"} {
      set opt(PR_STEP_PRES) 1
      lappend butDisabled optPR_STEP_PRES
    }
  } else {
    foreach b {gpmiColor0 gpmiColor1 gpmiColor2 gpmiColor3 linecolor optVIZPMIVP} {lappend butDisabled $b}
  }

# FEM view
  if {$opt(VIZFEA)} {
    foreach b {optVIZFEABC optVIZFEALV optVIZFEADS} {lappend butNormal $b}
    if {$opt(VIZFEALV)} {
      foreach b {optVIZFEALVS} {lappend butNormal $b}
    } else {
      foreach b {optVIZFEALVS} {lappend butDisabled $b}
    }
    if {$opt(VIZFEADS)} {
      foreach b {optVIZFEADSntail} {lappend butNormal $b}
    } else {
      foreach b {optVIZFEADSntail} {lappend butDisabled $b}
    }
  } else {
    foreach b {optVIZFEABC optVIZFEALV optVIZFEALVS optVIZFEADS optVIZFEADSntail} {lappend butDisabled $b}
  }

# semantic PMI report
  if {$opt(PMISEM)} {
    foreach b {optPR_STEP_AP242 optPR_STEP_REPR optPR_STEP_SHAP optPR_STEP_TOLR optPR_STEP_QUAN optPR_STEP_FEAT} {
      set opt([string range $b 3 end]) 1
      lappend butDisabled $b
    }
  } else {
    foreach b {optPR_STEP_REPR optPR_STEP_TOLR optPR_STEP_FEAT} {lappend butNormal $b}
    if {!$opt(PMIGRF)} {
      if {!$opt(VALPROP)} {lappend butNormal optPR_STEP_QUAN}
      foreach b {optPR_STEP_AP242 optPR_STEP_COMM optPR_STEP_SHAP} {lappend butNormal $b}
    }
  }

# tessellated geometry view
  if {$opt(VIZTPG)} {
    if {$opt(XLSCSV) != "None"} {
      set opt(PR_STEP_PRES) 1
      lappend butDisabled optPR_STEP_PRES
    }
    foreach b {optVIZTPGMSH} {lappend butNormal $b}
  } else {
    catch {
      if {!$opt(PMISEM) && !$opt(PMIGRF)} {lappend butNormal optPR_STEP_COMM}
      if {!$opt(PMISEM)} {lappend butNormal optPR_STEP_PRES}
    }
    foreach b {optVIZTPGMSH} {lappend butDisabled $b}
  }
  
# user-defined entity list
  if {$opt(PR_USER)} {
    foreach b {userentity userentityopen} {lappend butNormal $b}
  } else {
    foreach b {userentity userentityopen} {lappend butDisabled $b}
    set userEntityList {}
  }
  
# common for any report  
  if {$opt(PMISEM) || $opt(PMIGRF) || $opt(VALPROP)} {
    set opt(PR_STEP_COMM) 1
    lappend butDisabled optPR_STEP_COMM
  } else {
    lappend butNormal optPR_STEP_COMM
  }
  
  if {$developer} {
    if {$opt(INVERSE)} {
      foreach b {optDEBUGINV} {lappend butNormal $b}
    } else {
      foreach b {optDEBUGINV} {lappend butDisabled $b}
    }
  }
  
  if {$opt(writeDirType) == 0} {
    foreach b {userdir userentry userentry1 userfile} {lappend butDisabled $b}
  } elseif {$opt(writeDirType) == 1} {
    foreach b {userdir userentry}   {lappend butDisabled $b}
    foreach b {userentry1 userfile} {lappend butNormal   $b}
  } elseif {$opt(writeDirType) == 2} {
    foreach b {userdir userentry}   {lappend butNormal   $b}
    foreach b {userentry1 userfile} {lappend butDisabled $b}
  }

# make sure there is some entity type to process
  set nopt 0
  foreach idx [lsort [array names opt]] {
    if {([string first "PR_" $idx] == 0 || $idx == "VALPROP" || $idx == "PMIGRF" || $idx == "PMISEM") && [string first "FEAT" $idx] == -1} {
      incr nopt $opt($idx)
    }
  }
  if {$nopt == 0 && $opt(XLSCSV) != "None"} {set opt(PR_STEP_COMM) 1}
  
# configure buttons
  if {[llength $butNormal]   > 0} {foreach but $butNormal   {catch {$buttons($but) configure -state normal}}}
  if {[llength $butDisabled] > 0} {foreach but $butDisabled {catch {$buttons($but) configure -state disabled}}}
    
# configure all, none, for buttons
  if {[info exists allNone]} {
    if {($allNone == 2 && ($opt(PMISEM) != 1 || $opt(PMIGRF) != 1 || $opt(VALPROP) != 1)) ||
        ($allNone == 3 && ($opt(VIZPMI) != 1 || $opt(VIZTPG) != 1 || $opt(VIZFEA)  != 1 || $opt(VIZBRP) != 1))} {
      set allNone -1
    } elseif {$allNone == 0} {
      foreach item [array names opt] {
        if {[string first "PR_STEP" $item] == 0} {
          if {$item != "PR_STEP_GEOM" && $item != "PR_STEP_CPNT"} {
            if {$opt($item) == 0} {set allNone -1}
          }
        }
      }
    } elseif {$allNone == 1} {
      foreach item [array names opt] {
        if {[string first "PR_STEP" $item] == 0} {
          if {$item != "PR_STEP_COMM" && $item != "PR_STEP_FEAT"} {
            if {$opt($item) == 1} {set allNone -1}
          }
        }
      }
    }
  }
}

# -------------------------------------------------------------------------------------------------
proc getNISTName {} {
  global developer localName
  
  set nistName ""
  set filePrefix {}
  set prefixes {}
  for {set i 4} {$i < 20} {incr i} {lappend prefixes "sp$i"}
  for {set i 1} {$i < 20} {incr i} {lappend prefixes "tgp$i"}
  for {set i 3} {$i < 5}  {incr i} {lappend prefixes "tp$i"}
  set prefixes [concat $prefixes [list lsp lpp ltg ltp]]
  foreach fp $prefixes {
    lappend filePrefix "$fp\_"
    lappend filePrefix "$fp\-"
  }
  set ftail [string tolower [file tail $localName]]
  set ftail1 $ftail
  set c 3
  if {[string first "tgp" $ftail] == 0} {set c 4}
  foreach str {asme1 ap203 ap214 ap242 242 c3e} {regsub $str $ftail "" ftail}
  
# first check some specific names, CAx-IF ISO PMI models
  foreach part [list base cheek pole spindle] {
    if {[string first "sp" $ftail1] == 0} {
      if {[string first $part $ftail] != -1} {set nistName "sp6-$part"}
    }
    if {[string first "$part\_r"  $ftail] == 0}      {set nistName "sp6-$part"}
    if {[string first "_$part"    $ftail] != -1}     {set nistName "sp6-$part"}
    if {[string first "$part.stp" $localName] != -1} {set nistName "sp6-$part"}
  }
    
# QIF bracket    
  if {[string first "332211_qif_bracket" $ftail] != -1} {set nistName "332211_qif_bracket_revh"}
      
# CAx-IF sp3 models      
  if {[string first "sp" $ftail] == 0} {
    if {[string first "1101"  $ftail] != -1} {set nistName "sp3-1101"}
    if {[string first "16792" $ftail] != -1} {set nistName "sp3-16792"}
    if {[string first "box"   $ftail] != -1} {set nistName "sp3-box"}
  }

  if {$developer && [string first "step-file-analyzer" $ftail] == 0} {set nistName "nist_ctc_01"}

# specific name found  
  if {$nistName != ""} {return $nistName}

# check for a NIST CTC or FTC
  set ctcftc 0
  set ok  0
  set ok1 0
  
  if {[lsearch $filePrefix [string range $ftail 0 $c]] != -1 || [string first "nist" $ftail] != -1 || \
      [string first "ctc" $ftail] != -1 || [string first "ftc" $ftail] != -1} {
    if {[lsearch $filePrefix [string range $ftail 0 $c]] != -1} {set ftail [string range $ftail $c+1 end]}

    set tmp "nist_"
    foreach item {ctc ftc} {
      if {[string first $item $ftail] != -1} {
        append tmp "$item\_"
        set ctcftc 1
      }
    }

# find nist_ctc_01 directly        
    if {$ctcftc} {
      foreach zero {"0" ""} {
        for {set i 1} {$i <= 11} {incr i} {
          set i1 $i
          if {$i < 10} {set i1 "$zero$i"}
          set tmp1 "$tmp$i1"
          if {[string first $tmp1 $ftail] != -1 && !$ok1} {
            set nistName $tmp1
            #outputMsg $nistName green
            set ok1 1
          }
        }
      }
    }

# find the number in the string            
    if {!$ok1} {
      foreach zero {"0" ""} {
        for {set i 1} {$i <= 11} {incr i} {
          if {!$ok} {
            set i1 $i
            if {$i < 10} {set i1 "$zero$i"; set k "0$i"}
            set c {""}
            #outputMsg "$i1  [string first $i1 $ftail]  [string last $i1 $ftail]" blue
            if {[string first $i1 $ftail] != [string last $i1 $ftail]} {set c {"_" "-"}}
            foreach c1 $c {
              for {set j 0} {$j < 2} {incr j} {
                if {$j == 0} {set i2 "$c1$i1"}
                if {$j == 1} {set i2 "$i1$c1"}
                #outputMsg "[string first $i2 $ftail]  $i2  $ftail" green
                if {[string first $i2 $ftail] != -1 && !$ok} {
                  if {$ctcftc} {
                    append tmp $k
                  } elseif {$i <= 5} {
                    append tmp "ctc_$k"
                  } else {
                    append tmp "ftc_$k"
                  }
                  set nistName $tmp
                  set ok 1
                  #outputMsg $nistName red
                }
              }
            }
          }
        }
      }
    }
  }
  
# other files
#  if {!$ok} {}
  
  return $nistName
}

# -------------------------------------------------------------------------------------------------
proc setCoordMinMax {coord} {
  global x3dPoint x3dMin x3dMax

  set x3dPoint(x) [lindex $coord 0]
  set x3dPoint(y) [lindex $coord 1]
  set x3dPoint(z) [lindex $coord 2]

# min,max of points
  foreach idx {x y z} {
    if {$x3dPoint($idx) > $x3dMax($idx)} {set x3dMax($idx) $x3dPoint($idx)}
    if {$x3dPoint($idx) < $x3dMin($idx)} {set x3dMin($idx) $x3dPoint($idx)}
  }
}

# -------------------------------------------------------------------------------------------------
# set color based on entColorIndex variable
proc setColorIndex {ent {multi 0}} {
  global entCategory entColorIndex stepAP andEntAP209
  
# special case
  if {[string first "geometric_representation_context" $ent] != -1} {set ent "geometric_representation_context"}
  
# simple entity, not compound with _and_
  foreach i [array names entCategory] {
    if {[info exist entColorIndex($i)]} {
      if {[lsearch $entCategory($i) $ent] != -1} {
        return $entColorIndex($i)
      }
    }
  }
  
# compound entity with _and_
  set c1 [string first "\_and\_" $ent]
  if {$c1 != -1} {
    set c2 [string last  "\_and\_" $ent]
    set tc1 "1000"
    set tc2 "1000"
    set tc3 "1000"
    
    foreach i [array names entCategory] {
      if {[info exist entColorIndex($i)]} {
        set ent1 [string range $ent 0 $c1-1]
        if {[lsearch $entCategory($i) $ent1] != -1} {
          #outputMsg "1 AND $ent  $ent1  $i  $entColorIndex($i)"
          set tc1 $entColorIndex($i)
        }
        if {$c2 == $c1} {
          set ent2 [string range $ent $c1+5 end]
          if {[lsearch $entCategory($i) $ent2] != -1} {
            #outputMsg "2 AND $ent  $ent2  $i  $entColorIndex($i)"
            set tc2 $entColorIndex($i)
          } 
        } elseif {$c2 != $c1} {
          set ent2 [string range $ent $c1+5 $c2-1]
          if {[lsearch $entCategory($i) $ent2] != -1} {
            #outputMsg "2 AND $ent  $ent2  $i  $entColorIndex($i)"
            set tc2 $entColorIndex($i)
          } 
          set ent3 [string range $ent $c2+5 end]
          if {[lsearch $entCategory($i) $ent3] != -1} {
            #outputMsg "3 AND $ent  $ent3  $i  $entColorIndex($i)"
            set tc3 $entColorIndex($i)
          }
        }
      }
    }
    set tc [expr {min($tc1,$tc2,$tc3)}]

# exception for STEP measures    
    if {$tc1 == $entColorIndex(PR_STEP_QUAN) || $tc2 == $entColorIndex(PR_STEP_QUAN) || $tc3 == $entColorIndex(PR_STEP_QUAN)} {
      set tc $entColorIndex(PR_STEP_QUAN)
    }

# fix some AP209 entities with '_and_'
    if {[string first "AP209" $stepAP] != -1} {foreach str $andEntAP209 {if {[string first $str $ent] != -1} {set tc 19}}}

    #outputMsg "TC $tc"
    if {$tc < 1000} {return $tc}
  }

# entity not in any category, color by AP
  if {[string first "AP209" $stepAP] != -1} {return 19} 
  if {$stepAP == "AP210"} {return 15} 
  if {$stepAP == "AP238"} {return 24}

# entity from other APs (no color)
  return -2      
}

#-------------------------------------------------------------------------------
proc openURL {url} {
  global pf32

# open in whatever is registered for the file extension, except for .cgi for upgrade url
  if {[string first ".cgi" $url] == -1} {
    if {[catch {
      exec {*}[auto_execok start] "" $url
    } emsg]} {
      if {[string first "is not recognized" $emsg] == -1} {
        if {[string first "UNC" $emsg] == -1} {errorMsg "ERROR opening $url: $emsg"}
      }
    }

# find web browser command  
  } else {
    set webCmd ""
    catch {
      set reg_wb [registry get {HKEY_CURRENT_USER\Software\Classes\http\shell\open\command} {}]
      set reg_wb [lindex [split $reg_wb "\""] 1]
      set webCmd $reg_wb
    }
    if {$webCmd == "" || ![file exists $webCmd]} {set webCmd [file join $pf32 "Internet Explorer" IEXPLORE.EXE]}
    exec $webCmd $url &
  }
}

#-------------------------------------------------------------------------------
proc openFile {{openName ""}} {
  global localName localNameList outputWin fileDir buttons extXLS

  if {$openName == ""} {
  
# file types for file select dialog (removed .stpnc)
    set typelist [list {"STEP Files" {".stp" ".step" ".p21" ".stpZ"}} {"IFC Files" {".ifc"}}]

# file open dialog
    set localNameList [tk_getOpenFile -title "Open STEP File(s)" -filetypes $typelist -initialdir $fileDir -multiple true]
    if {[llength $localNameList] <= 1} {set localName [lindex $localNameList 0]}
    catch {
      set fext [string tolower [file extension $localName]]
      if {$fext == ".stpnc"} {errorMsg "Rename the file extension to '.stp' to process STEP-NC files."}
    }

# file name passed in as openName
  } else {
    set localName $openName
    set localNameList [list $localName]
  }

# multiple files selected
  if {[llength $localNameList] > 1} {
    set fileDir [file dirname [lindex $localNameList 0]]

    outputMsg "\nReady to process [llength $localNameList] STEP files" green
    if {[info exists buttons]} {
      $buttons(genExcel) configure -state normal
      if {[info exists buttons(appOpen)]} {$buttons(appOpen) configure -state normal}
      focus $buttons(genExcel)
    }

# single file selected
  } elseif {[file exists $localName]} {
    catch {pack forget $buttons(pgb1)}
  
# check for zipped file
    if {[string first ".stpz" [string tolower $localName]] != -1} {unzipFile}  

    set fileDir [file dirname $localName]
    if {[string first "z" [string tolower [file extension $localName]]] == -1} {
      outputMsg "\nReady to process: [file tail $localName] ([expr {[file size $localName]/1024}] Kb)" blue
      if {[info exists buttons]} {
        $buttons(genExcel) configure -state normal
        if {[info exists buttons(appOpen)]} {$buttons(appOpen) configure -state normal}
        focus $buttons(genExcel)
      }
    }
  
# not found
  } else {
    if {$localName != ""} {errorMsg "File not found: [truncFileName [file nativename $localName]]"}
  }
  catch {.tnb select .tnb.status}
}

#-------------------------------------------------------------------------------
proc unzipFile {} {
  global localName wdir mytemp

  if {[catch {
    outputMsg "\nUnzipping: [file tail $localName] ([expr {[file size $localName]/1024}] Kb)"

# copy gunzip to TEMP
    if {[file exists [file join $wdir exe gunzip.exe]]} {file copy -force [file join $wdir exe gunzip.exe] $mytemp}

    set gunzip [file join $mytemp gunzip.exe]
    if {[file exists $gunzip]} {

# copy zipped file to TEMP
      if {[regsub ".stpZ" $localName ".stp.Z" ln] == 0} {regsub ".stpz" $localName ".stp.Z" ln}
      set fzip [file join $mytemp [file tail $ln]]
      file copy -force $localName $fzip

# get name of unzipped file
      set gz [exec $gunzip -Nl $fzip]
      set c1 [string first "%" $gz]
      set ftmp [string range $gz $c1+2 end]

# unzip to a tmp file
      if {[file tail $ftmp] != [file tail $fzip]} {outputMsg " Extracting: [file tail $ftmp]" blue}
      exec $gunzip -Nf $fzip

# copy to new stp file
      set fstp [file join [file dirname $localName] [file tail $ftmp]]
      set ok 0
      if {![file exists $fstp]} {
        set ok 1
      } elseif {[file mtime $localName] != [file mtime $fstp]} {
        outputMsg " Overwriting existing unzipped STEP file: [truncFileName [file nativename $fstp]]" red
        set ok 1
      }
      if {$ok} {file copy -force $ftmp $fstp}

      set localName $fstp
      file delete $fzip
      file delete $ftmp
    } else {
      errorMsg "ERROR: gunzip.exe not found to unzip compressed STEP file"
    }
  } emsg]} {
    errorMsg "ERROR unzipping file: $emsg"
  }
}

#-------------------------------------------------------------------------------
proc saveState {} {
  global optionsFile fileDir openFileList opt userWriteDir dispCmd dispCmds
  global lastXLS lastXLS1 lastX3DOM userXLSFile fileDir1 mydocs sfaVersion upgrade
  global userEntityFile buttons statusFont excelVersion

  if {![info exists buttons]} {return}
  
  if {[catch {
    if {![file exists $optionsFile]} {
      outputMsg " "
      errorMsg "Creating options file: [truncFileName $optionsFile]"
    }
    set fileOptions [open $optionsFile w]
    puts $fileOptions "# Options file for the NIST STEP File Analyzer and Viewer v[getVersion] ([string trim [clock format [clock seconds]]])\n#\n# DO NOT EDIT OR DELETE FROM USER HOME DIRECTORY $mydocs\n# DOING SO WILL CORRUPT THE CURRENT SETTINGS OR CAUSE ERRORS IN THE SOFTWARE\n#"
    set varlist [list fileDir fileDir1 userWriteDir userEntityFile openFileList dispCmd dispCmds lastXLS lastXLS1 lastX3DOM \
                      userXLSFile statusFont upgrade sfaVersion excelVersion]

    foreach var $varlist {
      if {[info exists $var]} {
        set vartmp [set $var]
        if {[string first "/" $vartmp] != -1 || [string first "\\" $vartmp] != -1 || [string first " " $vartmp] != -1} {
          if {$var != "dispCmds" && $var != "openFileList"} {
            regsub -all {\\} $vartmp "/" vartmp
            puts $fileOptions "set $var \"$vartmp\""
          } else {
            regsub -all {\\} $vartmp "/" vartmp
            regsub -all {\[} $vartmp "\\\[" vartmp
            regsub -all {\]} $vartmp "\\\]" vartmp
            for {set i 0} {$i < [llength $vartmp]} {incr i} {
              if {$i == 0} {
                if {[llength $vartmp] > 1} {
                  puts $fileOptions "set $var \"\{[lindex $vartmp $i]\} \\"
                } else {
                  puts $fileOptions "set $var \"\{[lindex $vartmp $i]\}\""
                }
              } elseif {$i == [expr {[llength $vartmp]-1}]} {
                puts $fileOptions "       \{[lindex $vartmp $i]\}\""
              } else {
                puts $fileOptions "       \{[lindex $vartmp $i]\} \\"
              }
            }
          }
        } else {
          if {$vartmp != ""} {
            puts $fileOptions "set $var [set $var]"
          } else {
            puts $fileOptions "set $var \"\""
          }
        }
      }
    }
    
    set winpos "+300+200"
    set wg [winfo geometry .]
    catch {set winpos [string range $wg [string first "+" $wg] end]}
    puts $fileOptions "set winpos \"$winpos\""
    set wingeo [string range $wg 0 [expr {[string first "+" $wg]-1}]]
    puts $fileOptions "set wingeo \"$wingeo\""

    foreach idx [lsort [array names opt]] {
      if {([string first "PR_" $idx] == -1 || [string first "PR_STEP" $idx] == 0 || [string first "PR_USER" $idx] == 0) && [string first "DEBUG" $idx] == -1} {
        set var opt($idx)
        set vartmp [set $var]
        if {[string first "/" $vartmp] != -1 || [string first "\\" $vartmp] != -1 || [string first " " $vartmp] != -1} {
          regsub -all {\\} $vartmp "/" vartmp
          puts $fileOptions "set $var \"$vartmp\""
        } else {
          if {$vartmp != ""} {
            puts $fileOptions "set $var [set $var]"
          } else {
            puts $fileOptions "set $var \"\""
          }
        }
      }
    }

    close $fileOptions

  } emsg]} {
    errorMsg "ERROR writing to options file: $emsg"
    catch {raise .}
  }
}

#-------------------------------------------------------------------------------
proc runOpenProgram {} {
  global localName dispCmd appName transFile
  global sccmsg model_typ pfbent
  global openFileList File editorCmd
  global edmWriteToFile edmWhereRules eeWriteToFile
  
  set dispFile $localName
  set idisp [file rootname [file tail $dispCmd]]
  if {[info exists appName]} {if {$appName != ""} {set idisp $appName}}

  .tnb select .tnb.status
  outputMsg "\nOpening STEP file in: $idisp"

# open file
#  (list is programs that CANNOT start up with a file *OR* need specific commands below)
  if {[string first "Conformance"       $idisp] == -1 && \
      [string first "Tree View"         $idisp] == -1 && \
      [string first "Default"           $idisp] == -1 && \
      [string first "QuickStep"         $idisp] == -1 && \
      [string first "EDM Model Checker" $idisp] == -1} {

# start up with a file
    if {[catch {
      exec $dispCmd [file nativename $dispFile] &
    } emsg]} {
      errorMsg $emsg
    }

# default viewer associated with file extension
  } elseif {[string first "Default" $idisp] == 0} {
    if {[catch {
      exec {*}[auto_execok start] "" [file nativename $dispFile]
    } emsg]} {
      if {[string first "UNC" $emsg] == -1} {
        errorMsg "No application is associated with STEP files."
        errorMsg " See Websites > STEP File Viewers"
      }
    }

# file tree view
  } elseif {[string first "Tree View" $idisp] != -1} {
    indentFile $dispFile

# QuickStep
  } elseif {[string first "QuickStep" $idisp] != -1} {
    cd [file dirname $dispFile]
    exec $dispCmd [file tail $dispFile] &

#-------------------------------------------------------------------------------
# validate file with ST-Developer Conformance Checkers
  } elseif {[string first "Conformance" $idisp] != -1} {
    set stfile $dispFile
    outputMsg "Ready to validate:  [truncFileName [file nativename $stfile]] ([expr {[file size $stfile]/1024}] Kb)" blue
    cd [file dirname $stfile]

# gui version
    if {[string first "gui" $dispCmd] != -1 && !$eeWriteToFile} {
      if {[catch {exec $dispCmd $stfile &} err]} {outputMsg "Conformance Checker error:\n $err" red}

# non-gui version
    } else {
      set stname [file tail $stfile]
      set stlog  "[file rootname $stname]\_stdev.log"
      catch {if {[file exists $stlog]} {file delete -force $stlog}}
      outputMsg "ST-Developer log file: [truncFileName [file nativename $stlog]]" blue

      set c1 [string first "gui" $dispCmd]
      set dispCmd1 $dispCmd
      if {$c1 != -1} {set dispCmd1 [string range $dispCmd 0 $c1-1][string range $dispCmd $c1+3 end]}

      if {[string first "apconform" $dispCmd1] != -1} {
        if {[catch {exec $dispCmd1 -syntax -required -unique -bounds -aggruni -arrnotopt -inverse -strwidth -binwidth -realprec -atttypes -refdom $stfile >> $stlog &} err]} {outputMsg "Conformance Checker error:\n $err" red}
      } else {
        if {[catch {exec $dispCmd1 $stfile >> $stlog &} err]} {outputMsg "Conformance Checker error:\n $err" red}
      }  
      if {[string first "Notepad++" $editorCmd] != -1} {
        outputMsg "Opening log file in editor"
        exec $editorCmd $stlog &
      } else {
        outputMsg "Wait until the Conformance Checker has finished and then open the log file"
      }
    }

#-------------------------------------------------------------------------------
# Jotne EDM Model Checker (only for developer)
  } elseif {[string first "EDM Model Checker" $idisp] != -1} {
    set filename $dispFile
    outputMsg "Ready to validate:  [truncFileName [file nativename $filename]] ([expr {[file size $filename]/1024}] Kb)" blue
    cd [file dirname $filename]

# write script file to open database
    set edmScript [file join [file dirname $filename] edm-validate-script.txt]
    catch {file delete -force $edmScript}
    set scriptFile [open $edmScript w]
    set okschema 1

    set edmDir [split [file nativename $dispCmd] [file separator]]
    set i [lsearch $edmDir "bin"]
    set edmDir [join [lrange $edmDir 0 [expr {$i-1}]] [file separator]]
    set edmDBopen "ACCUMULATING_COMMAND_OUTPUT,OPEN_SESSION"
    
# open file to find STEP schema name
    set edmPW "NIST@edm[string range $idisp end end]"
    set fschema [getSchemaFromFile $filename]

    if {[string first "AP203_CONFIGURATION_CONTROLLED_3D_DESIGN_OF_MECHANICAL_PARTS_AND_ASSEMBLIES_MIM_LF" $fschema] == 0} {
      puts $scriptFile "Database>Open([file nativename [file join $edmDir Db]], ap203, $edmPW, \"$edmDBopen\")"
    } elseif {$fschema == "CONFIG_CONTROL_DESIGN"} {
      puts $scriptFile "Database>Open([file nativename [file join $edmDir Db]], ap203e1, $edmPW, \"$edmDBopen\")"
    } elseif {[string first "AP209_MULTIDISCIPLINARY_ANALYSIS_AND_DESIGN_MIM_LF" $fschema] == 0} {
      puts $scriptFile "Database>Open([file nativename [file join $edmDir Db]], ap209, $edmPW, \"$edmDBopen\")"
    } elseif {$fschema == "AUTOMOTIVE_DESIGN"} {
      puts $scriptFile "Database>Open([file nativename [file join $edmDir Db]], ap214, $edmPW, \"$edmDBopen\")"
    } elseif {[string first "AP242_MANAGED_MODEL_BASED_3D_ENGINEERING_MIM_LF" $fschema] == 0} {
      set ap242 "ap242"
      if {[string first "1 0 10303 442 2 1 4" $fschema] != -1} {append ap242 "e2"}
      puts $scriptFile "Database>Open([file nativename [file join $edmDir Db]], $ap242, $edmPW, \"$edmDBopen\")"
    } else {
      outputMsg "$idisp cannot be used with:\n $fschema" red
      set okschema 0
    }

# create a temporary file if certain characters appear in the name, copy original to temporary and process that one
    if {$okschema} {
      set tmpfile 0
      set fileRoot [file rootname [file tail $filename]]
      if {[string is integer [string index $fileRoot 0]] || \
        [string first " " $fileRoot] != -1 || \
        [string first "." $fileRoot] != -1 || \
        [string first "+" $fileRoot] != -1 || \
        [string first "%" $fileRoot] != -1 || \
        [string first "(" $fileRoot] != -1 || \
        [string first ")" $fileRoot] != -1} {
        if {[string is integer [string index $fileRoot 0]]} {set fileRoot "a_$fileRoot"}
        regsub -all " " $fileRoot "_" fileRoot
        regsub -all {[\.()+%]} $fileRoot "_" fileRoot
        set edmFile [file join [file dirname $filename] $fileRoot]
        append edmFile [file extension $filename]
        file copy -force $filename $edmFile
        set tmpfile 1
      } else {
        set edmFile $filename
      }

# validate everything
      #set edmValidate "FULL_VALIDATION,OUTPUT_STEPID"

# not validating DERIVE, ARRAY_REQUIRED_ELEMENTS
      set edmValidate "GLOBAL_RULES,REQUIRED_ATTRIBUTES,ATTRIBUTE_DATA_TYPE,AGGREGATE_DATA_TYPE,AGGREGATE_SIZE,AGGREGATE_UNIQUENESS,OUTPUT_STEPID"
      if {$edmWhereRules} {append edmValidate ",LOCAL_RULES,UNIQUENESS_RULES,INVERSE_RULES"}

# write script file if not writing output to file, just import model and validate
      set edmImport "ACCUMULATING_COMMAND_OUTPUT,KEEP_STEP_IDENTIFIERS,DELETING_EXISTING_MODEL,LOG_ERRORS_AND_WARNINGS_ONLY"
      if {$edmWriteToFile == 0} {
        puts $scriptFile "Data>ImportModel(DataRepository, $fileRoot, DataRepository, $fileRoot\_HeaderModel, \"[file nativename $edmFile]\", \$, \$, \$, \"$edmImport,LOG_TO_STDOUT\")"
        puts $scriptFile "Data>Validate>Model(DataRepository, $fileRoot, \$, \$, \$, \"ACCUMULATING_COMMAND_OUTPUT,$edmValidate,FULL_OUTPUT\")"

# write script file if writing output to file, create file names, import model, validate, and exit
      } else {
        set edmLog  "[file rootname $filename]_edm.log"
        set edmLogImport "[file rootname $filename]_edm_import.log"
        puts $scriptFile "Data>ImportModel(DataRepository, $fileRoot, DataRepository, $fileRoot\_HeaderModel, \"[file nativename $edmFile]\", \"[file nativename $edmLogImport]\", \$, \$, \"$edmImport,LOG_TO_FILE\")"
        puts $scriptFile "Data>Validate>Model(DataRepository, $fileRoot, \$, \"[file nativename $edmLog]\", \$, \"ACCUMULATING_COMMAND_OUTPUT,$edmValidate,FULL_OUTPUT\")"
        puts $scriptFile "Data>Close>Model(DataRepository, $fileRoot, \" ACCUMULATING_COMMAND_OUTPUT\")"
        puts $scriptFile "Data>Delete>ModelContents(DataRepository, $fileRoot, ACCUMULATING_COMMAND_OUTPUT)"
        puts $scriptFile "Data>Delete>Model(DataRepository, $fileRoot, header_section_schema, \"ACCUMULATING_COMMAND_OUTPUT,DELETE_ALL_MODELS_OF_SCHEMA\")"
        puts $scriptFile "Data>Delete>Model(DataRepository, $fileRoot, \$, ACCUMULATING_COMMAND_OUTPUT)"
        puts $scriptFile "Data>Delete>Model(DataRepository, $fileRoot, \$, \"ACCUMULATING_COMMAND_OUTPUT,CLOSE_MODEL_BEFORE_DELETION\")"
        puts $scriptFile "Exit>Exit()"
      }
      close $scriptFile

# run EDM Model Checker with the script file
      outputMsg "Running $idisp"
      eval exec {$dispCmd} $edmScript &

# if results are written to a file, open output file from the validation (edmLog) and output file if there are import errors (edmLogImport)
      if {$edmWriteToFile} {
        if {[string first "Notepad++" $editorCmd] != -1} {
          outputMsg "Opening log file(s) in editor"
          exec $editorCmd $edmLog &
          after 1000
          if {[file size $edmLogImport] > 0} {
            exec $editorCmd $edmLogImport &
          } else {
            catch {file delete -force $edmLogImport}
          }
        } else {
          outputMsg "Wait until the EDM Model Checker has finished and then open the log file"
        }
      }

# attempt to delete the script file
      set nerr 0
      while {[file exists $edmScript]} {
        catch {file delete -force $edmScript}
        after 1000
        incr nerr
        if {$nerr > 60} {break}
      }

# if using a temporary file, attempt to delete it
      if {$tmpfile} {
        set nerr 0
        while {[file exists $edmFile]} {
          catch {file delete -force $edmFile}
          after 1000
          incr nerr
          if {$nerr > 60} {break}
        }
      }
    }

# all others
  } else {
    .tnb select .tnb.status
    outputMsg "You have to manually import the STEP file to $idisp." red
    exec $dispCmd &
  }
  
    
# add file to menu
  addFileToMenu
  saveState
}

#-------------------------------------------------------------------------------
proc getOpenPrograms {} {
  global dispApps dispCmds dispCmd appNames appName env
  global drive editorCmd developer myhome pf32 pf64

# Including any of the CAD viewers and software below does not imply a recommendation or
# endorsement of them by NIST https://www.nist.gov/disclaimer
# For more STEP viewers, go to https://www.cax-if.org/step_viewers.html
  
  regsub {\\} $pf32 "/" p32
  lappend pflist $p32
  if {$pf64 != "" && $pf64 != $pf32} {
    regsub {\\} $pf64 "/" p64
    lappend pflist $p64
  }
  set lastver 0

# Jotne EDM Model Checker
  if {$developer} {
    set edms [glob -nocomplain -directory [file join $drive edm] -join edm* bin Edms.exe]
    foreach match $edms {
      set name "EDM Model Checker"
      if {[string first "edm5" $match] != -1} {
        set num 5 
      } elseif {[string first "edmsix" $match] != -1} {
        set num 6
      }
      set dispApps($match) "$name $num"
    }
  }

# STEP Tools apps
  foreach pf $pflist {
    if {[file isdirectory [file join $pf "STEP Tools"]]} {
      set applist [list \
        [list ap203checkgui.exe "AP203 Conformance Checker"] \
        [list ap209checkgui.exe "AP209 Conformance Checker"] \
        [list ap214checkgui.exe "AP214 Conformance Checker"] \
        [list apconformgui.exe "AP Conformance Checker"] \
        [list stepbrws.exe "STEP File Browser"] \
        [list stepcleangui.exe "STEP File Cleaner"] \
        [list stpcheckgui.exe "STEP Check and Browse"] \
        [list stview.exe "ST-Viewer"] \
      ]
      foreach app $applist {
        set stmatch ""
        foreach match [glob -nocomplain -directory $pf -join "STEP Tools" "ST-Developer*" bin [lindex $app 0]] {
          if {$stmatch == ""} {
            set stmatch $match
            set lastver [lindex [split [file nativename $match] [file separator]] 3]
          } else {
            set ver [lindex [split [file nativename $match] [file separator]] 3]
            if {$ver > $lastver} {set stmatch $match}
          }
        }
        if {$stmatch != ""} {
          if {![info exists dispApps($stmatch)]} {set dispApps($stmatch) [lindex $app 1]}
        }
      }
    }

# other STEP file apps
    set applist [list \
      [list {*}[glob -nocomplain -directory [file join $pf "SOLIDWORKS Corp"] -join "eDrawings (*)" eDrawings.exe] eDrawings] \
      [list {*}[glob -nocomplain -directory [file join $pf "Stratasys Direct Manufacturing"] -join "SolidView Pro RP *" bin SldView.exe] SolidView] \
      [list {*}[glob -nocomplain -directory [file join $pf "TransMagic Inc"] -join "TransMagic *" System code bin TransMagic.exe] TransMagic] \
      [list {*}[glob -nocomplain -directory [file join $pf Actify SpinFire] -join "*" SpinFire.exe] SpinFire] \
      [list {*}[glob -nocomplain -directory [file join $pf CADSoftTools] -join "ABViewer*" ABViewer.exe] ABViewer] \
      [list {*}[glob -nocomplain -directory [file join $pf Kubotek] -join "Spectrum*" Spectrum.exe] Spectrum] \
      [list {*}[glob -nocomplain -directory [file join $pf] -join "3D-Tool V*" 3D-Tool.exe] 3D-Tool] \
      [list {*}[glob -nocomplain -directory [file join $pf] -join "VariCADViewer *" bin varicad-x64.exe] "VariCAD Viewer"] \
      [list {*}[glob -nocomplain -directory [file join $pf] -join ZWSOFT "CADbro *" CADbro.exe] CADbro] \
    ]
    if {$pf64 == ""} {
      lappend applist [list {*}[glob -nocomplain -directory [file join $pf] -join "VariCADViewer *" bin varicad-i386.exe] "VariCAD Viewer (32-bit)"]
    }

    foreach app $applist {
      if {[llength $app] == 2} {
        set match [join [lindex $app 0]]
        if {$match != "" && ![info exists dispApps($match)]} {
          set dispApps($match) [lindex $app 1]
        }
      }
    }
    
    set applist [list \
      [list [file join $pf "3DJuump X64" 3DJuump.exe] "3DJuump"] \
      [list [file join $pf "CAD Assistant" CADAssistant.exe] "CAD Assistant"] \
      [list [file join $pf "CAD Exchanger" bin Exchanger.exe] "CAD Exchanger"] \
      [list [file join $pf "SOLIDWORKS Corp" eDrawings eDrawings.exe] "eDrawings"] \
      [list [file join $pf "STEP Tools" "STEP-NC Machine Personal Edition" STEPNCExplorer.exe] "STEP-NC Machine"] \
      [list [file join $pf "STEP Tools" "STEP-NC Machine Personal Edition" STEPNCExplorer_x86.exe] "STEP-NC Machine"] \
      [list [file join $pf "STEP Tools" "STEP-NC Machine" STEPNCExplorer.exe] "STEP-NC Machine"] \
      [list [file join $pf "STEP Tools" "STEP-NC Machine" STEPNCExplorer_x86.exe] "STEP-NC Machine"] \
      [list [file join $pf "Tekla BIMsight" BIMsight.exe] "Tekla BIMsight"] \
      [list [file join $pf CadFaster QuickStep QuickStep.exe] QuickStep] \
      [list [file join $pf Glovius Glovius glovius.exe] Glovius] \
      [list [file join $pf IFCBrowser IfcQuickBrowser.exe] IfcQuickBrowser] \
      [list [file join $pf Kisters 3DViewStation 3DViewStation.exe] 3DViewStation] \
      [list [file join $pf STPViewer STPViewer.exe] "STP Viewer"] \
    ]
    foreach app $applist {
      if {[file exists [lindex $app 0]]} {
        set name [lindex $app 1]
        set dispApps([lindex $app 0]) $name
      }
    }
    
# FreeCAD    
    foreach app [list {*}[glob -nocomplain -directory [file join $pf] -join "FreeCAD *" bin FreeCAD.exe] FreeCAD]] {
      set ver [lindex [split [file nativename $app] [file separator]] 2]
      if {$pf64 != "" && [string first "x86" $app] != -1} {append ver " (32-bit)"}
      set dispApps($app) $ver
    }

# Tetra4D in Adobe Acrobat
    for {set i 40} {$i > 9} {incr i -1} {
      if {$i > 11} {
        set j "20$i"
      } else {
        set j "$i.0"
      }        
      foreach match [glob -nocomplain -directory $pf -join Adobe "Acrobat $j" Acrobat Acrobat.exe] {
        if {[file exists [file join $pf Adobe "Acrobat $j" Acrobat plug_ins 3DPDFConverter 3DPDFConverter.exe]]} {
          if {![info exists dispApps($match)]} {
            set name "Tetra4D Converter"
            set dispApps($match) $name
          }
        }
      }
      set match [file join $pf Adobe "Acrobat $j" Acrobat plug_ins 3DPDFConverter 3DReviewer.exe]
      if {![info exists dispApps($match)]} {
        set name "Tetra4D Reviewer"
        set dispApps($match) $name
      }
    }
  }

# others  
  set b1 [file join $myhome AppData Local IDA-STEP ida-step.exe]
  if {[file exists $b1]} {
    set name "IDA-STEP Viewer"
    set dispApps($b1) $name
  }
  set b1 [file join $drive CCELabs EnSuite-View Bin EnSuite-View.exe]
  if {[file exists $b1]} {
    set name "EnSuite-View"
    set dispApps($b1) $name
  } else {
    set b1 [file join $drive CCE EnSuite-View Bin EnSuite-View.exe]
    if {[file exists $b1]} {
      set name "EnSuite-View"
      set dispApps($b1) $name
    }
  }

#-------------------------------------------------------------------------------
# default viewer
  set dispApps(Default) "Default STEP Viewer"

# file tree view
  set dispApps(Indent) "Tree View (for debugging)"

#-------------------------------------------------------------------------------
# set text editor command and name
  set editorCmd ""
  set editorName ""

# Notepad++ or Notepad
  set editorCmd [file join $pf32 Notepad++ notepad++.exe]
  if {[file exists $editorCmd]} {
    set editorName "Notepad++"
    set dispApps($editorCmd) $editorName
  } elseif {[info exists env(windir)]} {
    set editorCmd [file join $env(windir) system32 Notepad.exe]
    set editorName "Notepad"
    set dispApps($editorCmd) $editorName
  }

#-------------------------------------------------------------------------------
# remove cmd that do not exist in dispCmds and non-executables
  set dispCmds1 {}
  foreach app $dispCmds {
    if {([file exists $app] || [string first "Default" $app] == 0 || [string first "Indent" $app] == 0) && \
         [file tail $app] != "NotePad.exe"} {
      lappend dispCmds1 $app
    }
  }
  set dispCmds $dispCmds1

# check for cmd in dispApps that does not exist in dispCmds and add to list
  foreach app [array names dispApps] {
    if {[file exists $app] || [string first "Default" $app] == 0 || [string first "Indent" $app] == 0} {
      set notInCmds 1
      foreach cmd $dispCmds {if {[string tolower $cmd] == [string tolower $app]} {set notInCmds 0}}
      if {$notInCmds} {lappend dispCmds $app}
    }
  }

# remove duplicates in dispCmds
  if {[llength $dispCmds] != [llength [lrmdups $dispCmds]]} {set dispCmds [lrmdups $dispCmds]}

# clean up list of app viewer commands
  if {[info exists dispCmd]} {
    if {([file exists $dispCmd] || [string first "Default" $dispCmd] == 0 || [string first "Indent" $dispCmd] == 0)} {
      if {[lsearch $dispCmds $dispCmd] == -1 && $dispCmd != ""} {lappend dispCmds $dispCmd}
    } else {
      if {[llength $dispCmds] > 0} {
        foreach dispCmd $dispCmds {
          if {([file exists $dispCmd] || [string first "Default" $dispCmd] == 0 || [string first "Indent" $dispCmd] == 0)} {break}
        }
      } else {
        set dispCmd ""
      }
    }
  } else {
    if {[llength $dispCmds] > 0} {
      set dispCmd [lindex $dispCmds 0]
    }
  }
  for {set i 0} {$i < [llength $dispCmds]} {incr i} {
    if {![file exists [lindex $dispCmds $i]] && [string first "Default" [lindex $dispCmds $i]] == -1 && [string first "Indent" [lindex $dispCmds $i]] == -1} {set dispCmds [lreplace $dispCmds $i $i]}
  }

# put dispCmd at beginning of dispCmds list
  if {[info exists dispCmd]} {
    for {set i 0} {$i < [llength $dispCmds]} {incr i} {
      if {$dispCmd == [lindex $dispCmds $i]} {
        set dispCmds [lreplace $dispCmds $i $i]
        set dispCmds [linsert $dispCmds 0 $dispCmd]
      }
    }
  }

# remove duplicates in dispCmds, again
  if {[llength $dispCmds] != [llength [lrmdups $dispCmds]]} {set dispCmds [lrmdups $dispCmds]}

# set list of STEP viewer names, appNames
  set appNames {}
  set appName  ""
  foreach cmd $dispCmds {
    if {[info exists dispApps($cmd)]} {
      lappend appNames $dispApps($cmd)
    } else {
      set name [file rootname [file tail $cmd]]
      lappend appNames  $name
      set dispApps($cmd) $name
    }
  }
  if {$dispCmd != ""} {
    if {[info exists dispApps($dispCmd)]} {set appName $dispApps($dispCmd)}
  }
}

# -------------------------------------------------------------------------------------------------
proc getFirstFile {} {
  global openFileList buttons
  
  set localName [lindex $openFileList 0]
  if {$localName != ""} {
    outputMsg "\nReady to process: [file tail $localName] ([expr {[file size $localName]/1024}] Kb)" blue
    if {[info exists buttons(appOpen)]} {$buttons(appOpen) configure -state normal}
  }
  return $localName
}

#-------------------------------------------------------------------------------
proc addFileToMenu {} {
  global openFileList localName File buttons

  set lenlist 25
  set filemenuinc 4
  
  if {![info exists buttons]} {return}
  
# change backslash to forward slash, if necessary
  regsub -all {\\} $localName "/" localName

# remove duplicates
  set newlist {}
  set dellist {}
  for {set i 0} {$i < [llength $openFileList]} {incr i} {
    set name [lindex $openFileList $i]
    set ifile [lsearch -all $openFileList $name]
    if {[llength $ifile] == 1 || [lindex $ifile 0] == $i} {
      lappend newlist $name
    } else {
      lappend dellist $i
    }
  }
  set openFileList $newlist
  
# check if file name is already in the menu, if so, delete
  set ifile [lsearch $openFileList $localName]
  if {$ifile > 0} {
    set openFileList [lreplace $openFileList $ifile $ifile]
    $File delete [expr {$ifile+$filemenuinc}] [expr {$ifile+$filemenuinc}]
  }

# insert file name at top of list
  set fext [string tolower [file extension $localName]]
  if {$ifile != 0 && ($fext == ".stp" || $fext == ".step" || $fext == ".p21")} {
    set openFileList [linsert $openFileList 0 $localName]
    $File insert $filemenuinc command -label [truncFileName [file nativename $localName] 1] \
      -command [list openFile $localName] -accelerator "F1"
    catch {$File entryconfigure 5 -accelerator {}}
  }

# check length of file list, delete from the end of the list
  if {[llength $openFileList] > $lenlist} {
    set openFileList [lreplace $openFileList $lenlist $lenlist]
    $File delete [expr {$lenlist+$filemenuinc}] [expr {$lenlist+$filemenuinc}]
  }

# compare file list and menu list
  set llen [llength $openFileList]
  for {set i 0} {$i < $llen} {incr i} {
    set f1 [file tail [lindex $openFileList $i]]
    set f2 ""
    catch {set f2 [file tail [lindex [$File entryconfigure [expr {$i+$filemenuinc}] -label] 4]]}
    #if {$f1 != $f2 && $f2 != ""} {errorMsg "File list and menu out of synch: $i $f1 $f2"}
  }
  
# save the state so that if the program crashes the file list will be already saved
  saveState
  return
}

#-------------------------------------------------------------------------------
# open a spreadsheet
proc openXLS {filename {check 0} {multiFile 0}} {
  global buttons

  if {[info exists buttons]} {
    .tnb select .tnb.status
    update idletasks
  }

  if {[file exists $filename]} {

# check if instances of Excel are already running
    if {$check} {checkForExcel}
    
# start Excel
    if {[catch {
      set xl [::tcom::ref createobject Excel.Application]
      [$xl ErrorCheckingOptions] TextDate False

# errors
    } emsg]} {
      errorMsg "ERROR starting Excel: $emsg"
    }
    
# open spreadsheet in Excel, works even if Excel not already started above although slower
    if {[catch {
      outputMsg "\nOpening Spreadsheet: [file tail $filename]"
      exec {*}[auto_execok start] "" [file nativename $filename]

# errors
    } emsg]} {
      if {[string first "UNC" $emsg] == -1} {
        errorMsg "ERROR opening Spreadsheet: $emsg"
        outputMsg " "
        set funcstr "F2"
        if {$multiFile} {set funcstr "F3"}
        errorMsg "Use $funcstr to open the spreadsheet or\n Go to the directory with the spreadsheet and open it."
        catch {raise .}
      }
    }

  } else {
    if {[file tail $filename] != ""} {errorMsg "Spreadsheet not found: [truncFileName [file nativename $filename]]"}
    set filename ""
  }
  return $filename
}

#-------------------------------------------------------------------------------
proc checkForExcel {{multFile 0}} {
  global lastXLS localName buttons opt
  
  set pid1 [twapi::get_process_ids -name "EXCEL.EXE"]
  if {![info exists useXL]} {set useXL 1}
  
  if {[llength $pid1] > 0 && $opt(XLSCSV) != "None"} {
    if {[info exists buttons]} {
      if {!$multFile} {
        set msg "There are ([llength $pid1]) instances of Excel already running.\nThe spreadsheets for the other instances might not be visible but will show up in the Windows Task Manager as EXCEL.EXE"
        append msg "\n\nThey might affect generating, saving, or viewing a new Excel spreadsheet."
        append msg "\n\nDo you want to close the other instances of Excel?"

        set dflt yes
        if {[info exists lastXLS] && [info exists localName]} {
          if {[llength $pid1] == 1} {if {[string first [file nativename [file rootname $localName]] [file nativename $lastXLS]] != 0} {set dflt no}}
        }
        set choice [tk_messageBox -type yesno -default $dflt -message $msg -icon question -title "Close Excel?"]

        if {$choice == "yes"} {
          for {set i 0} {$i < 5} {incr i} {
            set nnc 0
            foreach pid $pid1 {
              if {[catch {
                twapi::end_process $pid -force
              } emsg]} {
                incr nnc
              }
            }
            set pid1 [twapi::get_process_ids -name "EXCEL.EXE"]
            if {[llength $pid1] == 0} {break}
          }
          #if {$nnc > 0} {errorMsg "Some instances ($nnc) of Excel were not closed: $emsg" red}
        }
      }
    } else {
      foreach pid $pid1 {
        if {[catch {
          twapi::end_process $pid -force
        } emsg]} {
          #errorMsg "Some instances of Excel were not closed: $emsg" red
        }
      }
    }
  }
  return $pid1
}

#-------------------------------------------------------------------------------
# get next unused column
proc getNextUnusedColumn {ent} {
  global worksheet
  return [expr {[[[$worksheet($ent) UsedRange] Columns] Count] + 1}]
}

# -------------------------------------------------------------------------------
proc formatComplexEnt {str {space 0}} {
  global entCategory opt stepAP andEntAP209
  
  set str1 $str

# possibly format for _and_
  if {[string first "_and_" $str1] != -1} {

# check if _and_ is part of the entity name
    set ok 1
    foreach cat {PR_STEP_AP242 PR_STEP_COMM PR_STEP_TOLR PR_STEP_PRES PR_STEP_KINE PR_STEP_COMP} {
      if {$opt($cat)} {if {[lsearch $entCategory($cat) $str] != -1} {set ok 0; break}}
    }
    if {[info exists stepAP]} {
      if {[string first "AP209" $stepAP] != -1} {foreach str2 $andEntAP209 {if {[string first $str2 $str] != -1} {set ok 0}}}
    }

# format a_and_b to (a)(b)
    if {$ok} {
      catch {
        regsub -all "_and_" $str1 ") (" str1
        if {$space == 0} {regsub -all " " $str1 "" str1}
        set str1 "($str1)"
      }
    }
  }
  return $str1
}

#-------------------------------------------------------------------------------
proc cellRange {r c} {
  set letters ABCDEFGHIJKLMNOPQRSTUVWXYZ
  
# correct if 'c' is passed in as a letter
  set cf [string first $c $letters]
  if {$cf != -1} {set c [expr {$cf+1}]}

# a much more elegant solution from the Tcl wiki
  set cr ""
  set n $c
  while {[incr n -1] >= 0} {
    set cr [format %c%s [expr {$n%26+65}] $cr]
    set n [expr {$n/26}]
  }

  if {$r > 0} {
    append cr $r
  } else {
    append cr ":$cr"
  }
  
  return $cr
}

#-------------------------------------------------------------------------------
proc addCellComment {ent r c comment} {
  global worksheet recPracNames

  if {![info exists worksheet($ent)] || [string length $comment] < 2} {return}

# modify comment      
  if {[catch {
    while {[string first "  " $comment] != -1} {regsub -all "  " $comment " " comment}
    if {[string first "Syntax" $comment] == 0} {set comment "[string range $comment 14 end]"}
    if {[string first "GISU" $comment] != -1} {regsub "GISU" $comment "geometric_item_specific_usage"  comment}
    if {[string first "IIRU" $comment] != -1} {regsub "IIRU" $comment "item_identified_representation_usage" comment}

    foreach idx [array names recPracNames] {
      if {[string first $recPracNames($idx) $comment] != -1} {
        append comment "  See Websites > Recommended Practices"
        break
      }
    }
    
# add linefeeds for line length
    set ncomment ""
    set j 0
    for {set i 0} {$i < [string length $comment]} {incr i} {
      incr j
      set char [string index $comment $i]
      if {($j > 50 && $char == " ") || $char == [format "%c" 10]} {
        append ncomment \n
        set j 0
      } else {
        append ncomment $char
      }
    }
      
# add comment
    set comm [[$worksheet($ent) Range [cellRange $r $c]] AddComment]
    $comm Text $ncomment
    catch {[[$comm Shape] TextFrame] AutoSize [expr 1]}

# error
  } emsg]} {
    if {[string first "Unknown error" $emsg] == -1} {errorMsg "ERROR adding Cell Comment: $emsg\n  $ent"}
  }
}

#-------------------------------------------------------------------------------
# color bad cells red, add cell comment with message
proc colorBadCells {ent} {
  global excelVersion syntaxErr count cells worksheet stepAP legendColor entsWithErrors
  
  if {$stepAP == "" || $excelVersion < 11} {return}
      
# color red for syntax errors
  set rmax [expr {$count($ent)+3}]
  set okcomment 0
  
  set syntaxErr($ent) [lsort -integer -index 0 [lrmdups $syntaxErr($ent)]]
  foreach err $syntaxErr($ent) {
    set lastr 4
    if {[catch {

# get row and column number
      set r [lindex $err 0]
      set c [lindex $err 1]
      
# get message for cell comment
      set msg ""
      set msg [lindex $err 2]

# row and column are integers
      if {[string is integer $c]} {
        if {$r <= $rmax} {
          [[$worksheet($ent) Range [cellRange $r $c] [cellRange $r $c]] Interior] Color $legendColor(red)
          set okcomment 1
        }

# values are entity ID or row number (row) and attribute name (column)
      } else {
        #outputMsg "$ent / $r / $c / [string is integer $c]" red

# find column based on heading text
        set lastCol [[[$worksheet($ent) UsedRange] Columns] Count]
        if {![info exists nc($c)]} { 
          for {set i 2} {$i <= $lastCol} {incr i} {
            set val [[$cells($ent) Item 3 $i] Value]
            if {[string first $c $val] == 0} {
              set nc($c) $i
              break
            }
          }
        }
        
# cannot find heading, use first column        
        if {![info exists nc($c)]} {set nc($c) 1}
        set c $nc($c)
      
# entity ID
        if {$r > 0} {
          for {set i $lastr} {$i <= $rmax} {incr i} {
            set val [[$cells($ent) Item $i 1] Value]
            if {$val == $r} {
              set r $i
              set lastr [expr {$r+1}]
              [[$worksheet($ent) Range [cellRange $r $c] [cellRange $r $c]] Interior] Color $legendColor(red)
              set okcomment 1
              break
            }              
          }

# row number
        } else {
          set r [expr {abs($r)}]
          [[$worksheet($ent) Range [cellRange $r $c] [cellRange $r $c]] Interior] Color $legendColor(red)
          set okcomment 1
        }
      }
      
# add cell comment
      if {$msg != "" && $okcomment} {if {$r <= $rmax} {addCellComment $ent $r $c $msg}}
      if {$okcomment} {lappend entsWithErrors [formatComplexEnt $ent]}

# error      
    } emsg]} {
      errorMsg "ERROR setting cell color (red) or comment: $emsg\n  $ent"
      catch {raise .}
    }
  }
}

#-------------------------------------------------------------------------------
proc trimNum {num {prec 3}} {
  global unq_num
  
# check for already trimmed number
  set numsav $num
  if {[info exists unq_num($numsav)]} {
    set num $unq_num($numsav)
  } else {
    
# trim number    
    if {[catch {
      
# format number with 'prec' 
      set form "\%."
      append form $prec
      append form "f"
      set num [format $form $num]

# remove trailing zeros
      if {[string first "." $num] != -1} {
        for {set i 0} {$i < $prec} {incr i} {
          set num [string trimright $num "0"]
        }
        if {$num == "-0"} {set num 0.}
      }
    } errmsg]} {
      errorMsg "# $errmsg ($numsav reset to 0.0)" red
      set num 0.
    }

# save the number for next occurrence
    set unq_num($numsav) $num
  }
  return $num
}

#-------------------------------------------------------------------------------
proc outputMsg {msg {color "black"}} {
  global outputWin opt logFile

  if {[info exists outputWin]} {
    $outputWin issue "$msg " $color
    update idletasks
  } else {
    puts $msg
  }
  if {$opt(LOGFILE) && [info exists logFile]} {puts $logFile $msg}
}

#-------------------------------------------------------------------------------
proc errorMsg {msg {color ""}} {
  global errmsg outputWin stepAP opt logFile

  set oklog 0
  if {$opt(LOGFILE) && [info exists logFile]} {set oklog 1}
  
# check if error message has already been used
  if {![info exists errmsg]} {set errmsg ""}
  if {[string first $msg $errmsg] == -1} {

# save current message to the beginning of errmsg
    set errmsg "$msg\n$errmsg"
    
# this fix is necessary to handle messages related to inverses
    set c1 [string first "DELETETHIS" $msg]
    if {$c1 != -1} {set msg [string range $msg 0 $c1-1]}

# syntax error
    if {$color == ""} {
      if {[string first "syntax error" [string tolower $msg]] != -1} {
        if {$stepAP != ""} {
          set logmsg "*** $msg"
          if {[info exists outputWin]} { 
            $outputWin issue "$msg " syntax
          } else {
            puts $logmsg
          }
        }

# regular error message, ilevel is the procedure the error was generated in
      } else {
        set ilevel ""
        catch {set ilevel "  \[[lindex [info level [expr {[info level]-1}]] 0]\]"}
        if {$ilevel == "  \[errorMsg\]"} {set ilevel ""}
        
        set logmsg "*** $msg$ilevel"
        if {[info exists outputWin]} { 
          $outputWin issue "$msg$ilevel " error
        } else {
          puts $logmsg
        }
      }

# error message with color
    } else {
      set logmsg "*** $msg"
      if {[info exists outputWin]} { 
        $outputWin issue "$msg " $color
      } else {
        puts $logmsg
      }
    }
    update idletasks

# add message to logfile
    if {$oklog && [info exists logmsg]} {
      if {[string first "*" $logmsg] == -1} {
        puts $logFile $logmsg
      } else {
        set newmsg [split [string range $logmsg 4 end] "\n"]
        set logmsg ""
        foreach str $newmsg {append logmsg "\n*** $str"}
        puts $logFile [string range $logmsg 1 end]
      }
    }
    return 1

# error message already used, do nothing
  } else {
    return 0
  }
}

# -------------------------------------------------------------------------------------------------
proc truncFileName {fname {compact 0}} {
  global mydocs myhome mydesk

  if {[string first $mydocs $fname] == 0} {
    set nname "[string range $fname 0 2]...[string range $fname [string length $mydocs] end]"
  } elseif {[string first $mydesk $fname] == 0 && $mydesk != $fname} {
    set nname "[string range $fname 0 2]...[string range $fname [string length $mydesk] end]"
  #} elseif {[string first $myhome $fname] == 0 && $myhome != $fname} {
  #  set nname "[string range $fname 0 2]...[string range $fname [string length $myhome] end]"
  }

  if {[info exists nname]} {
    if {$nname != "C:\\..."} {set fname $nname}
  }

  if {$compact} {
    catch {
      while {[string length $fname] > 80} {
        set nname $fname
        set s2 0
        if {[string first "\\\\" $nname] == 0} {
          set nname [string range $nname 2 end]
          set s2 1
        }

        set nname [file nativename $nname]
        set sname [split $nname [file separator]]
        if {[llength $sname] <= 3} {break}

        if {[lindex $sname 1] == "..."} {
          set sname [lreplace $sname 2 2]
        } else {
          set sname [lreplace $sname 1 1 "..."]
        }

        set nname ""
        set nitem 0
        foreach item $sname {
          if {$nitem == 0 && [string length $item] == 2 && [string index $item 1] == ":"} {append item "/"}
          set nname [file join $nname $item]
          incr nitem
        }
        if {$s2} {set nname \\\\$nname}
        set fname [file nativename $nname]
      }
    }
  }
  return $fname
}

#-------------------------------------------------------------------------------
# copy schema rose files that are in the Tcl Virtual File System (VFS) to the IFCsvr dll directory
# this only works with Tcl 8.5.15 and lower
proc copyRoseFiles {} {
  global pf32 pf64 wdir mytemp env ifcsvrDir nistVersion contact stepAPs

# rose files in SFA distribution
  if {[file exists $ifcsvrDir]} {
    if {[llength [glob -nocomplain -directory [file join $wdir schemas] *.rose]] > 0} {
      set ok 1
      foreach fn [glob -nocomplain -directory [file join $wdir schemas] *.rose] {
          
        set fn1 [file tail $fn]
        set f2 [file join $ifcsvrDir $fn1]
        set okcopy 0
        if {![file exists $f2]} {
          set okcopy 1
        } elseif {[file mtime $fn] > [file mtime $f2]} {
          set okcopy 1
        }

# copy files
        if {$okcopy} {
          catch {.tnb select .tnb.status}
          if {[catch {
            errorMsg "\nInstalling new or updated STEP schema files (Help > Supported STEP APs)" red
            outputMsg " [string toupper [file rootname $fn1]]"
            file copy -force $fn $f2
          } emsg]} {
            errorMsg "ERROR copying STEP schema files (*.rose) to $ifcsvrDir"
            #errorMsg "ERROR copying STEP schema files (*.rose) to $ifcsvrDir: $emsg"
          }
          if {![file exists [file join $ifcsvrDir $fn1]]} {
            set ok 0
            catch {file copy -force $fn [file join $mytemp $fn1]}
          }
        }
      }

# error copying files
      if {!$ok} {
        catch {.tnb select .tnb.status}
        update idletasks
        errorMsg "STEP schema files (*.rose) could not be copied to the IFCsvr/dll directory."
        after 1000
        outputMsg " "
        errorMsg "Opening folder containing the *.rose files: $mytemp"
        outputMsg "Copy the *.rose files in $mytemp\n to [file nativename $ifcsvrDir]" red
        outputMsg "You should copy the files with administrator privileges (Run as administrator), if possible.\nIf there are problems copying the *.rose files, contact [lindex $contact 0] ([lindex $contact 1]).\nSee Help > Supported STEP APs to see which STEP schemas are supported." red
        after 1000
        if {[catch {
          exec {*}[auto_execok start] [file nativename $mytemp]
        } emsg]} {
          if {[string first "UNC" $emsg] == -1} {errorMsg "ERROR opening directory: $emsg"}
        }
      }
    }

# rose files in STEP Tools distribution
    if {[info exists env(ROSE)]} {
      set n [string range $env(ROSE) end-2 end-1]
      set stdir [file join $pf32 "STEP Tools" "ST-Runtime $n" schemas]
      if {![file exists $stdir]} {set stdir [file join $pf64 "STEP Tools" "ST-Runtime $n" schemas]}
      
      if {[file exists $stdir]} {
        set ok 1
        foreach fn [glob -nocomplain -directory $stdir *.rose] {
          set fn1 [file tail $fn]
          if {[string first "_EXP" $fn1] == -1 && ([string first "ap" $fn1] == 0 || [info exists stepAPs([string toupper [file rootname $fn1]])])} {
            set f2 [file join $ifcsvrDir $fn1]
            set okcopy 0
            if {![file exists $f2]} {
              set okcopy 1
            } elseif {[file mtime $fn] > [file mtime $f2]} {
              set okcopy 1
            }
            if {$okcopy} {
              catch {.tnb select .tnb.status}
              catch {
                file copy -force $fn $f2
                errorMsg "Installing STEP schema files from STEP Tools (Help > Supported STEP APs)" red
              }
            }
          }
        }      
      }
    }

# IFCsvr toolkit not found
  } else {
    #errorMsg "ERROR: IFCsvr Toolkit needs to be installed before copying STEP schema files (*.rose) to\n $ifcsvrDir"
  }
}

#-------------------------------------------------------------------------------
# install IFCsvr
proc installIFCsvr {} {
  global wdir mydocs mytemp ifcsvrDir nistVersion buttons contact

  set ifcsvr     "ifcsvrr300_setup_1008_en.msi"
  set ifcsvrInst [file join $wdir exe $ifcsvr]

# install if not already installed
  if {[info exists buttons]} {.tnb select .tnb.status}
  outputMsg " "
  errorMsg "The IFCsvr Toolkit needs to be installed to read and process STEP files (User Guide section 2.2.1)."
  outputMsg "- You might need administrator privileges (Run as administrator) to install the
  toolkit.  Antivirus software might respond that there is a security issue with
  the toolkit.  The toolkit is safe to install.  Use the default installation
  folder for the toolkit.
- See Help > Supported STEP APs to see which type of STEP files are supported.
- To reinstall the toolkit, run the installation file ifcsvrr300_setup_1008.en.msi
  in $mytemp
  or your home directory or the current directory.
- If there are problems with the IFCsvr installation, contact [lindex $contact 0] ([lindex $contact 1])."

  if {[file exists $ifcsvrInst] && [info exists buttons]} {
    set msg "The IFCsvr Toolkit needs to be installed to read and process STEP files (User Guide section 2.2.1).  After clicking OK the IFCsvr Toolkit installation will start."
    append msg "\n\nYou might need administrator privileges (Run as administrator) to install the toolkit.  Antivirus software might respond that there is a security issue with the toolkit.  The toolkit is safe to install.  Use the default installation folder for the toolkit."
    append msg "\n\nSee Help > Supported STEP APs to see which type of STEP files are supported."
    append msg "\n\nIf there are problems with the IFCsvr installation, contact [lindex $contact 0] ([lindex $contact 1])."
    set choice [tk_messageBox -type ok -message $msg -icon info -title "Install IFCsvr"]
    outputMsg "\nWait for the installation to complete before generating a spreadsheet or view.\n" red
  } elseif {![info exists buttons]} {
    outputMsg "\nRerun this program after the installation has completed to process a STEP file.\n"
  }

# try copying installation file to several locations
  set ifcsvrMsi [file join $mytemp $ifcsvr]
  if {[file exists $ifcsvrInst]} {
    if {[catch {
      file copy -force $ifcsvrInst $ifcsvrMsi
    } emsg1]} {
      set ifcsvrMsi [file join $mydocs $ifcsvr]
      if {[catch {
        file copy -force $ifcsvrInst $ifcsvrMsi
      } emsg2]} {
        set ifcsvrMsi [file join [pwd] $ifcsvr]
        if {[catch {
          file copy -force $ifcsvrInst $ifcsvrMsi
        } emsg3]} {
          errorMsg "ERROR copying the IFCsvr Toolkit installation file to a directory."
          outputMsg " $emsg1\n $emsg2\n $emsg3"
        }
      }
    }
  }

# ready or not to install
  if {[file exists $ifcsvrMsi]} {
    if {[catch {
      exec {*}[auto_execok start] "" $ifcsvrMsi
    } emsg]} {
      if {[string first "UNC" $emsg] == -1} {errorMsg "ERROR installing IFCsvr Toolkit: $emsg"}
    }
  } else {
    if {[file exists $ifcsvrInst]} {errorMsg "The IFCsvr Toolkit cannot be automatically installed."}
    catch {.tnb select .tnb.status}
    update idletasks
    if {$nistVersion} {
      outputMsg "To manually install the IFCsvr Toolkit:
- The installation file ifcsvrr300_setup_1008.en.msi can be found in either:
  $mytemp or your home directory or the current directory.
- Run the installer and follow the instructions.  Use the default installation folder for IFCsvr.
  You might need administrator privileges (Run as administrator) to install the toolkit.
- If there are problems with the IFCsvr installation, contact [lindex $contact 0] ([lindex $contact 1])\n"
      after 1000
      errorMsg "Opening folder: $mytemp"
      if {[catch {
        exec {*}[auto_execok start] [file nativename $mytemp]
      } emsg]} {
        if {[string first "UNC" $emsg] == -1} {errorMsg "ERROR opening directory: $emsg"}
      }
    } else {
      outputMsg "To install the IFCsvr Toolkit you must install the NIST version of the STEP File Analyzer and Viewer."
      outputMsg "1 - Go to https://concrete.nist.gov/cgi-bin/ctv/sfa_request.cgi"
      outputMsg "2 - Fill out the form, submit it, and follow the instructions."
      outputMsg "3 - The IFCsvr Toolkit will be installed when the NIST STEP File Analyzer and Viewer is run."
      outputMsg "4 - Generate a spreadsheet for at least one STEP file."
      after 1000
      openURL https://concrete.nist.gov/cgi-bin/ctv/sfa_request.cgi
    }
  }
}

#-------------------------------------------------------------------------------
# shortcuts
proc setShortcuts {} {
  global mydesk mymenu mytemp nistVersion wdir tcl_platform
  
  set progname [info nameofexecutable]
  if {[string first "AppData/Local/Temp" $progname] != -1 || [string first ".zip" $progname] != -1} {
    errorMsg "For the STEP File Analyzer and Viewer to run properly, it is recommended that you first\n extract all of the files from the ZIP file and run the extracted executable."
    return
  }

  set progstr  "STEP File Analyzer and Viewer"
  if {!$nistVersion} {set progstr "SFA"}
  
  if {[info exists mydesk] || [info exists mymenu]} {
    set ok 1
    set app ""
    
# delete old shortcuts    
    set progstr1 "STEP File Analyzer"
    foreach scut [list "Shortcut to $progstr1.exe.lnk" "$progstr1.exe.lnk" "$progstr1.lnk"] {
      catch {
        if {[file exists [file join $mydesk $scut]]} {
          file delete [file join $mydesk $scut]
          set ok 0
        }
        if {[file exists [file join $mymenu "$progstr1.lnk"]]} {file delete [file join $mymenu "$progstr1.lnk"]}
      }
    }
    if {[file exists [file join $mydesk [file tail [info nameofexecutable]]]]} {set ok 0}

    set msg "Do you want to create or overwrite shortcuts to the $progstr (v[getVersion])"
    if {[info exists mydesk]} {
      append msg " on the Desktop"
      if {[info exists mymenu]} {append msg " and"}
    }
    if {[info exists mymenu]} {append msg " in the Start Menu"}
    append msg "?"
      
    if {[info exists mydesk] || [info exists mymenu]} {
      set choice [tk_messageBox -type yesno -icon question -title "Shortcuts" -message $msg]
      if {$choice == "yes"} {
        outputMsg " "
        if {$nistVersion} {catch {[file copy -force [file join $wdir images NIST.ico] [file join $mytemp NIST.ico]]}}
        catch {
          if {[info exists mymenu]} {
            if {[file exists [file join $mymenu "$progstr.lnk"]]} {outputMsg "Existing Start Menu shortcut will be overwritten" red}
            if {$nistVersion} {
              if {$tcl_platform(osVersion) >= 6.2} {
                twapi::write_shortcut [file join $mymenu "$progstr.lnk"] -path [info nameofexecutable] -desc $progstr -iconpath [info nameofexecutable]
              } else {
                twapi::write_shortcut [file join $mymenu "$progstr.lnk"] -path [info nameofexecutable] -desc $progstr -iconpath [file join $mytemp NIST.ico]
              }
            } else {
              twapi::write_shortcut [file join $mymenu "$progstr.lnk"] -path [info nameofexecutable] -desc $progstr
            }
            outputMsg " Shortcut created in Start Menu to [truncFileName [file nativename [info nameofexecutable]]]"
          }
        }
  
        if {$ok} {
          catch {
            if {[info exists mydesk]} {
              if {[file exists [file join $mydesk "$progstr.lnk"]]} {outputMsg "Existing Desktop shortcut will be overwritten" red}
              if {$nistVersion} {
                if {$tcl_platform(osVersion) >= 6.2} {
                  twapi::write_shortcut [file join $mydesk "$progstr.lnk"] -path [info nameofexecutable] -desc $progstr -iconpath [info nameofexecutable]
                } else {
                  twapi::write_shortcut [file join $mydesk "$progstr.lnk"] -path [info nameofexecutable] -desc $progstr -iconpath [file join $mytemp NIST.ico]
                }
              } else {
                twapi::write_shortcut [file join $mydesk "$progstr.lnk"] -path [info nameofexecutable] -desc $progstr
              }
              outputMsg " Shortcut created on Desktop to [truncFileName [file nativename [info nameofexecutable]]]"
            }
          }
        }
      }
    }
  }
}

#-------------------------------------------------------------------------------
# set home, docs, desktop, menu directories
proc setHomeDir {} {
  global env tcl_platform drive myhome mydocs mydesk mymenu mytemp virtualDir

  set drive "C:/"
  if {[info exists env(SystemDrive)]} {
    set drive $env(SystemDrive)
    append drive "/"
  }
  set myhome $drive

# set mydocs, mydesk, mymenu based on USERPROFILE and registry entries
  if {[info exists env(USERPROFILE)]} {
    set myhome $env(USERPROFILE)
    
    catch {
      set reg_personal [registry get {HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders} {Personal}]
      if {[string first "%USERPROFILE%" $reg_personal] == 0} {regsub "%USERPROFILE%" $reg_personal $env(USERPROFILE) mydocs}
    }
    catch {
      set reg_desktop  [registry get {HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders} {Desktop}]
      if {[string first "%USERPROFILE%" $reg_desktop] == 0} {regsub "%USERPROFILE%" $reg_desktop $env(USERPROFILE) mydesk}
    }
    catch {
      set reg_menu [registry get {HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders} {Programs}]
      if {[string first "%USERPROFILE%" $reg_menu] == 0} {regsub "%USERPROFILE%" $reg_menu $env(USERPROFILE) mymenu}
    }
    
# set mytemp
    catch {
      if {$tcl_platform(osVersion) >= 6.0} {
        set reg_temp [registry get {HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders} {Local AppData}]
      } else {
        set reg_temp [registry get {HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders} {Local Settings}]
      }
      if {[string first "%USERPROFILE%" $reg_temp] == 0} {regsub "%USERPROFILE%" $reg_temp $env(USERPROFILE) mytemp}
      set mytemp [file join $mytemp Temp]

# make mytemp dir
      set mytemp [file nativename [file join $mytemp SFA]]
      checkTempDir
    }

# create myhome if USERPROFILE does not exist 
  } elseif {[info exists env(USERNAME)]} {
    set myhome [file join $drive Users $env(USERNAME)]
    if {$tcl_platform(osVersion) < 6.0} {set myhome [file join $drive "Documents and Settings" $env(USERNAME)]}
  }

  if {![info exists mydocs]} {
    set mydocs $myhome
    set docs "Documents"
    if {$tcl_platform(osVersion) < 6.0} {set docs "My Documents"}
    set docs [file join $mydocs $docs]
    if {[file exists $docs]} {if {[file isdirectory $docs]} {set mydocs $docs}}
  }

  if {![info exists mydesk]} {
    set mydesk $myhome
    set desk "Desktop"
    set desk [file join $mydesk $desk]
    if {[file exists $desk]} {if {[file isdirectory $desk]} {set mydesk $desk}}
  }
  
  if {![info exists mytemp]} {
    set mytemp $myhome
    set temp [file join AppData Local Temp SFA]
    if {$tcl_platform(osVersion) < 6.0} {set temp [file join "Local Settings" Temp SFA]}
    set mytemp [file join $mytemp $temp]
    checkTempDir
  }

  set myhome [file nativename $myhome]
  set mydocs [file nativename $mydocs]
  set mydesk [file nativename $mydesk]
  set mytemp [file nativename $mytemp]

# virtualStore directory  
  if {$tcl_platform(osVersion) >= 6.0} {
    if {[info exists env(APPDATA)]} {
      set appData [string range $env(APPDATA) 0 [string last "\\" $env(APPDATA)]-1]
      set virtualDir [file nativename [file join $appData Local VirtualStore [string range $env(ProgramFiles) 3 end] IFCsvrR300 dll]]
    } elseif {[info exists env(USERNAME)]} {
      set virtualDir [file nativename [file join $drive Users $env(USERNAME) AppData Local VirtualStore [string range $env(ProgramFiles) 3 end] IFCsvrR300 dll]]
    }
  }
}

#-------------------------------------------------------------------------------
proc checkTempDir {} {
  global mytemp

  if {[info exists mytemp]} {
    if {[file isfile $mytemp]} {file delete -force $mytemp}
    if {![file exists $mytemp]} {file mkdir $mytemp}
  }
}

#-------------------------------------------------------------------------------
proc fixTimeStamp {ts} {
  set c1 [string last "+" $ts]
  if {$c1 != -1} {set ts [string range $ts 0 $c1-1]}
  set c1 [string last "-" $ts]
  if {$c1 > 8} {set ts [string range $ts 0 $c1-1]}
  set c1 [string first ":" $ts]
  set c2 [string last  ":" $ts]
  if {$c1 != $c2 && $c2 != -1} {set ts [string range $ts 0 $c2-1]}
  if {[string index $ts end] == "T"} {set ts [string range $ts 0 end-1]}
  return $ts
}

#-------------------------------------------------------------------------------
proc getTiming {{str ""}} {
  global tlast

  set t [clock clicks -milliseconds]
  if {[info exists tlast]} {outputMsg "Timing: [expr {($t-$tlast)}]  $str" red}
  set tlast $t
}

#-------------------------------------------------------------------------------
# From http://wiki.tcl.tk/4021
proc sortlength2 {wordlist} {
  set words {}
  foreach word $wordlist {
    lappend words [list [string length $word] $word]
  }
  set result {}
  foreach pair [lsort -decreasing -integer -index 0 [lsort -ascii -index 1 $words]] {
    lappend result [lindex $pair 1]
  }
  return $result
}

#-------------------------------------------------------------------------------
# From http://wiki.tcl.tk/3070
proc stringSimilarity {a b} {
  set totalLength [max [string length $a] [string length $b]]
  return [string range [max [expr {double($totalLength-[levenshteinDistance $a $b])/$totalLength}] 0.0] 0 4]
}

proc levenshteinDistance {s t} {
  if {![set n [string length $t]]} {
    return [string length $s]
  } elseif {![set m [string length $s]]} {
    return $n
  }
  for {set i 0} {$i <= $m} {incr i} {
    lappend d 0
    lappend p $i
  }
  for {set j 0} {$j < $n} {} {
    set tj [string index $t $j]
    lset d 0 [incr j]
    for {set i 0} {$i < $m} {} {
      set a [expr {[lindex $d $i]+1}]
      set b [expr {[lindex $p $i]+([string index $s $i] ne $tj)}]
      set c [expr {[lindex $p [incr i]]+1}]
      lset d $i [expr {$a<$b ? $c<$a ? $c : $a : $c<$b ? $c : $b}]
    }
    set nd $p; set p $d; set d $nd
  }
  return [lindex $p end]
}

#-------------------------------------------------------------------------------
# Based on http://www.posoft.de/html/extCawt.html
proc GetWorksheetAsMatrix {worksheetId} {
  set cellId [[$worksheetId Cells] Range [GetCellRange 1 1 [[[$worksheetId UsedRange] Rows] Count] [[[$worksheetId UsedRange] Columns] Count]]]
  set matrixList [$cellId Value2]
  return $matrixList
}

proc GetCellRange {row1 col1 row2 col2} {
  set range [format "%s%d:%s%d" [ColumnIntToChar $col1] $row1 [ColumnIntToChar $col2] $row2]
  return $range
}

proc ColumnIntToChar {col} {
  if {$col <= 0} {errorMsg "Column number $col is invalid."}
  set dividend $col
  set columnName ""
  while {$dividend > 0} {
    set modulo [expr {($dividend - 1) % 26} ]
    set columnName [format "%c${columnName}" [expr {65 + $modulo}]]
    set dividend [expr {($dividend - $modulo) / 26}]
  }
  return $columnName
}

#-------------------------------------------------------------------------------
proc compareLists {str l1 l2} {
  set l3 [intersect3 $l1 $l2]
  outputMsg "\n$str" red
  outputMsg "Unique to L1   ([llength [lindex $l3 0]])\n  [lindex $l3 0]"
  outputMsg "Common to both ([llength [lindex $l3 1]])\n  [lindex $l3 1]"
  outputMsg "Unique to L2   ([llength [lindex $l3 2]])\n  [lindex $l3 2]"
}
