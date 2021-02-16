
#install.packages("DT", "readtext", "shinyjs", "configr", "shinyalert", "zip")

#some commented to create more lightweight docker container
#library(shinyLP)
#library(shinycssloaders)
library(DT)
library(shinyjs)
library(readtext)
library(configr)
#library(shinybusy)
library(shinyalert)
library(zip)
source("Utils.R")

options(shiny.maxRequestSize=100*1024^2)
options(shiny.port = 8080)
options(shiny.host = "0.0.0.0")


set.seed(100)

#defined in Rtils.r
mocap_data_file_loc <- BASE_DIR



read_mocap_csv_data <- function(file_loc){
  return(load_db(mocap_data_file_loc))
}

query_mocap_descriptor <- function(mocap_data_frame, query_string){
  return(mocap_data_frame[grep(query_string, mocap_data_frame$"Description"),])
}

mocap_dataframe <<- read_mocap_csv_data(mocap_data_file_loc)
files_to_export_dataframe <<- mocap_dataframe[0,]



write_ini <- function(ini_file_loc, asset_file, retarget_anims_dir, source_anims_dir){
  list_to_write <- list()
  list_to_write[["DEFAULT"]] <- list(folder_to_merge = source_anims_dir, 
                        output_folder_loc = retarget_anims_dir, 
                        output_file_base_name = "Retargeted_",
                        source_namespace = "CMU_",
                        target_filename = asset_file,
                        target_namespace = "Target_"
                        )
  write.config(list_to_write, ini_file_loc, "ini")
}

