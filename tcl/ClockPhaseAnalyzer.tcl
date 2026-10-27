# Sources from the hkttd-hdl Git submodule.

puts "INFO: Adding ClockPhaseAnalyzer sources..."
set cpa_files [list \
  [file join $CPA_DIR_PATH sources DdmtdDetector.vhd] \
  [file join $CPA_DIR_PATH sources DdmtdReference.vhd] \
  [file join $CPA_DIR_PATH sources DdmtdSampler.vhd] \
  [file join $CPA_DIR_PATH sources PhaseAccumulator.vhd] \
  [file join $CPA_DIR_PATH sources PhaseAverage.vhd] \
  [file join $CPA_DIR_PATH sources PhaseDetector.vhd] \
  [file join $CPA_DIR_PATH sources PhaseReference.vhd] \
  [file join $CPA_DIR_PATH sources PhaseStepGenerator.vhd] \
  [file join $CPA_DIR_PATH sources defPhase.vhd]
]

foreach source_file $cpa_files {
  if {![file isfile $source_file]} { error "Required ClockPhaseAnalyzer source is missing: $source_file" }
}
add_files -norecurse -fileset sources_1 $cpa_files
set_property library $default_library [get_files $cpa_files]

# IP configurations maintained by the submodule.
set cpa_ip_sources [list \
  [file join $CPA_DIR_PATH sources ip mmcm_ddmtd $CPA_DEVICE_NAME mmcm_ddmtd.xci]
]

foreach xci $cpa_ip_sources {
  if {![file isfile $xci]} { error "Required ClockPhaseAnalyzer IP configuration is missing: $xci" }

  puts "INFO: Importing ClockPhaseAnalyzer IP: $xci"
  set imported_files [import_ip -srcset sources_1 $xci]
  if {[llength $imported_files] == 0} { error "Vivado did not import ClockPhaseAnalyzer IP: $xci" }

  set_property library $default_library $imported_files
  set_property generate_files_for_reference 0 $imported_files
  set_property registered_with_manager 1 $imported_files
}
