

library(dplyr)
library(tools)


DB_FILE_NAME <<- "/motionDB.csv"
MOTION_CLASSES <<- c("Walking", "Running", "Jumping", "Bending_down")

BASE_DIR <- paste0(getwd(), "/..")
BVH_DIR <- paste0(BASE_DIR, "/Database/BVH")
FBX_DIR <- paste0(BASE_DIR, "/Database/FBX")


load_db <- function(base_directory){
  return(read.csv(paste0(base_directory, DB_FILE_NAME), stringsAsFactors=FALSE))
}

write_db <- function(base_directory){
  write.csv(paste0(base_directory, DB_FILE_NAME))
}

is_file_in_db_file <- function(file_name, db){
  #file_name <- 
  return(file_name %in% db$File.Name)
}

get_file_from_db <- function(file_name, db){
  file_name_no_ext <- file_path_sans_ext(basename(file_name))
  if(!is_file_in_db_file(file_name_no_ext, db)){
    print(paste0(file_name, " doesn't exist in the DB"))
    return(NULL)
  }
  if(!verify_file_present(file_name)){
    print(paste0(file_name, " is present in the db listing but the file has been deleted"))
    return(NULL)
  }
  else{
    ext <- file_ext(file_name)
    if(ext == 'fbx'){
      print("returning located fbx")
      return(paste0(FBX_DIR, file_name))
    }
    else if(ext == 'bvh'){
      print("Returning located bvh")
      return(paste0(BVH_DIR, file_name))
    }
    else{
      print(paste("Invalid extension: ", ext))
    }
  }
}

verify_file_present <- function( file_name){
  ext <- file_ext(file_name)
  print(paste("Ext: ", ext))
  if (ext == 'fbx'){
    print(paste("Looking for ", paste0(FBX_DIR, file_name)))
    return(file.exists(paste0(FBX_DIR, file_name)))
  }
  else if(ext == 'bvh'){
    print(paste("Looking for ", paste0(BVH_DIR, file_name)))
    return(file.exists(paste0(BVH_DIR, file_name))) 
  }
  else{
    return(FALSE)
  }
}


upload_file <- function(base_dir, name, description, mocap_class, origin, licence, fbx_loc = '', bvh_loc = ''){
  if(fbx_loc == '' & bvh_loc == ''){
    return(FALSE)
  }
  #check file not already in DB
  db <- load_db(base_dir)
  
  if(verify_file_present(base_dir, name)){
    print(paste(file_name, " already exists in db"))
    return(FALSE)
  }
  
  if(is_file_in_db(name, db)){
    print(paste(file_name, " already exists in db"))
    return(FALSE)
  }
    
    #copy file to DB
  file.copy(fbx_loc, FBX_DIR )
  file.copy(fbx_loc, BVH_DIR )
  
    
    #Update csv
  db[nrow(db) + 1,] = c(name, description, mocap_class, origin, licence)
  
  
}


delete_file_from_db <- function(db, name){
  if(is_file_in_db(name, db)){
    db <- db[-c(name %in% db["File Name"]),]
  }
  write_db(BASE_DIR)
}


delete_file_from_folder <- function(name){
  if(verify_file_present(BASE_DIR, name)){
    ext <- file_ext(file_name)
    if (ext == 'fbx'){
      return(file.remove(paste0(FBX_DIR, file_name)))
    }
    else if(ext == 'bvh'){
      return(file.remove(paste0(BVH_DIR, file_name))) 
    }
  }
  else{
    print(paste(name, " is not present in the directory"))
  }
}



deleteButtonColumn <- function(df, id, ...) {
  # function to create one action button as string
  f <- function(i) {
    as.character(
      actionButton(
        # The id prefix with index
        paste(id, i, sep="_"),
        label = NULL,
        icon = icon('trash'),
        onclick = 'Shiny.setInputValue(\"deletePressed\", this.id, {priority: "event"})'))
  }
  
  deleteCol <- unlist(lapply(seq_len(nrow(df)), f))
  
  # Return a data table
  DT::datatable(cbind(delete = deleteCol, df),
                # Need to disable escaping for html as string to work
                escape = FALSE,
                rownames= FALSE, 
                filter = "top",
                options = list(
                  # Disable sorting for the delete column
                  columnDefs = list(
                    list(targets = 1, sortable = FALSE)),
                  selection = 'single'
                ))
}

parseDeleteEvent <- function(idstr) {
  res <- as.integer(sub(".*_([0-9]+)", "\\1", idstr))
  if (! is.na(res)) res
}


addRowAt <- function(df, row, i) {
  # Slow but easy to understand
  if (i > 1) {
    rbind(df[1:(i - 1), ], row, df[-(1:(i - 1)), ])
  } else {
    rbind(row, df)
  }
  
}


















