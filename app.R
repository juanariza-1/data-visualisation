library(shiny)
library(leaflet)
library(sf)
library(dplyr)
library(ggplot2)
library(scales)

# =========================
# 1. LOAD FINAL DATA
# =========================

shape_us <- readRDS("data/private/shape_us_final.rds")

state_lookup <- c(
  "01"="Alabama","04"="Arizona","05"="Arkansas","06"="California","08"="Colorado",
  "09"="Connecticut","10"="Delaware","11"="District of Columbia","12"="Florida",
  "13"="Georgia","16"="Idaho","17"="Illinois","18"="Indiana","19"="Iowa",
  "20"="Kansas","21"="Kentucky","22"="Louisiana","23"="Maine","24"="Maryland",
  "25"="Massachusetts","26"="Michigan","27"="Minnesota","28"="Mississippi",
  "29"="Missouri","30"="Montana","31"="Nebraska","32"="Nevada","33"="New Hampshire",
  "34"="New Jersey","35"="New Mexico","36"="New York","37"="North Carolina",
  "38"="North Dakota","39"="Ohio","40"="Oklahoma","41"="Oregon","42"="Pennsylvania",
  "44"="Rhode Island","45"="South Carolina","46"="South Dakota","47"="Tennessee",
  "48"="Texas","49"="Utah","50"="Vermont","51"="Virginia","53"="Washington",
  "54"="West Virginia","55"="Wisconsin","56"="Wyoming"
)

shape_us_leaflet <- shape_us %>%
  st_transform(4326) %>%
  st_make_valid() %>%
  mutate(
    STATEFP = as.integer(STATEFP),
    state_fips = sprintf("%02d", STATEFP),
    state_name = unname(state_lookup[state_fips]),
    pop_other_total = pop_other + pop_two
  ) %>%
  filter(!is.na(state_name), !is.na(total_pop))

counties_df <- shape_us_leaflet %>%
  st_drop_geometry() %>%
  select(
    GEOID, NAME, state_name,
    pop_white, pop_black, pop_native, pop_asian, pop_other_total, total_pop
  )

bins_pop <- unique(quantile(shape_us_leaflet$total_pop, probs = seq(0, 1, length.out = 7), na.rm = TRUE))

pal_pop <- colorBin(
  palette = "YlOrBr",
  domain = shape_us_leaflet$total_pop,
  bins = bins_pop,
  pretty = FALSE,
  na.color = "lightgray"
)

default_state <- "California"

# =========================
# 2. UI
# =========================

ui <- fluidPage(
  titlePanel("US county population in 2010"),
  
  fluidRow(
    column(
      width = 4,
      selectInput(
        "state",
        "State:",
        choices = sort(unique(counties_df$state_name)),
        selected = default_state,
        selectize = FALSE
      )
    ),
    column(
      width = 4,
      uiOutput("county_ui")
    )
  ),
  
  br(),
  
  fluidRow(
    column(
      width = 12,
      leafletOutput("map_shape", height = 470)
    )
  ),
  
  br(),
  
  fluidRow(
    column(
      width = 6,
      plotOutput("plot_counts", height = 320)
    ),
    column(
      width = 6,
      plotOutput("plot_share", height = 320)
    )
  )
)

# =========================
# 3. SERVER
# =========================