server <- function(input, output) {
  
  #animations_to_export
  rv <- reactiveValues(data = NULL,
                       deletedRows = NULL,
                       deletedRowIndices = list()
  )
  
  selected_animation_file <<- ""
  files_to_retarget <<- c()
  
  output$bvh_viewer <- renderUI({

    includeHTML("./BVH_playerEdited.html")

  })
  
  output$animations_to_export <- DT::renderDataTable({
    
    display_df <- deleteButtonColumn(mocap_dataframe[rv$data,c("File.Name", "Description", "Motion.Capture.Class", "Origin")], 'delete_button')
    print("nrows display_df: ")
    print(nrow(display_df))
    
    return(display_df)
    
  })
  
  observeEvent(input$add_to_export_list, {
    matching_rows <- isolate(input$animation_search_results_rows_selected)
    if(is.null(matching_rows)){
      showNotification("You haven't selected a file to add to the export list")
    }
    else{
      if(!matching_rows %in% rv$data){
        rv$data <- append(rv$data, matching_rows)
      }
      
      #files_to_export_dataframe <<- rbind(files_to_export_dataframe, mocap_dataframe[matching_rows, ])
      print(paste("rv$data: ", rv$data))
      
    }
  })
  
  observeEvent(input$deletePressed, {
    
    rowNum <- parseDeleteEvent(input$deletePressed)
    mocapDeleteIndex <- rv$data[rowNum]
    
    print(paste("deleted row number: ", rowNum, " in the export list."))
    dataRow <- mocap_dataframe[mocapDeleteIndex,]
    
    # Put the deleted row into a data frame so we can undo
    # Last item deleted is in position 1
    rv$deletedRows <- rbind(rv$deletedRows, dataRow)
    
    print("rv$deletedRowIndices")
    print(rv$deletedRowIndices)
    
    rv$deletedRowIndices <- unlist(append(rv$deletedRowIndices, mocapDeleteIndex))
    
    print("rv$deletedRowIndices")
    print(rv$deletedRowIndices)
    
    
    # Delete the row from the data frame
    rv$data <- rv$data[-rowNum]
    
    print("rv$data: ")
    print(rv$data)
    
  })
  
  output$animation_search_results <- DT::renderDataTable({
    #input$animation_keyword_button
    #carry out search procedure
    query_string <- isolate(input$animation_search_results_search)
    
    if(length(query_string) > 0){
      print(query_string)
      print(paste("Searching for", query_string))
      matching_rows <<- query_mocap_descriptor(mocap_dataframe, query_string)
      print(paste("showing ", nrow(matching_rows), " rows"))
      return(DT::datatable(matching_rows[, c("File.Name", "Description", "Motion.Capture.Class", "Origin")], 
                           selection = 'single', rownames= FALSE, filter = "top"
                           ))
    }
    else{
      return(DT::datatable(mocap_dataframe[, c("File.Name", "Description", "Motion.Capture.Class", "Origin")], 
                           selection = 'single', rownames= FALSE, filter = "top"
      ))
    }
  })
  
  
  observeEvent(input$undo, {
    
    
    if(length(rv$deletedRowIndices) > 0) {
      #row <- rv$deletedRows[1, ]
      #rv$data <- addRowAt(rv$data, row, rv$deletedRowIndices[[1]])
      print("rv$deletedRowIndices")
      print(rv$deletedRowIndices)
      print("row index to undo: ")
      print(rv$deletedRowIndices[-1])
      rv$data <- append(rv$data, rv$deletedRowIndices[length(rv$deletedRowIndices)])
      print("Undoing")
      print("rv$data: ")
      print(rv$data)
      
      # Remove row
      rv$deletedRows <- rv$deletedRows[-1,]
      # Remove index
      rv$deletedRowIndices <- rv$deletedRowIndices[-length(rv$deletedRowIndices)]
    }
  })
  
  output$undoUI <- renderUI({
    if(!is.null(rv$deletedRows) && nrow(rv$deletedRows) > 0) {
      actionButton('undo', label = 'Undo delete', icon('undo'))
    } else {
      actionButton('undo', label = 'Undo delete', icon('undo'), disabled = TRUE)
    }
  })
  
  
  
  observeEvent(input$animation_search_results_rows_selected,{
    if(length(input$animation_search_results_rows_selected)>0){
      #show_spinner()
      print(paste("selected rows: ",input$animation_search_results_rows_selected))
      
      query_string <- isolate(input$animation_search_results_search)
      
      
      if(length(query_string) == 0){
        matching_rows <- mocap_dataframe
      }
      else{
        matching_rows <- input$animation_search_results_rows_selected
      }

      file_name <- paste0("/", mocap_dataframe[input$animation_search_results_rows_selected, 'File.Name'], '.bvh')
      
      print(paste("seaching for animation  file", file_name))
      
      file_location <- get_file_from_db(file_name, mocap_dataframe)
      print(paste("Got file_location", file_location))
      if(is.null(file_location)){
        shinyalert(title = paste("The file ", file_name, "doesn't exist in the database"), type = "error")
        return()
      }
      file_to_upload <- readtext(file_location)
      #cat(file_to_upload$text)
      runjs(paste0("upload_file_api(`", file_to_upload$text, "`);"))
    }
      else{
        alert("No rows selected in data table, please select a row to visualise the animation")
      }
      
    }, ignoreInit = TRUE)

  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("data-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(data, file)
    }
  )
  
  observeEvent(input$clear_export_list,{
    rv$data <- NULL
    rv$deletedRows <- NULL
    rv$deletedRowIndices <- list()
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("output", "zip", sep=".")
    },
    
    content = function(fname) {
      print("exporting")
      files_to_write <- mocap_dataframe[rv$data, "File.Name"]
      file_names <- lapply(files_to_write, function(x) paste0("/", x, '.fbx'))
      print("file paths: ")
      print(file_names)
      fs <- c()
      tmpdir <- tempdir()
      #setwd(tempdir())
      for(file_name in file_names){
        #paste0(FBX_DIR, file_name)
        print(paste("Copying ", paste0(FBX_DIR, file_name), " to ", tmpdir))
        file.copy(paste0(FBX_DIR, file_name), tmpdir)
      }
      
      fs <- unlist(lapply(file_names, function(x) paste0(tmpdir, x)))
      
      print("fs: ")
      print(fs)
      #fname = "animations.zip"
      if(file_ext(fname) != "zip"){
        shinyalert("You must write to a zip file", type = "error")
        
      }
      
      print(paste("Zipping to ", fname))
      res <- zipr(zipfile=fname, files=fs)
      
      
      for(file_name in file_names){
        print(paste("Removing ", paste0(FBX_DIR, file_name), " from ", tmpdir))
        file.remove(paste0(tmpdir, file_name))
      }
      
    },
    contentType = "application/zip"
  )
  
  observeEvent(input$add_to_export_list, {
    #input<- list()
    #input$animation_search_results_rows_selected <- 34
    matching_rows <- input$animation_search_results_rows_selected
    rbind(files_to_export_dataframe, mocap_dataframe[matching_rows, ])
    
  })
  
  runjs("init();")
}


