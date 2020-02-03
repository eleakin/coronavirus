# Module UI
  
#' @title   mod_map_ui and mod_map_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_map
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_map_ui <- function(id){
  ns <- NS(id)
  f7Row(
    f7Col(
      f7Card(
        title = "Confirmed Cases - China",
        echarts4r::echarts4rOutput(ns("map"), height = "70vh")
      )
    ),
    f7Col(
      f7Card(
        title = "Confirmed Cases - Worldwide",
        echarts4r::echarts4rOutput(ns("world"), height = "70vh")
      )
    )
  )
}
    
# Module Server
    
#' @rdname mod_map
#' @export
#' @keywords internal
    
mod_map_server <- function(input, output, session, df){
  ns <- session$ns

  output$map <- echarts4r::renderEcharts4r({
    
    dat <- df %>% 
      dplyr::filter(country %in% c("Mainland China", "Hong Kong", "Taiwan")) %>% 
      dplyr::filter(type == "confirmed") %>% 
      dplyr::left_join(chinese_provinces, by = "state") %>% 
      dplyr::group_by(date)

    index <- length(unique(dat$date)) -1 
      
    dat %>% 
      echarts4r::e_charts(chinese, timeline = TRUE) %>% 
      echarts4r.maps::em_map("China") %>% 
      echarts4r::e_map(cases, map = "China") %>% 
      echarts4r::e_visual_map(cases, min = 0) %>% 
      echarts4r::e_theme(theme) %>% 
      echarts4r::e_timeline_opts(currentIndex = index)
  })

  output$world <- echarts4r::renderEcharts4r({
    df %>% 
      dplyr::filter(date == max(date)) %>%
      echarts4r::e_country_names(country_iso2c, country) %>% 
      dplyr::group_by(country) %>% 
      dplyr::summarise(cases = sum(cases, na.rm = TRUE)) %>% 
      dplyr::ungroup() %>% 
      echarts4r::e_charts(country) %>% 
      echarts4r::e_map(cases) %>% 
      echarts4r::e_visual_map(cases) %>% 
      echarts4r::e_theme(theme)
  })
}