server <- function(input, output, session) {
  
  selected_from_map <- reactiveVal(NULL)
  
  counties_in_state <- reactive({
    req(input$state)
    
    counties_df %>%
      filter(state_name == input$state) %>%
      arrange(NAME)
  })
  
  output$county_ui <- renderUI({
    df <- counties_in_state()
    req(nrow(df) > 0)
    
    selected_county <- NULL
    
    if (!is.null(selected_from_map()) && selected_from_map() %in% df$GEOID) {
      selected_county <- selected_from_map()
    } else if (input$state == "California" && "Los Angeles" %in% df$NAME) {
      selected_county <- df$GEOID[df$NAME == "Los Angeles"][1]
    } else {
      selected_county <- df$GEOID[1]
    }
    
    selectInput(
      "county",
      "County:",
      choices = setNames(df$GEOID, df$NAME),
      selected = selected_county,
      selectize = FALSE
    )
  })
  
  observeEvent(input$map_shape_shape_click, {
    click <- input$map_shape_shape_click
    req(click$id)
    
    clicked_row <- counties_df %>%
      filter(GEOID == click$id)
    
    req(nrow(clicked_row) == 1)
    
    selected_from_map(click$id)
    updateSelectInput(session, "state", selected = clicked_row$state_name[1])
  })
  
  selected_county_df <- reactive({
    req(input$county)
    
    out <- counties_df %>%
      filter(GEOID == input$county)
    
    req(nrow(out) == 1)
    out
  })
  
  selected_county_sf <- reactive({
    req(input$county)
    
    out <- shape_us_leaflet %>%
      filter(GEOID == input$county)
    
    req(nrow(out) == 1)
    out
  })
  
  race_df <- reactive({
    x <- selected_county_df()
    
    data.frame(
      race = factor(
        c("white", "black", "native", "asian", "other"),
        levels = c("white", "black", "native", "asian", "other")
      ),
      population = c(
        x$pop_white,
        x$pop_black,
        x$pop_native,
        x$pop_asian,
        x$pop_other_total
      )
    ) %>%
      mutate(
        share = population / sum(population, na.rm = TRUE)
      )
  })
  
  output$map_shape <- renderLeaflet({
    leaflet(
      shape_us_leaflet,
      options = leafletOptions(preferCanvas = TRUE)
    ) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        layerId = ~GEOID,
        fillColor = ~pal_pop(total_pop),
        fillOpacity = 0.9,
        color = "black",
        weight = 0.3,
        opacity = 0.7,
        smoothFactor = 0.2,
        label = ~paste0(NAME, ", ", state_name, " | Pop: ", comma(total_pop)),
        popup = ~paste0(
          "<strong>Total Population:</strong> ", comma(total_pop), "<br>",
          "<strong>County ID:</strong> ", GEOID, "<br>",
          "<strong>County:</strong> ", NAME, "<br>",
          "<strong>State:</strong> ", state_name
        )
      ) %>%
      addLegend(
        pal = pal_pop,
        values = ~total_pop,
        opacity = 0.9,
        title = "Total Pop.",
        position = "bottomright"
      )
  })
  
  observe({
    sf_sel <- selected_county_sf()
    
    leafletProxy("map_shape") %>%
      clearGroup("selected") %>%
      addPolygons(
        data = sf_sel,
        group = "selected",
        fill = FALSE,
        color = "#00BFC4",
        weight = 4
      )
  })
  
  output$plot_counts <- renderPlot({
    df <- race_df()
    county_name <- selected_county_df()$NAME
    
    ggplot(df, aes(x = population / 1e6, y = race, fill = race)) +
      geom_col(width = 0.7, show.legend = FALSE) +
      geom_text(
        aes(label = paste0(round(population / 1e6, 2), "M")),
        hjust = -0.12,
        size = 4.2
      ) +
      scale_x_continuous(
        labels = label_number(accuracy = 0.1),
        expand = expansion(mult = c(0, 0.08))
      ) +
      labs(
        title = paste0(county_name, " County: population by race"),
        x = "Population (millions)",
        y = NULL
      ) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title = element_text(face = "bold"),
        axis.text.y = element_text(color = "black"),
        panel.grid.minor = element_blank()
      )
  })
  
  output$plot_share <- renderPlot({
    df <- race_df()
    county_name <- selected_county_df()$NAME
    
    ggplot(df, aes(x = share, y = race, fill = race)) +
      geom_col(width = 0.7, show.legend = FALSE) +
      geom_text(
        aes(label = percent(share, accuracy = 0.1)),
        hjust = -0.12,
        size = 4.2
      ) +
      scale_x_continuous(
        labels = percent_format(accuracy = 1),
        limits = c(0, max(df$share) * 1.12),
        expand = expansion(mult = c(0, 0.02))
      ) +
      labs(
        title = paste0(county_name, " County: population share by race"),
        x = "Population share",
        y = NULL
      ) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title = element_text(face = "bold"),
        axis.text.y = element_text(color = "black"),
        panel.grid.minor = element_blank()
      )
  })
}

shinyApp(ui = ui, server = server)