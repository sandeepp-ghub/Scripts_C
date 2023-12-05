
foreach clock {

  PIPE16_pma0_PCS_CLK_RATE2DIV_DIV2__PIPE2_CLK_TX
  PIPE16_pma1_PCS_CLK_RATE2DIV_DIV2__PIPE0_CLK_TX
  PIPE16_pma2_PCS_CLK_RATE2DIV_DIV2__PIPE1_CLK_TX
  PIPE16_pma3_PCS_CLK_RATE2DIV_DIV2__PIPE3_CLK_TX

  PIPE16_pma0_PCS_CLK_RATE1_DIV1__PIPE2_PCLK_LNx_i
  PIPE16_pma1_PCS_CLK_RATE1_DIV1__PIPE0_PCLK_LNx_i
  PIPE16_pma2_PCS_CLK_RATE1_DIV1__PIPE1_PCLK_LNx_i
  PIPE16_pma3_PCS_CLK_RATE1_DIV1__PIPE3_PCLK_LNx_i

} {
  report_timing -from [get_clocks $clock] -to phy__qlm?/pma/i_afe/afe_ln?_clk_txdata_i -derate -nosplit -max_paths 16 -slack_less INFINITY > skew_${clock}_${run_type_specific}.rpt
}
